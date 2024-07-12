#!/bin/bash

#SBATCH -A ntrain1
#SBATCH -C cpu
#SBATCH -q regular
#SBATCH --output=slurm_mpi_singlenode.out
#SBATCH --time=00:05:00
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --exclusive

ml use /global/common/software/nersc/n9/julia/modules
ml julia

mpiexecjl --project=../.. julia diffusion_2d_mpi.jl
