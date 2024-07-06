# Script for benchmarking and comparing the multithreaded variants.
#   - Supposed to be run on an entire (exclusive) compute node.
#   - Takes `ns` as (the only) input argument.
#
using ThreadPinning

do_visualize = false
do_run = false
codefile = joinpath(@__DIR__, "diffusion_2d_threads.jl")
include(codefile)

ns  = parse(Int, ARGS[1])
nt  = 100

println("-- ns=$ns, nt=$nt, SERIAL initialization, STATIC scheduling")
for pin in (:cores, :sockets, :numa)
    println("pinthreads($pin)")
    pinthreads(pin)
    run_diffusion(; ns, nt, do_visualize, parallel_init=false, static=true)
end

println("\n-- ns=$ns, nt=$nt, PARALLEL initialization, STATIC scheduling")
for pin in (:cores, :sockets, :numa)
    println("pinthreads($pin)")
    pinthreads(pin)
    run_diffusion(; ns, nt, do_visualize, parallel_init=true, static=true)
end

println("\n-- ns=$ns, nt=$nt, PARALLEL initialization, DYNAMIC scheduling")
for pin in (:cores, :sockets, :numa)
    println("pinthreads($pin)")
    pinthreads(pin)
    run_diffusion(; ns, nt, do_visualize, parallel_init=true, static=false)
end
