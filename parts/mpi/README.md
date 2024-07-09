# Diffusion 2D - MPI

In this part, we want to use MPI (distributed parallelism) to parallelize our Diffusion 2D example.

The starting point is (once again) the serial loop version [`diffusion_2d_loop.jl`](./../diffusion_2d/diffusion_2d_loop.jl). The file [`diffusion_2d_mpi.jl`](./diffusion_2d_mpi.jl) in this folder is a modified copy of this variant. While the computational kernel `diffusion_step!` is essentially untouched, we included MPI bits at the beginning of the `run_diffusion` function and introduced the key function `update_halo!`, which is supposed to take care of data exchange between MPI ranks. However, as of now, the function isn't communicating anything and it will be (one of) your tasks to fix that 😉.

General information: **Use 4 MPI ranks (→ 2x2 grid) unless the task tells you otherwise!**

## Task 1 - Running the MPI code

Although incomplete from a semantic point of view, the code in `diffusion_2d_mpi.jl` is perfectly runnable as is. It won't compute the right thing, but it runs 😉. So **let's run it**, but how?

First thing to realize is that, on Perlmutter, **you can't run MPI on a login node**. You have two options to work on a compute node:

1) **Interactive session**: You can try to get an interactive session on a compute node by running `sh get_compute_node_interactive.sh`. But unfortunately, we don't have a node for everyone, so you might not get one (Sorry!). **If you can get one**, you can use `mpiexecjl --project -n 4 julia diffusion_2d_mpi.jl` to run the code. Alternatively, you can run `sh job_mpi_singlenode.sh`.

2) **Compute job**: You can always submit a job that runs the code: `sbatch job_mpi_singlenode.sh`. The output will land in `slurm_mpi_singlenode.out`. Check out the [Perlmutter cheetsheet](../../help/perlmutter_cheatsheet.md) to learn more about jobs.

Irrespective of which option you choose, **go ahead an run the code**.

To see that the code is currently not working properly (in the sense of computing the right thing), run `julia --project visualize_mpi.jl` to combine the results of different MPI ranks (`*.jld2` files) into a visualization (`visualization.png`). Inspect the visualization and notice the undesired dark lines.

## Task 2 - Halo exchange

Take a look at the general MPI setup (the beginning of `run_diffusion`) and the `update_halo!` function (the bits that are already there) and try to understand it.

Afterwards, implement the necessary MPI communication. To that end, find the "TODO" block in `update_halo!` and follow the instructions. Note that we want to use **non-blocking** communication, i.e. you should use the functions `MPI.Irecv` and `MPI.Isend`.

Check that your code is working by comparing the `visualization.png` that you get to this (basic "eye test"):

<img src="./solution/visualization.png" width=500px>


TODO.... performance, scaling.