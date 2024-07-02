function initialize_arrays(impl::Multithreading)
    (; L, ns, ds) = impl.params
    pts    = range(start=ds / 2, stop=L - ds / 2, length=ns) .- 0.5 * L
    C      = Matrix{Float64}(undef, ns, ns)
    C2     = Matrix{Float64}(undef, ns, ns)
    if impl.parallel_init
        # parallel initialization
        if impl.static
            Threads.@threads :static for iy in axes(C, 2)
                for ix in axes(C, 1)
                    C[ix, iy]  = exp(- pts[ix]^2 - pts[iy]^2)
                    C2[ix, iy] = C[ix, iy] # element-wise copy
                end
            end
        else
            Threads.@threads :dynamic for iy in axes(C, 2)
                for ix in axes(C, 1)
                    C[ix, iy]  = exp(- pts[ix]^2 - pts[iy]^2)
                    C2[ix, iy] = C[ix, iy] # element-wise copy
                end
            end
        end
    else
        # serial initialization
        for iy in axes(C, 2)
            for ix in axes(C, 1)
                C[ix, iy]  = exp(- pts[ix]^2 - pts[iy]^2)
                C2[ix, iy] = C[ix, iy] # element-wise copy
            end
        end
    end
    return C, C2
end

function diffusion_step!(impl::Multithreading, C2, C)
    (; ds, dt, D) = impl.params
    if impl.static
        Threads.@threads :static for iy ∈ 1:size(C, 2)-2
            for ix ∈ 1:size(C, 1)-2
                @inbounds C2[ix+1, iy+1] = C[ix+1, iy+1] - dt * ((@qx(ix+1, iy+1) - @qx(ix, iy+1)) / ds +
                                                                (@qy(ix+1, iy+1) - @qy(ix+1, iy)) / ds)
            end
        end
    else
        Threads.@threads :dynamic for iy ∈ 1:size(C, 2)-2
            for ix ∈ 1:size(C, 1)-2
                @inbounds C2[ix+1, iy+1] = C[ix+1, iy+1] - dt * ((@qx(ix+1, iy+1) - @qx(ix, iy+1)) / ds +
                                                                (@qy(ix+1, iy+1) - @qy(ix+1, iy)) / ds)
            end
        end
    end
    return nothing
end

function run(impl::Multithreading)
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
