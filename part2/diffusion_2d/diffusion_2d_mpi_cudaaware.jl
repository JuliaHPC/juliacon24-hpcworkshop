# 2D linear diffusion CUDA-aware MPI solver
# run: ~/.julia/bin/mpiexecjl -n 4 julia --project diffusion_2d_mpi_cudaaware.jl
using Printf, JLD2
import MPI

# enable plotting by default
(!@isdefined do_save) && (do_save = true)

# MPI functions
@views function update_halo!(A, bufs, neighbors, comm)
    # Send to / receive from neighbor 1 in dimension x ("left neighbor")
    if neighbors.x[1] != MPI.PROC_NULL
        copyto!(bufs.send_2, A[2, :])
        MPI.Send(bufs.send_2, neighbors.x[1], 0, comm)
        MPI.Recv!(bufs.recv_2, neighbors.x[1], 1, comm)
        copyto!(A[1, :], bufs.recv_2)
    end
    # Send to / receive from neighbor 2 in dimension x ("right neighbor")
    if neighbors.x[2] != MPI.PROC_NULL
        copyto!(bufs.send_2, A[end-1, :])
        MPI.Recv!(bufs.recv_2, neighbors.x[2], 0, comm)
        MPI.Send(bufs.send_2, neighbors.x[2], 1, comm)
        copyto!(A[end, :], bufs.recv_2)
    end
    # Send to / receive from neighbor 1 in dimension y ("bottom neighbor")
    if neighbors.y[1] != MPI.PROC_NULL
        copyto!(bufs.send_1, A[:, 2])
        MPI.Send(bufs.send_1, neighbors.y[1], 2, comm)
        MPI.Recv!(bufs.recv_1, neighbors.y[1], 3, comm)
        copyto!(A[:, 1], bufs.recv_1)
    end
    # Send to / receive from neighbor 2 in dimension y ("top neighbor")
    if neighbors.y[2] != MPI.PROC_NULL
        copyto!(bufs.send_1, A[:, end-1])
        MPI.Recv!(bufs.recv_1, neighbors.y[2], 2, comm)
        MPI.Send(bufs.send_1, neighbors.y[2], 3, comm)
        copyto!(A[:, end], bufs.recv_1)
    end
    return
end

function init_bufs(A)
    return bufs = (; send_1=CUDA.zeros(size(A, 1)), send_2=CUDA.zeros(size(A, 2)),
                     recv_1=CUDA.zeros(size(A, 1)), recv_2=CUDA.zeros(size(A, 2)))
end

@views function diffusion_2D_mpi(nx=32; do_save=false)
    # MPI
    MPI.Init()
    dims   = [0, 0]
    comm   = MPI.COMM_WORLD
    nprocs = MPI.Comm_size(comm)
    MPI.Dims_create!(nprocs, dims)
    comm_cart   = MPI.Cart_create(comm, dims, [0, 0], 1)
    me          = MPI.Comm_rank(comm_cart)
    coords      = MPI.Cart_coords(comm_cart)
    neighbors   = (; x=MPI.Cart_shift(comm_cart, 0, 1), y=MPI.Cart_shift(comm_cart, 1, 1))
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
    ny     = nx  # local number of grid points
    nx_g, ny_g = dims[1] * (nx - 2) + 2, dims[2] * (ny - 2) + 2  # global number of grid points
    # Derived numerics
    dx, dy = lx / nx_g, ly / ny_g
    dt     = min(dx, dy)^2 / D / 4.1
    # Array allocation
    qx     = CUDA.zeros(Float64, nx - 1, ny - 2)
    qy     = CUDA.zeros(Float64, nx - 2, ny - 1)
    # Initial condition
    x0, y0 = coords[1] * (nx - 2) * dx, coords[2] * (ny - 2) * dy
    xc     = [x0 + ix * dx - dx / 2 - 0.5 * lx for ix = 1:nx]
    yc     = [y0 + iy * dy - dy / 2 - 0.5 * ly for iy = 1:ny]
    C      = CuArray(exp.(.-xc .^ 2 .- yc' .^ 2))
    bufs   = init_bufs(C)
    t_tic  = 0.0
    # Time loop
    for it = 1:nt
        (it == 11) && (t_tic = Base.time()) # time after warmup
        qx .= .-D .* diff(C[:, 2:end-1], dims=1) ./ dx
        qy .= .-D .* diff(C[2:end-1, :], dims=2) ./ dy
        C[2:end-1, 2:end-1] .-= dt .* (diff(qx, dims=1) ./ dx .+ diff(qy, dims=2) ./ dy)
        update_halo!(C, bufs, neighbors, comm_cart)
    end
    t_toc = (Base.time() - t_tic)
    (me == 0) && @printf("Time = %1.4e s, T_eff = %1.2f GB/s \n", t_toc, round((2 / 1e9 * nx * ny * sizeof(lx)) / (t_toc / (nt - 10)), sigdigits=2))
    # Save to visualise
    do_save && jldsave(joinpath(@__DIR__, "out_$(me).jld2"); C = Array(C[2:end-1, 2:end-1]), lxy = (; lx, ly))
    MPI.Finalize()
    return
end

diffusion_2D_mpi(128; do_save)
