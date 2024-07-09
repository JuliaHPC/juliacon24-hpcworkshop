# 2D linear diffusion solver - GPU cuda version
using Printf
using JLD2
using CUDA
include(joinpath(@__DIR__, "../../shared.jl"))

# convenience macros simply to avoid writing nested finite-difference expression
macro qx(ix, iy) esc(:(-D * (C[$ix+1, $iy] - C[$ix, $iy]) * inv(ds))) end
macro qy(ix, iy) esc(:(-D * (C[$ix, $iy+1] - C[$ix, $iy]) * inv(ds))) end

function diffusion_step_kernel!(params, C2, C)
    (; ds, dt, D) = params
    ix = (blockIdx().x - 1) * blockDim().x + threadIdx().x # CUDA vectorised unique index
    iy = (blockIdx().y - 1) * blockDim().y + threadIdx().y # CUDA vectorised unique index
    if ix <= size(C, 1)-2 && iy <= size(C, 2)-2
        @inbounds C2[ix+1, iy+1] = C[ix+1, iy+1] - dt * ((@qx(ix + 1, iy + 1) - @qx(ix, iy + 1)) * inv(ds) +
                                                         (@qy(ix + 1, iy + 1) - @qy(ix + 1, iy)) * inv(ds))
    end
    return nothing
end

function diffusion_step!(params, C2, C)
    (; nthreads, nblocks) = params
    @cuda threads = nthreads blocks = nblocks diffusion_step_kernel!(params, C2, C)
    return nothing
end

function run_diffusion(; ns=64, nt=100, do_save=false)
    params   = init_params_gpu(; ns, nt, do_save)
    C, C2    = init_arrays_gpu(params)
    t_tic = 0.0
    # Time loop
    for it in 1:nt
        # time after warmup (ignore first 10 iterations)
        (it == 11) && (t_tic = Base.time())
        # diffusion
        diffusion_step!(params, C2, C)
        C, C2 = C2, C # pointer swap
    end
    # synchronize the gpu before querying the final time
    CUDA.synchronize()
    t_toc = (Base.time() - t_tic)
    print_perf(params, t_toc)
    do_save && jldsave(joinpath(@__DIR__, "out_gpu.jld2"); C = Array(C), l = params.L)
    return nothing
end

# Running things...

# enable saving by default
(!@isdefined do_save) && (do_save = true)
# enable execution by default
(!@isdefined do_run) && (do_run = true)

if do_run
    if !isempty(ARGS)
        run_diffusion(; ns=parse(Int, ARGS[1]), do_save)
    else
        run_diffusion(; ns=256, do_save)
    end
end
