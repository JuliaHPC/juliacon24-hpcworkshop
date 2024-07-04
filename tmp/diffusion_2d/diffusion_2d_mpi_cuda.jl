# 2D linear diffusion MPI solver
# run: ~/.julia/bin/mpiexecjl -n 4 julia --project diffusion_2d_mpi_nonblock_cudaaware_kernel.jl
using Printf, JLD2
using CUDA
import MPI

# enable plotting by default
(!@isdefined do_save) && (do_save = true)

# MPI functions
@views function update_halo!(A, bufs, neighbors, comm)
    # dim-1 (x)
    (neighbors.x[1] != MPI.PROC_NULL) && copyto!(bufs.send_1_1, A[2    , :])
    (neighbors.x[2] != MPI.PROC_NULL) && copyto!(bufs.send_1_2, A[end-1, :])

    reqs = MPI.MultiRequest(4)
    (neighbors.x[1] != MPI.PROC_NULL) && MPI.Irecv!(bufs.recv_1_1, comm, reqs[1]; source=neighbors.x[1])
    (neighbors.x[2] != MPI.PROC_NULL) && MPI.Irecv!(bufs.recv_1_2, comm, reqs[2]; source=neighbors.x[2])

    (neighbors.x[1] != MPI.PROC_NULL) && MPI.Isend(bufs.send_1_1, comm, reqs[3]; dest=neighbors.x[1])
    (neighbors.x[2] != MPI.PROC_NULL) && MPI.Isend(bufs.send_1_2, comm, reqs[4]; dest=neighbors.x[2])
    MPI.Waitall(reqs) # blocking

    (neighbors.x[1] != MPI.PROC_NULL) && copyto!(A[1  , :], bufs.recv_1_1)
    (neighbors.x[2] != MPI.PROC_NULL) && copyto!(A[end, :], bufs.recv_1_2)

    # dim-2 (y)
    (neighbors.y[1] != MPI.PROC_NULL) && copyto!(bufs.send_2_1, A[:, 2    ])
    (neighbors.y[2] != MPI.PROC_NULL) && copyto!(bufs.send_2_2, A[:, end-1])

    reqs = MPI.MultiRequest(4)
    (neighbors.y[1] != MPI.PROC_NULL) && MPI.Irecv!(bufs.recv_2_1, comm, reqs[1]; source=neighbors.y[1])
    (neighbors.y[2] != MPI.PROC_NULL) && MPI.Irecv!(bufs.recv_2_2, comm, reqs[2]; source=neighbors.y[2])

    (neighbors.y[1] != MPI.PROC_NULL) && MPI.Isend(bufs.send_2_1, comm, reqs[3]; dest=neighbors.y[1])
    (neighbors.y[2] != MPI.PROC_NULL) && MPI.Isend(bufs.send_2_2, comm, reqs[4]; dest=neighbors.y[2])
    MPI.Waitall(reqs) # blocking

    (neighbors.y[1] != MPI.PROC_NULL) && copyto!(A[:, 1  ], bufs.recv_2_1)
    (neighbors.y[2] != MPI.PROC_NULL) && copyto!(A[:, end], bufs.recv_2_2)
    return
end

function init_bufs(A)
    return (; send_1_1=CUDA.zeros(Float64, size(A, 2)), send_1_2=CUDA.zeros(Float64, size(A, 2)),
              send_2_1=CUDA.zeros(Float64, size(A, 1)), send_2_2=CUDA.zeros(Float64, size(A, 1)),
              recv_1_1=CUDA.zeros(Float64, size(A, 2)), recv_1_2=CUDA.zeros(Float64, size(A, 2)),
              recv_2_1=CUDA.zeros(Float64, size(A, 1)), recv_2_2=CUDA.zeros(Float64, size(A, 1)))
end

# avoid flux arrays
macro qx(ix, iy) esc(:(-D * (C[$ix+1, $iy] - C[$ix, $iy]) * inv(dx))) end
macro qy(ix, iy) esc(:(-D * (C[$ix, $iy+1] - C[$ix, $iy]) * inv(dy))) end

function diffusion_step!(C2, C, D, dt, dx, dy)
    ix = (blockIdx().x - 1) * blockDim().x + threadIdx().x
    iy = (blockIdx().y - 1) * blockDim().y + threadIdx().y
    if ix <= size(C, 1)-2 && iy <= size(C, 2)-2
        @inbounds C2[ix+1, iy+1] = C[ix+1, iy+1] - dt * ((@qx(ix + 1, iy + 1) - @qx(ix, iy + 1)) * inv(dx) +
                                                         (@qy(ix + 1, iy + 1) - @qy(ix + 1, iy)) * inv(dy))
    end
    return
end

@views function diffusion_2D_mpi(nx=32; do_save=false)
    # MPI
    MPI.Init()
    dims   = [0, 0]
    comm   = MPI.COMM_WORLD
    nprocs = MPI.Comm_size(comm)
    MPI.Dims_create!(nprocs, dims)
    comm_cart = MPI.Cart_create(comm, dims, [0, 0], 1)
    me        = MPI.Comm_rank(comm_cart)
    coords    = MPI.Cart_coords(comm_cart)
    neighbors = (; x=MPI.Cart_shift(comm_cart, 0, 1), y=MPI.Cart_shift(comm_cart, 1, 1))
    # select GPU on multi-GPU system based on shared memory topology
    comm_l = MPI.Comm_split_type(comm, MPI.COMM_TYPE_SHARED, me)
    me_l   = MPI.Comm_rank(comm_l)
    gpu_id = CUDA.device!(me_l) # set GPU
    println("$(gpu_id)")
    (me == 0) && println("nprocs = $(nprocs), dims = $dims")
    # Physics
    lx, ly = 10.0, 10.0
    D      = 1.0
    nt     = 10nx
    # Numerics
    ny         = nx  # local number of grid points
    nthreads   = 32, 8
    nblocks    = cld.((nx, ny), nthreads)
    nx_g, ny_g = dims[1] * (nx - 2) + 2, dims[2] * (ny - 2) + 2  # global number of grid points
    # Derived numerics
    dx, dy = lx / nx_g, ly / ny_g
    dt     = min(dx, dy)^2 / D / 4.1
    # Initial condition
    x0, y0 = coords[1] * (nx - 2) * dx, coords[2] * (ny - 2) * dy
    xc     = [x0 + ix * dx - dx / 2 - 0.5 * lx for ix = 1:nx]
    yc     = [y0 + iy * dy - dy / 2 - 0.5 * ly for iy = 1:ny]
    C      = CuArray(exp.(.-xc .^ 2 .- yc' .^ 2))
    C2     = copy(C)
    bufs   = init_bufs(C)
    t_tic  = 0.0
    # Time loop
    for it in 1:nt
        (it == 11) && (t_tic = Base.time()) # time after warmup
        @cuda threads = nthreads blocks = nblocks diffusion_step!(C2, C, D, dt, dx, dy)
        update_halo!(C2, bufs, neighbors, comm_cart)
        C, C2 = C2, C # pointer swap
    end
    CUDA.synchronize() # needed for accurate timing
    t_toc = (Base.time() - t_tic)
    (me == 0) && @printf("Time = %1.4e s, T_eff = %1.2f GB/s \n", t_toc, round((2 / 1e9 * nx * ny * sizeof(lx)) / (t_toc / (nt - 10)), sigdigits=2))
    # Save to visualise
    do_save && jldsave(joinpath(@__DIR__, "out_$(me).jld2"); C = Array(C[2:end-1, 2:end-1]), lxy = (; lx, ly))
    MPI.Finalize()
    return
end

diffusion_2D_mpi(128; do_save)
