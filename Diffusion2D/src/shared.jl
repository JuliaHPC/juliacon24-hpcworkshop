# VISUALIZATION
function maybe_init_visualization(impl::AbstractImplementation, C)
    if impl.do_viz
        (; ds, L, ns) = impl.params
        pts = range(start=ds / 2, stop=L - ds / 2, length=ns) .- 0.5 * L
        fig = Figure(; size=(500, 400), fontsize=14)
        ax  = Axis(fig[1, 1][1, 1]; aspect=DataAspect(), title="C")
        plt  = heatmap!(ax, pts, pts, Array(C); colormap=:turbo, colorrange=(0, 1))
        cb  = Colorbar(fig[1, 1][1, 2], plt)
        display(fig)
        return fig, plt
    end
    return nothing, nothing
end

function maybe_update_visualization(impl::AbstractImplementation, fig, plt, C, it)
    if impl.do_viz && (it % impl.nout == 0)
        plt[3] = Array(C)
        display(fig)
    end
    return nothing
end

# PRINTING
function print_result(impl::AbstractImplementation, t_toc)
    (; ns, nt) = impl.params
    @printf("Time = %1.4e s, T_eff = %1.2f GB/s \n", t_toc, round((2 / 1e9 * ns^2 * sizeof(Float64)) / (t_toc / (nt - 10)), sigdigits=3))
    return nothing
end


# convenience macros for computing fluxes on the fly
macro qx(ix, iy) esc(:(-D * (C[$ix+1, $iy] - C[$ix, $iy]) / ds)) end
macro qy(ix, iy) esc(:(-D * (C[$ix, $iy+1] - C[$ix, $iy]) / ds)) end


# TODO: should these initializations be shared?! Currently each only used by a single implementation.
function initialize_arrays(impl::AbstractImplementation)
    (; L, ns, ds) = impl.params
    pts    = range(start=ds / 2, stop=L - ds / 2, length=ns) .- 0.5 * L
    C      = @. exp(-(pts)^2 -(pts')^2)
    return C, copy(C)
end

function initialize_arrays_with_flux(impl::AbstractImplementation)
    (; L, ns, ds) = impl.params
    pts    = range(start=ds / 2, stop=L - ds / 2, length=ns) .- 0.5 * L
    # diffusive field
    C      = @. exp(-(pts)^2 -(pts')^2)
    # "flux" arrays (first order derivatives)
    qx     = zeros(ns - 1, ns - 2)
    qy     = zeros(ns - 2, ns - 1)
    return C, qx, qy
end
