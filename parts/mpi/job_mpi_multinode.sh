#!/bin/bash
#SBATCH --time=00:05:00
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=4
#SBATCH --constraint=gpu
#SBATCH --account=ntrain1
#SBATCH --output=slurm_mpi_multinode.out
#SBATCH --qos=regular

# Load julia
ml use /global/common/software/nersc/n9/julia/modules
ml julia

mpiexecjl --project julia -e 'do_save=false; include("diffusion_2d_mpi.jl");' 6144
