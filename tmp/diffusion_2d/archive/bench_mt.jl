# Script for benchmarking and comparing the multithreaded variants.
# Supposed to be run with 8 threads on an entire (exclusive) compute node.
using ThreadPinning

if Threads.nthreads() != 8
    @warn("This script is supposed to be run with 8 Julia threads.")
end

do_vis = false
do_exec = false

N  = 6144 # finer grid → more memory accesses
nt = 200  # shorter time integration (otherwise we'd have to wait too long 😉)

println("---- N=$N, nt=$nt, SERIAL initialization, STATIC scheduling")
begin
    println("\npinthreads(:cores)")
    pinthreads(:cores)
    include(joinpath(@__DIR__, "diffusion_2d_fun_threads.jl"))
    diffusion_2D(N; do_vis, nt)

    println("\npinthreads(:sockets)")
    pinthreads(:sockets)
    include(joinpath(@__DIR__, "diffusion_2d_fun_threads.jl"))
    diffusion_2D(N; do_vis, nt)

    println("\npinthreads(:numa)")
    pinthreads(:numa)
    include(joinpath(@__DIR__, "diffusion_2d_fun_threads.jl"))
    diffusion_2D(N; do_vis, nt)
end



println("\n\n\n")
println("---- N=$N, nt=$nt, PARALLEL initialization, STATIC scheduling")
begin
    println("\npinthreads(:cores)")
    pinthreads(:cores)
    include(joinpath(@__DIR__, "diffusion_2d_fun_threads_parallelinit.jl"))
    diffusion_2D(N; do_vis, nt)

    println("\npinthreads(:sockets)")
    pinthreads(:sockets)
    include(joinpath(@__DIR__, "diffusion_2d_fun_threads_parallelinit.jl"))
    diffusion_2D(N; do_vis, nt)

    println("\npinthreads(:numa)")
    pinthreads(:numa)
    include(joinpath(@__DIR__, "diffusion_2d_fun_threads_parallelinit.jl"))
    diffusion_2D(N; do_vis, nt)
end



println("\n\n\n")
println("---- N=$N, nt=$nt, PARALLEL initialization, STATIC scheduling, WITH flux arrays (i.e. more memory accesses)")
begin
    println("\npinthreads(:cores)")
    pinthreads(:cores)
    include(joinpath(@__DIR__, "diffusion_2d_fun_threads_parallelinit_flux.jl"))
    diffusion_2D(N; do_vis, nt)

    println("\npinthreads(:sockets)")
    pinthreads(:sockets)
    include(joinpath(@__DIR__, "diffusion_2d_fun_threads_parallelinit_flux.jl"))
    diffusion_2D(N; do_vis, nt)

    println("\npinthreads(:numa)")
    pinthreads(:numa)
    include(joinpath(@__DIR__, "diffusion_2d_fun_threads_parallelinit_flux.jl"))
    diffusion_2D(N; do_vis, nt)
end



println("\n\n\n")
println("---- N=$N, nt=$nt, PARALLEL initialization, DYNAMIC scheduling")
begin
    println("\npinthreads(:cores)")
    pinthreads(:cores)
    include(joinpath(@__DIR__, "diffusion_2d_fun_threads_parallelinit_dynamic.jl"))
    diffusion_2D(N; do_vis, nt)

    println("\npinthreads(:sockets)")
    pinthreads(:sockets)
    include(joinpath(@__DIR__, "diffusion_2d_fun_threads_parallelinit_dynamic.jl"))
    diffusion_2D(N; do_vis, nt)

    println("\npinthreads(:numa)")
    pinthreads(:numa)
    include(joinpath(@__DIR__, "diffusion_2d_fun_threads_parallelinit_dynamic.jl"))
    diffusion_2D(N; do_vis, nt)
end
