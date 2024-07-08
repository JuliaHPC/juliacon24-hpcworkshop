#!/bin/bash
#SBATCH --time=00:05:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=256
#SBATCH --constraint=gpu
#SBATCH --gpu=1
#SBATCH --account=ntrain1
#SBATCH --output=slurm_bench_gpu.out

# Load julia
ml use /global/common/software/nersc/n9/julia/modules
ml julia

for i in 512 2048 4096 8192 16384
do
    echo -e "\n\n#### GPU run $i"

    julia --project -e 'do_visualize=false; include("diffusion_2d_cuda.jl")' $i
done
