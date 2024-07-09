## PARAMETER INITIALIZATION
function init_params(; ns=64, nt=100, kwargs...)
    L    = 10.0               # physical domain length
    D    = 1.0                # diffusion coefficient
    ds   = L / ns             # grid spacing
    dt   = ds^2 / D / 8.2     # time step
    cs   = range(start=ds / 2, stop=L - ds / 2, length=ns) .- 0.5 * L # vector of coord points
    nout = floor(Int, nt / 5) # plotting frequency
    return (; L, D, ns, nt, ds, dt, cs, nout, kwargs...)
end

function init_params_mpi(; dims, coords, ns=64, nt=100, kwargs...)
    L    = 10.0                      # physical domain length
    D    = 1.0                       # diffusion coefficient
    nx_g = dims[1] * (ns - 2) + 2    # global number of grid points along dim 1
    ny_g = dims[2] * (ns - 2) + 2    # global number of grid points along dim 2
    dx   = L / nx_g                  # grid spacing
    dy   = L / ny_g                  # grid spacing
    dt   = min(dx, dy)^2 / D / 8.2   # time step
    x0   = coords[1] * (ns - 2) * dx # coords shift to get global coords on  local process
    y0   = coords[2] * (ns - 2) * dy # coords shift to get global coords on  local process
    xcs  = LinRange(x0 + dx / 2, x0 + ns * dx - dx / 2, ns) .- 0.5 .* L # local vector of global coord points
    ycs  = LinRange(y0 + dy / 2, y0 + ns * dx - dy / 2, ns) .- 0.5 .* L # local vector of global coord points
    return (; L, D, ns, nt, dx, dy, dt, xcs, ycs, kwargs...)
end

function init_params_gpu(; ns=64, nt=100, kwargs...)
    L    = 10.0                   # physical domain length
    D    = 1.0                    # diffusion coefficient
    ds   = L / ns                 # grid spacing
    dt   = ds^2 / D / 8.2         # time step
    cs   = range(start=ds / 2, stop=L - ds / 2, length=ns) .- 0.5 * L # vector of coord points
    nout = floor(Int, nt / 5)     # plotting frequency
    nthreads = 32, 8              # number of threads per block
    nblocks  = cld.(ns, nthreads) # number of blocks
    return (; L, D, ns, nt, ds, dt, cs, nout, nthreads, nblocks, kwargs...)
end

function init_params_gpu_mpi(; dims, coords, ns=64, nt=100, kwargs...)
    L    = 10.0                      # physical domain length
    D    = 1.0                       # diffusion coefficient
    nx_g = dims[1] * (ns - 2) + 2    # global number of grid points along dim 1
    ny_g = dims[2] * (ns - 2) + 2    # global number of grid points along dim 2
    dx   = L / nx_g                  # grid spacing
    dy   = L / ny_g                  # grid spacing
    dt   = min(dx, dy)^2 / D / 8.2   # time step
    x0   = coords[1] * (ns - 2) * dx # coords shift to get global coords on  local process
    y0   = coords[2] * (ns - 2) * dy # coords shift to get global coords on  local process
    xcs  = LinRange(x0 + dx / 2, x0 + ns * dx - dx / 2, ns) .- 0.5 * L # local vector of global coord points
    ycs  = LinRange(y0 + dy / 2, y0 + ns * dy - dy / 2, ns) .- 0.5 * L # local vector of global coord points
    nthreads = 32, 8                 # number of threads per block
    nblocks  = cld.(ns, nthreads)    # number of blocks
    return (; L, D, ns, nt, dx, dy, dt, xcs, ycs, nthreads, nblocks, kwargs...)
end

## ARRAY INITIALIZATION
function init_arrays_with_flux(params)
    (; cs, ns) = params
    C  = @. exp(-cs^2 - (cs')^2)
    qx = zeros(ns - 1, ns - 2)
    qy = zeros(ns - 2, ns - 1)
    return C, qx, qy
end

function init_arrays(params)
    (; cs) = params
    C  = @. exp(-cs^2 - (cs')^2)
    C2 = copy(C)
    return C, C2
end

function init_arrays_mpi(params)
    (; xcs, ycs) = params
    C  = @. exp(-xcs^2 - (ycs')^2)
    C2 = copy(C)
    return C, C2
end

function init_arrays_gpu(params)
    (; cs) = params
    C  = CuArray(@. exp(-cs^2 - (cs')^2))
    C2 = copy(C)
    return C, C2
end

function init_arrays_gpu_mpi(params)
    (; xcs, ycs) = params
    C  = CuArray(@. exp(-xcs^2 - (ycs')^2))
    C2 = copy(C)
    return C, C2
end

## VISUALIZATION & PRINTING
function maybe_init_visualization(params, C)
    if params.do_visualize
        fig = Figure(; size=(500, 400), fontsize=14)
        ax  = Axis(fig[1, 1][1, 1]; aspect=DataAspect(), title="C")
        plt = heatmap!(ax, params.cs, params.cs, Array(C); colormap=:turbo, colorrange=(0, 1))
        cb  = Colorbar(fig[1, 1][1, 2], plt)
        display(fig)
        return fig, plt
    end
    return nothing, nothing
end

function maybe_update_visualization(params, fig, plt, C, it)
    if params.do_visualize && (it % params.nout == 0)
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
