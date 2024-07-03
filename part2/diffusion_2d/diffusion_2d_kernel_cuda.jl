# 2D linear diffusion solver
using Printf, CairoMakie
using CUDA

# enable plotting by default
(!@isdefined do_vis) && (do_vis = true)
# enable execution by default
(!@isdefined do_exec) && (do_exec = true)

# avoid flux arrays
macro qx(ix, iy) esc(:(-D * (C[$ix+1, $iy] - C[$ix, $iy]) / dx)) end
macro qy(ix, iy) esc(:(-D * (C[$ix, $iy+1] - C[$ix, $iy]) / dy)) end

function diffusion_step!(C2, C, D, dt, dx, dy)
    ix = (blockIdx().x-1) * blockDim().x + threadIdx().x;
    iy = (blockIdx().y-1) * blockDim().y + threadIdx().y;
    @inbounds C2[ix+1, iy+1] = C[ix+1, iy+1] - dt * ((@qx(ix+1, iy+1) - @qx(ix, iy+1)) / dx +
                                                     (@qy(ix+1, iy+1) - @qy(ix+1, iy)) / dy)
    return
end

function diffusion_2D(nx=64; do_vis=false, nt=10nx)
    # Physics
    lx, ly = 10.0, 10.0
    D      = 1.0
    nt     = 10nx
    # Numerics
    ny       = nx
    nout     = floor(Int, nt / 5)
    nthreads = 32, 8
    nblocks  = cld.((nx, ny), nthreads)
    # Derived numerics
    dx, dy = lx / nx, ly / ny
    dt     = min(dx, dy)^2 / D / 4.1 / 2
    # Initial condition
    xc     = [ix * dx - dx / 2 - 0.5 * lx for ix = 1:nx]
    yc     = [iy * dy - dy / 2 - 0.5 * ly for iy = 1:ny]
    C      = CuArray(exp.(.-xc .^ 2 .- yc' .^ 2))
    C2     = copy(C)
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
        @cuda threads = nthreads blocks = nblocks diffusion_step!(C2, C, D, dt, dx, dy)
        C, C2 = C2, C # pointer swap
        do_vis && (it % nout == 0) && (hm[3] = Array(C); display(fig))
    end
    t_toc = (Base.time() - t_tic)
    @printf("Time = %1.4e s, T_eff = %1.2f GB/s \n", t_toc, round((2 / 1e9 * nx * ny * sizeof(lx)) / (t_toc / (nt - 10)), sigdigits=3))
    return
end

if do_exec
    diffusion_2D(256; do_vis)
end