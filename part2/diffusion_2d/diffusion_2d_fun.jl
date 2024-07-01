# 2D linear diffusion solver
using Printf, CairoMakie

# enable plotting by default
(!@isdefined do_vis) && (do_vis = true)

# avoid flux arrays
macro qx() esc(:(.-D * diff(C[:, 2:end-1], dims=1) / dx)) end
macro qy() esc(:(.-D * diff(C[2:end-1, :], dims=2) / dy)) end

function diffusion_step!(C, D, dt, dx, dy)
    C[2:end-1, 2:end-1] .-= dt * (diff(@qx(), dims=1) / dx .+ diff(@qy(), dims=2) / dy)
    return
end

@views function diffusion_2D(nx=64; do_vis=false)
    # Physics
    lx, ly = 10.0, 10.0
    D      = 1.0
    nt     = 200nx
    # Numerics
    ny     = nx
    nout   = 50nx
    # Derived numerics
    dx, dy = lx / nx, ly / ny
    dt     = min(dx, dy)^2 / D / 4.1
    # Initial condition
    xc     = [ix * dx - dx / 2 - 0.5 * lx for ix = 1:nx]
    yc     = [iy * dy - dy / 2 - 0.5 * ly for iy = 1:ny]
    C      = exp.(.-xc .^ 2 .- yc' .^ 2)
    t_tic  = 0.0
    # visu
    fig = Figure(; size=(500, 400), fontsize=14)
    ax  = Axis(fig[1, 1][1, 1]; aspect=DataAspect(), title="C")
    hm  = heatmap!(ax, xc, yc, Array(C); colormap=:turbo)
    cb  = Colorbar(fig[1, 1][1, 2], hm)
    display(fig)
    # Time loop
    for it = 1:nt
        (it == 11) && (t_tic = Base.time()) # time after warmup
        diffusion_step!(C, D, dt, dx, dy)
        do_vis && (it % nout == 0) && (hm[3] = Array(C); display(fig))
    end
    t_toc = (Base.time() - t_tic)
    @printf("Time = %1.4e s, T_eff = %1.2f GB/s \n", t_toc, round((2 / 1e9 * nx * ny * sizeof(lx)) / (t_toc / (nt - 10)), sigdigits=3))
    return
end

diffusion_2D(64; do_vis)
