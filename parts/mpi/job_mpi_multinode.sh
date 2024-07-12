#!/bin/bash

#SBATCH -A ntrain1
#SBATCH -C cpu
#SBATCH -q regular
#SBATCH --output=slurm_mpi_multinode.out
#SBATCH --time=00:05:00
#SBATCH --nodes=4
#SBATCH --ntasks=16
#SBATCH --exclusive

ml use /global/common/software/nersc/n9/julia/modules
ml julia

mpiexecjl --project=../.. julia -e 'do_save=false; include("diffusion_2d_mpi.jl");'
