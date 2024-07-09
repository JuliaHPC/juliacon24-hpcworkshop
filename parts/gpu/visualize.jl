# Visualisation script for the 2D MPI solver
using CairoMakie
using JLD2

function vizme2D()
    C, l = load(joinpath(@__DIR__, "out_gpu.jld2"), "C", "l")
    xc, yc = LinRange.(0, (l, l), size(C))
    fig  = Figure(; size=(500, 400), fontsize=14)
    ax   = Axis(fig[1, 1][1, 1]; aspect=DataAspect(), title="C")
    hm   = heatmap!(ax, xc, yc, C; colormap=:turbo, colorrange=(0, 1))
    cb   = Colorbar(fig[1, 1][1, 2], hm)
    display(fig)
    return
end

vizme2D()
