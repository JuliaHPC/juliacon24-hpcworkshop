#!/usr/bin/env sh
#=
$(dirname "$0")/julia_wrapper.sh $0
exit
# =#

@info("Preparing .bashrc")
bashrc = joinpath(ENV["HOME"], ".bashrc")
str = """\n
# --- JULIACON24-HPCWORKSHOP ---
export JULIA_DEPOT_PATH=\$SCRATCH/.julia:/global/common/software/ntrain1/.julia
export PATH=\$SCRATCH/.julia/bin:\$PATH
# auto-load the Julia module
ml use /global/common/software/nersc/n9/julia/modules
ml julia\n
"""
open(bashrc; append=true) do f
    write(f, str)
end
@info("Done!")

@info("Instantiating Julia environment")
empty!(DEPOT_PATH)
push!(DEPOT_PATH, joinpath(ENV["SCRATCH"], ".julia"))
push!(DEPOT_PATH, "/global/common/software/ntrain1/.julia")
using Pkg
Pkg.activate(@__DIR__)
Pkg.instantiate()
@info("Done!")

using MPI
MPI.install_mpiexecjl(force=true)

@info("Installing Jupyter kernel")
Pkg.build("IJulia") # to be safe
using IJulia
IJulia.installkernel("JuliaCon24 HPC Workshop"; env=Dict("JULIA_NUM_THREADS" => "8", "JULIA_PROJECT" => @__DIR__))
@info("Done!")
