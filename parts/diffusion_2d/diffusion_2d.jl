# 2D linear diffusion solver - serial, vectorized
using Printf
using CairoMakie
include(joinpath(@__DIR__, "../shared.jl"))

function compute_flux!(params, qx, qy, C)
    (; D, ds) = params
    @views qx .= .-D .* diff(C[:, 2:end-1], dims=1) ./ ds
    @views qy .= .-D .* diff(C[2:end-1, :], dims=2) ./ ds
    return
end

function diffusion_step!(params, C, qx, qy)
    (; ds, dt) = params
    @views C[2:end-1, 2:end-1] .-= dt .* (diff(qx, dims=1) ./ ds .+ diff(qy, dims=2) ./ ds)
    return
end

function run_diffusion(; ns=64, nt=100, do_visualize=false)
    params    = init_params(; ns, nt, do_visualize)
    C, qx, qy = init_arrays_with_flux(params)
    fig, plt  = maybe_init_visualization(params, C)
    t_tic = 0.0
    # time loop
    for it in 1:nt
        # time after warmup (ignore first 10 iterations)
        (it == 11) && (t_tic = Base.time())
        # diffusion
        compute_flux!(params, qx, qy, C)
        diffusion_step!(params, C, qx, qy)
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
    run_diffusion(; ns=256, nt=500, do_visualize)
end
