function init_params(ns=64, nt=100, do_visu=false)
    L  = 10.0                 # physical domain length
    D  = 1.0                  # diffusion coefficient
    ds = L / ns               # grid spacing
    dt = ds^2 / D / 4.1       # time step
    cs = range(start=ds / 2, stop=L - ds / 2, length=ns) .- 0.5 * L # vector of coord points
    nout = floor(Int, nt / 5) # plotting frequency
    return (; L, D, ns, nt, ds, dt, cs, nout, do_visu)
end

function init_arrays_with_flux(params)
    (; cs, ns) = params
    C  = @. exp(-cs^2 - (cs')^2)
    qx = zeros(ns - 1, ns - 2)
    qy = zeros(ns - 2, ns - 1)
    return C, qx, qy
end

function maybe_init_visu(params, C)
    if params.do_visu
        fig = Figure(; size=(500, 400), fontsize=14)
        ax  = Axis(fig[1, 1][1, 1]; aspect=DataAspect(), title="C")
        plt = heatmap!(ax, params.cs, params.cs, Array(C); colormap=:turbo, colorrange=(0, 1))
        cb  = Colorbar(fig[1, 1][1, 2], plt)
        display(fig)
        return fig, plt
    end
    return nothing, nothing
end

function maybe_update_visu(params, fig, plt, C, it)
    if params.do_visu && (it % params.nout == 0)
        plt[3] = Array(C)
        display(fig)
    end
    return nothing
end

function print_perf(params, t_toc)
    (; ns, nt) = params
    @printf("Time = %1.4e s, T_eff = %1.2f GB/s \n", t_toc, round((2 / 1e9 * ns^2 * sizeof(Float64)) / (t_toc / (nt - 10)), sigdigits=6))
    return nothing
end
