# 2D linear diffusion solver - GPU MPI
using Printf
using JLD2
using CUDA
using MPI
include(joinpath(@__DIR__, "../shared.jl"))

# convenience macros simply to avoid writing nested finite-difference expression
macro qx(ix, iy) esc(:(-D * (C[$ix+1, $iy] - C[$ix, $iy]) * inv(dx))) end
macro qy(ix, iy) esc(:(-D * (C[$ix, $iy+1] - C[$ix, $iy]) * inv(dy))) end

function diffusion_step_kernel!(params, C2, C)
    (; dx, dy, dt, D) = params
    ix = (blockIdx().x - 1) * blockDim().x + threadIdx().x # CUDA vectorised unique index
    iy = (blockIdx().y - 1) * blockDim().y + threadIdx().y # CUDA vectorised unique index
    if ix <= size(C, 1)-2 && iy <= size(C, 2)-2
        @inbounds C2[ix+1, iy+1] = C[ix+1, iy+1] - dt * ((@qx(ix + 1, iy + 1) - @qx(ix, iy + 1)) * inv(dx) +
                                                         (@qy(ix + 1, iy + 1) - @qy(ix + 1, iy)) * inv(dy))
    end
    return nothing
end

function diffusion_step!(params, C2, C)
    (; nthreads, nblocks) = params
    @cuda threads = nthreads blocks = nblocks diffusion_step_kernel!(params, C2, C)
    return nothing
end

# MPI functions
@views function update_halo!(A, bufs, neighbors, comm)
    #
    # !! TODO !!
    #
    # We want to replace use the `update_halo!` function defined in the CPU MPI script
    # and use it here. Since we are using GPU-aware MPI, we can directly re-use the
    # function since MPI communication will take care of exchanging halo values living
    # in GPU memory.
    #
    return
end

function init_bufs(A)
    #
    # !! TODO !!
    #
    # We are using GPU-aware MPI, which greatly simplifies the implementation and ensures
    # good performance. GPU-aware MPI exchanges GPU pointers and thus we shpuld initialize
    # the send and receive buffers on the GPU memory. Complete the missing `return` statement
    # by replicating what we did for CPU MPI but making sure to initialise buffers on the GPU
    # using the correct data type (Float64).
    #
    return (; # TODO )
end

function run_diffusion(; ns=64, nt=100, do_save=false)
    MPI.Init()
    comm      = MPI.COMM_WORLD
    nprocs    = MPI.Comm_size(comm)
    dims      = MPI.Dims_create(nprocs, (0, 0)) |> Tuple
    comm_cart = MPI.Cart_create(comm, dims)
    me        = MPI.Comm_rank(comm_cart)
    coords    = MPI.Cart_coords(comm_cart) |> Tuple
    neighbors = (; x=MPI.Cart_shift(comm_cart, 0, 1), y=MPI.Cart_shift(comm_cart, 1, 1))
    # select GPU on multi-GPU system based on shared memory topology
    #
    # !! TODO !!
    #
    # We need to define a local MPI communicator based on `MPI.COMM_TYPE_SHARED` in order to
    # retireve the node-local rank of the MPI processes given we want to map each GPU from one
    # node to a MPI rank. Then we want to get the rank from the new communicator and use
    # it to set the GPU device.
    #
    println("$(gpu_id), out of: $(ndevices())")
    (me == 0) && println("nprocs = $(nprocs), dims = $dims")

    params = init_params_gpu_mpi(; dims, coords, ns, nt, do_save)
    C, C2  = init_arrays_gpu_mpi(params)
    bufs   = init_bufs(C)
    t_tic  = 0.0
    # Time loop
    for it in 1:nt
        # time after warmup (ignore first 10 iterations)
        (it == 11) && (t_tic = Base.time())
        # diffusion
        diffusion_step!(params, C2, C)
        update_halo!(C2, bufs, neighbors, comm_cart)
        C, C2 = C2, C # pointer swap
    end
    # synchronize the gpu before querying the final time
    CUDA.synchronize()
    t_toc = (Base.time() - t_tic)
    # "master" prints performance
    (me == 0) && print_perf(params, t_toc)
    # save to (maybe) visualize later
    if do_save
        jldsave(joinpath(@__DIR__, "out_$(me).jld2"); C = Array(C[2:end-1, 2:end-1]), lxy = (; lx=params.L, ly=params.L))
    end
    MPI.Finalize()
    return
end

# Running things...

# enable save to disk by default
(!@isdefined do_save) && (do_save = true)
# enable execution by default
(!@isdefined do_run) && (do_run = true)

if do_run
    run_diffusion(; ns=256, do_save)
end
