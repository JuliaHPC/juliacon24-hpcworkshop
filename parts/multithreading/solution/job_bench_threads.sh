#!/bin/bash
#SBATCH --time=00:05:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=256
#SBATCH --constraint=cpu
#SBATCH --account=ntrain1
#SBATCH --output=slurm_bench_threads.out

# Load julia
ml use /global/common/software/nersc/n9/julia/modules
ml julia

for i in 512 2048 6144
do
    echo -e "\n\n#### Run $i"

    echo -e "-- single threaded"
    julia --project --threads 1 -e 'do_visualize=false; include("diffusion_2d_threads.jl")' $i
    echo -e ""

    julia --project --threads 8 bench_threads.jl $i # benchmark multithreaded variants
done