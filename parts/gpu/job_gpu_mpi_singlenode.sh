#!/bin/bash
#SBATCH --time=00:05:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --gpus-per-task=1
#SBATCH --constraint=gpu
#SBATCH --account=ntrain1
#SBATCH --output=slurm_gpu_mpi_singlenode.out
#SBATCH --qos=regular

# pin to closest NIC to GPU
export MPICH_OFI_NIC_POLICY=GPU

# Load julia
ml use /global/common/software/nersc/n9/julia/modules
ml julia

mpiexecjl --project julia diffusion_2d_cuda_mpi.jl
