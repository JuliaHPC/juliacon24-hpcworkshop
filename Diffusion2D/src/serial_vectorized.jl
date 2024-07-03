function update_flux!(impl::SerialVectorized, qx, qy, C)
    (; ds, D) = impl.params
    # update fluxes (first order derivatives)
    qx .= .-D .* diff(C[:, 2:end-1], dims=1) ./ ds
    qy .= .-D .* diff(C[2:end-1, :], dims=2) ./ ds
    return nothing
end

function diffusion_step!(impl::SerialVectorized, C, qx, qy)
    (; ds, dt) = impl.params
    C[2:end-1, 2:end-1] .-= dt .* (diff(qx, dims=1) ./ ds .+ diff(qy, dims=2) ./ ds)
    return nothing
end

function run(impl::SerialVectorized)
    C, qx, qy = initialize_arrays_with_flux(impl)
    fig, plt = maybe_init_visualization(impl, C)
    t_tic = 0.0
    nt = impl.params.nt
    for it in 1:nt # time loop
        (it == 11) && (t_tic = Base.time()) # time after warmup (ignore first 10 runs)
        update_flux!(impl, qx, qy, C)
        diffusion_step!(impl, C, qx, qy)
        maybe_update_visualization(impl, fig, plt, C, it)
    end
    t_toc = (Base.time() - t_tic)
    print_result(impl, t_toc)
    return nothing
end
