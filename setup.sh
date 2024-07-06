#!/usr/bin/env sh
#=
$(dirname "$0")/julia_wrapper.sh $0
exit
# =#

@info("Instantiating Julia environment")
using Pkg
Pkg.activate(@__DIR__)
Pkg.instantiate()
@info("Done!")

using MPI
MPI.install_mpiexecjl(force=true)

@info("Preparing .bashrc")
bashrc = joinpath(ENV["HOME"], ".bashrc")
str = """\n
# --- JULIACON24-HPCWORKSHOP ---
export JULIA_DEPOT_PATH=\$SCRATCH/.julia
export PATH=\$SCRATCH/.julia/bin:\$PATH
# auto-load the Julia module
ml use /global/common/software/nersc/n9/julia/modules
ml julia\n
"""
open(bashrc; append=true) do f
    write(f, str)
end
@info("Done!")