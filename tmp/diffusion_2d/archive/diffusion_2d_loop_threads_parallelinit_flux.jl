# 2D linear diffusion solver
using Printf, CairoMakie

# enable plotting by default
(!@isdefined do_vis) && (do_vis = true)
# enable execution by default
(!@isdefined do_exec) && (do_exec = true)

function compute_fluxes!(qx, qy, C, D, dx, dy, nx, ny)
    Threads.@threads :static for iy in 2:(ny-1)
        for ix in 1:(nx-1)
            @inbounds qx[ix, iy-1] = -D * (C[ix+1, iy] - C[ix, iy]) / dx
        end
    end
    Threads.@threads :static for iy in 1:(ny-1)
        for ix in 2:(nx-1)
            @inbounds qy[ix-1, iy] = -D * (C[ix, iy+1] - C[ix, iy]) / dy
        end
    end
    return nothing
end

function diffusion_step!(C, dt, dx, dy, qx, qy)
    nx, ny = size(C)
    Threads.@threads :static for iy in 2:(ny-1)
        for ix in 2:(nx-1)
            @inbounds C[ix, iy] = C[ix, iy] - dt *
                                        ((qx[ix, iy-1] - qx[ix-1, iy-1]) / dx +
                                         (qy[ix-1, iy] - qy[ix-1, iy-1]) / dy)
        end
    end
    return
end

function diffusion_2D(nx=64; do_vis=false, nt=10nx)
    # Physics
    lx, ly = 10.0, 10.0
    D      = 1.0
    # Numerics
    ny     = nx
    nout   = floor(Int, nt / 5)
    # Derived numerics
    dx, dy = lx / nx, ly / ny
    dt     = min(dx, dy)^2 / D / 4.1 / 2
    # Initial condition
    xc     = [ix * dx - dx / 2 - 0.5 * lx for ix = 1:nx]
    yc     = [iy * dy - dy / 2 - 0.5 * ly for iy = 1:ny]
    # parallel initialization
    C      = Matrix{Float64}(undef, nx, ny)
    qx     = Matrix{Float64}(undef, nx - 1, ny - 2)
    qy     = Matrix{Float64}(undef, nx - 2, ny - 1)
    Threads.@threads :static for iy in axes(C, 2)
        for ix in axes(C, 1)
            C[ix, iy] = exp(- xc[ix]^2 - yc[iy]^2)
        end
    end
    Threads.@threads :static for iy in axes(qx, 2)
        for ix in axes(qx, 1)
            qx[ix, iy] = 0.0
        end
    end
    Threads.@threads :static for iy in axes(qy, 2)
        for ix in axes(qy, 1)
            qy[ix, iy] = 0.0
        end
    end
    t_tic  = 0.0
    # visu
    if do_vis
        fig = Figure(; size=(500, 400), fontsize=14)
        ax  = Axis(fig[1, 1][1, 1]; aspect=DataAspect(), title="C")
        hm  = heatmap!(ax, xc, yc, Array(C); colormap=:turbo, colorrange=(0, 1))
        cb  = Colorbar(fig[1, 1][1, 2], hm)
        display(fig)
    end
    # Time loop
    for it = 1:nt
        (it == 11) && (t_tic = Base.time()) # time after warmup
        compute_fluxes!(qx, qy, C, D, dx, dy, nx, ny)
        diffusion_step!(C, dt, dx, dy, qx, qy)
        do_vis && (it % nout == 0) && (hm[3] = Array(C); display(fig))
    end
    t_toc = (Base.time() - t_tic)
    @printf("Time = %1.4e s, T_eff = %1.2f GB/s \n", t_toc, round((2 / 1e9 * nx * ny * sizeof(lx)) / (t_toc / (nt - 10)), sigdigits=3))
    return
end

if do_exec
    diffusion_2D(256; do_vis)
    # diffusion_2D(4096; do_vis, nt=400)
end
