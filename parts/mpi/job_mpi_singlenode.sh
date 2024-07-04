#!/bin/bash
#SBATCH --time=00:05:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --constraint=cpu
#SBATCH --account=ntrain1
#SBATCH --output=slurm_mpi_singlenode.out

# Load julia
ml use /global/common/software/nersc/n9/julia/modules
ml julia

mpiexecjl --project -n 4 julia --threads 1 diffusion_2d_mpi.jl
