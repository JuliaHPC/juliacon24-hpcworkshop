#!/bin/bash
#SBATCH --time=00:05:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=256
#SBATCH --constraint=cpu
#SBATCH --account=nguest
#SBATCH --output=slurm_bench_mt.out

# Load julia
ml use /global/common/software/nersc/n9/julia/modules
ml julia

julia --project --threads 8 bench_mt.jl