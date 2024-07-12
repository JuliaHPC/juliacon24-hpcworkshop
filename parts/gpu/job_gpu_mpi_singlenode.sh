#!/bin/bash

#SBATCH -A ntrain1
#SBATCH -C gpu
#SBATCH -q regular
#SBATCH --output=slurm_gpu_mpi_singlenode.out
#SBATCH --time=00:05:00
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --gpus-per-node=4
#SBATCH --exclusive
#SBATCH --gpu-bind=none

# pin to closest NIC to GPU
export MPICH_OFI_NIC_POLICY=GPU

# default to std memory pool, see: https://juliaparallel.org/MPI.jl/stable/knownissues/#Memory-pool
export JULIA_CUDA_MEMORY_POOL=none

ml use /global/common/software/nersc/n9/julia/modules
ml julia

mpiexecjl --project=../.. julia diffusion_2d_cuda_mpi.jl
