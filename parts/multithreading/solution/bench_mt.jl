# Script for benchmarking and comparing the multithreaded variants.
# Supposed to be run with 8 threads on an entire (exclusive) compute node.
using ThreadPinning

if Threads.nthreads() != 8
    @warn("This script is supposed to be run with 8 Julia threads.")
end

codefile = joinpath(@__DIR__, "../diffusion_2d_threads.jl")
include(codefile)

do_visualize = false
do_run = false
ns  = 6144 # finer grid → more memory accesses
nt  = 200  # shorter time integration (otherwise we'd have to wait too long 😉)

println("---- ns=$ns, nt=$nt, SERIAL initialization, STATIC scheduling")
let
    println("\npinthreads(:cores)")
    pinthreads(:cores)
    run_diffusion(; ns, nt, do_visualize, parallel_init=false, static=true)

    println("\npinthreads(:sockets)")
    pinthreads(:sockets)
    run_diffusion(; ns, nt, do_visualize, parallel_init=false, static=true)

    println("\npinthreads(:numa)")
    pinthreads(:numa)
    run_diffusion(; ns, nt, do_visualize, parallel_init=false, static=true)
end



println("\n\n\n")
println("---- ns=$ns, nt=$nt, PARALLEL initialization, STATIC scheduling")
let
    println("\npinthreads(:cores)")
    pinthreads(:cores)
    run_diffusion(; ns, nt, do_visualize, parallel_init=true, static=true)

    println("\npinthreads(:sockets)")
    pinthreads(:sockets)
    run_diffusion(; ns, nt, do_visualize, parallel_init=true, static=true)

    println("\npinthreads(:numa)")
    pinthreads(:numa)
    run_diffusion(; ns, nt, do_visualize, parallel_init=true, static=true)
end



println("\n\n\n")
println("---- ns=$ns, nt=$nt, PARALLEL initialization, DYNAMIC scheduling")
let
    println("\npinthreads(:cores)")
    pinthreads(:cores)
    run_diffusion(; ns, nt, do_visualize, parallel_init=true, static=false)

    println("\npinthreads(:sockets)")
    pinthreads(:sockets)
    run_diffusion(; ns, nt, do_visualize, parallel_init=true, static=false)

    println("\npinthreads(:numa)")
    pinthreads(:numa)
    run_diffusion(; ns, nt, do_visualize, parallel_init=true, static=false)
end
