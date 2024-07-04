#!/bin/bash
#SBATCH --time=00:05:00
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=1
#SBATCH --constraint=cpu
#SBATCH --account=ntrain
#SBATCH --output=slurm_mpi_multinode.out
#SBATCH --qos=regular

# Load julia
ml use /global/common/software/nersc/n9/julia/modules
ml julia

mpiexecjl --project -n 4 julia diffusion_2d_mpi.jl
