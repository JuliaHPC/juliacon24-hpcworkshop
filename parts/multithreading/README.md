# Diffusion 2D - Multithreading (shared-memory parallelism)

The diffusion kernel (taken from `diffusion_2d_loop.jl`):

```julia
for iy in 1:size(C, 2)-2
    for ix in 1:size(C, 1)-2
        @inbounds C2[ix+1, iy+1] = C[ix+1, iy+1] - dt * ((@qx(ix+1, iy+1) - @qx(ix, iy+1)) / ds +
                                                            (@qy(ix+1, iy+1) - @qy(ix+1, iy)) / ds)
    end
end
```