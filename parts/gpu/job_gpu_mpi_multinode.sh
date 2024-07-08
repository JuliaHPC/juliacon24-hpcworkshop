#!/bin/bash
#SBATCH --time=00:05:00
#SBATCH --nodes=4
#SBATCH --ntasks-per-node=1
#SBATCH --constraint=gpu
#SBATCH --gpu=4
#SBATCH --account=ntrain1
#SBATCH --output=slurm_gpu_mpi_multinode.out
#SBATCH --qos=regular

# Load julia
ml use /global/common/software/nersc/n9/julia/modules
ml julia

mpiexecjl --project -n 4 julia diffusion_2d_cuda_mpi.jl
