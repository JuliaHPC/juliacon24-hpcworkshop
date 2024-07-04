# 2D linear diffusion solver - serial, loop version
using Printf
using CairoMakie
include(joinpath(@__DIR__, "../shared.jl"))

# convenience macros simply to avoid writing nested finite-difference expression
macro qx(ix, iy) esc(:(-D * (C[$ix+1, $iy] - C[$ix, $iy]) / ds)) end
macro qy(ix, iy) esc(:(-D * (C[$ix, $iy+1] - C[$ix, $iy]) / ds)) end

function diffusion_step!(params, C2, C)
    (; ds, dt, D) = params
    # respect column major order
    for iy in 1:size(C, 2)-2
        for ix in 1:size(C, 1)-2
            @inbounds C2[ix+1, iy+1] = C[ix+1, iy+1] - dt * ((@qx(ix+1, iy+1) - @qx(ix, iy+1)) / ds +
                                                             (@qy(ix+1, iy+1) - @qy(ix+1, iy)) / ds)
        end
    end
    return nothing
end

function run_diffusion(; ns=64, nt=100, do_visualize=false)
    params   = init_params(; ns, nt, do_visualize)
    C, C2    = init_arrays(params)
    fig, plt = maybe_init_visualization(params, C)
    t_tic = 0.0
    # time loop
    for it in 1:nt
        # time after warmup (ignore first 10 iterations)
        (it == 11) && (t_tic = Base.time())
        # diffusion
        diffusion_step!(params, C2, C)
        C, C2 = C2, C # pointer swap
        # visualization
        maybe_update_visualization(params, fig, plt, C, it)
    end
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
