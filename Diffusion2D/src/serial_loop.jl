function diffusion_step!(impl::SerialLoop, C2, C)
    (; ds, dt, D) = impl.params
    for iy ∈ 1:size(C, 2)-2
        for ix ∈ 1:size(C, 1)-2
            @inbounds C2[ix+1, iy+1] = C[ix+1, iy+1] - dt * ((@qx(ix+1, iy+1) - @qx(ix, iy+1)) / ds +
                                                             (@qy(ix+1, iy+1) - @qy(ix+1, iy)) / ds)
        end
    end
    return nothing
end

function run(impl::SerialLoop)
    C, C2 = initialize_arrays(impl)
    fig, plt = maybe_init_visualization(impl, C)
    t_tic = 0.0
    nt = impl.params.nt
    for it in 1:nt # time loop
        (it == 11) && (t_tic = Base.time()) # time after warmup (ignore first 10 runs)
        diffusion_step!(impl, C2, C)
        C, C2 = C2, C # pointer swap
        maybe_update_visualization(impl, fig, plt, C, it)
    end
    t_toc = (Base.time() - t_tic)
    print_result(impl, t_toc)
    return nothing
end
