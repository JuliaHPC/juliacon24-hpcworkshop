# 2D linear diffusion solver
using Printf, CairoMakie

include("shared.jl")

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

function run(; ns=64, nt=100, do_visu=false)
    params    = init_params(ns, nt, do_visu)
    C, qx, qy = init_arrays_with_flux(params)
    fig, plt  = maybe_init_visu(params, C)
    t_tic = 0.0
    # Time loop
    for it = 1:nt
        (it == 11) && (t_tic = Base.time()) # time after warmup (ignore first 10 iterations)
        compute_flux!(params, qx, qy, C)
        diffusion_step!(params, C, qx, qy)
        maybe_update_visu(params, fig, plt, C, it)
    end
    t_toc = (Base.time() - t_tic)
    print_perf(params, t_toc)
    return
end
