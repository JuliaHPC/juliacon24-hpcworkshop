# Script for benchmarking and comparing the multithreaded variants.
# Supposed to be run with 8 threads on an entire (exclusive) compute node.
include(joinpath(@__DIR__, "../Diffusion2D/Diffusion2D.jl"))
using .Diffusion2D
using ThreadPinning

if Threads.nthreads() != 8
    @warn("This script is supposed to be run with 8 Julia threads.")
end

ns  = 6144 # finer grid → more memory accesses
nt  = 200  # shorter time integration (otherwise we'd have to wait too long 😉)
p   = Parameters(; ns, nt)

println("---- ns=$ns, nt=$nt, SERIAL initialization, STATIC scheduling")
let
    variant = Multithreading(; static=true, params=p, do_viz=false)

    println("\npinthreads(:cores)")
    pinthreads(:cores)
    Diffusion2D.run(variant)

    println("\npinthreads(:sockets)")
    pinthreads(:sockets)
    Diffusion2D.run(variant)

    println("\npinthreads(:numa)")
    pinthreads(:numa)
    Diffusion2D.run(variant)
end



println("\n\n\n")
println("---- ns=$ns, nt=$nt, PARALLEL initialization, STATIC scheduling")
let
    variant = Multithreading(; static=true, parallel_init=true, params=p, do_viz=false)

    println("\npinthreads(:cores)")
    pinthreads(:cores)
    Diffusion2D.run(variant)

    println("\npinthreads(:sockets)")
    pinthreads(:sockets)
    Diffusion2D.run(variant)

    println("\npinthreads(:numa)")
    pinthreads(:numa)
    Diffusion2D.run(variant)
end



# println("\n\n\n")
# println("---- ns=$ns, nt=$nt, PARALLEL initialization, STATIC scheduling, WITH flux arrays (i.e. more memory accesses)")
# let
#     println("\npinthreads(:cores)")
#     pinthreads(:cores)
#     include(joinpath(@__DIR__, "diffusion_2d_fun_threads_parallelinit_flux.jl"))
#     diffusion_2D(N; do_vis, nt)

#     println("\npinthreads(:sockets)")
#     pinthreads(:sockets)
#     include(joinpath(@__DIR__, "diffusion_2d_fun_threads_parallelinit_flux.jl"))
#     diffusion_2D(N; do_vis, nt)

#     println("\npinthreads(:numa)")
#     pinthreads(:numa)
#     include(joinpath(@__DIR__, "diffusion_2d_fun_threads_parallelinit_flux.jl"))
#     diffusion_2D(N; do_vis, nt)
# end



println("\n\n\n")
println("---- ns=$ns, nt=$nt, PARALLEL initialization, DYNAMIC scheduling")
let
    variant = Multithreading(; static=false, parallel_init=true, params=p, do_viz=false)

    println("\npinthreads(:cores)")
    pinthreads(:cores)
    Diffusion2D.run(variant)

    println("\npinthreads(:sockets)")
    pinthreads(:sockets)
    Diffusion2D.run(variant)

    println("\npinthreads(:numa)")
    pinthreads(:numa)
    Diffusion2D.run(variant)
end
