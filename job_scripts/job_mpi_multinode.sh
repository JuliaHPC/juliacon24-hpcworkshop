#!/bin/bash
#SBATCH --time=00:10:00
#SBATCH --nodes=16
#SBATCH --ntasks-per-node=1
#SBATCH --constraint=cpu
#SBATCH --account=nguest
#SBATCH --output=slurm_mpi_multinode.out
#SBATCH --qos=regular

# Load julia
ml use /global/common/software/nersc/n9/julia/modules
ml julia

mpiexecjl --project -n 4 julia --project mpi_multinode.jl
mpiexecjl --project -n 9 julia --project mpi_multinode.jl
mpiexecjl --project -n 16 julia --project mpi_multinode.jl
