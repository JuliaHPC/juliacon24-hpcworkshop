# 2D linear diffusion solver - GPU cuda version
using Printf
using CairoMakie
using CUDA
include(joinpath(@__DIR__, "../shared.jl"))

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

function run_diffusion(; ns=64, nt=100, do_visualize=false)
    params   = init_params_gpu(; ns, nt, do_visualize)
    C, C2    = init_arrays_gpu(params)
    fig, plt = maybe_init_visualization(params, C)
    t_tic = 0.0
    # Time loop
    for it in 1:nt
        # time after warmup (ignore first 10 iterations)
        (it == 11) && (t_tic = Base.time())
        # diffusion
        diffusion_step!(params, C2, C)
        C, C2 = C2, C # pointer swap
        # visualization
        maybe_update_visualization(params, fig, plt, C, it)
    end
    # synchronize the gpu before querying the final time
    CUDA.synchronize()
    t_toc = (Base.time() - t_tic)
    print_perf(params, t_toc)
    return nothing
end

# Running things...

# enable visualization by default
(!@isdefined do_visualize) && (do_visualize = true)
# enable execution by default
(!@isdefined do_run) && (do_run = true)

if do_run
    run_diffusion(; ns=256, do_visualize)
end
