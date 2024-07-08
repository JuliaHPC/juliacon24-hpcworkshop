# 2D Linear Diffusion Solver

In this part, we introduce the Diffusion 2D example we will use throughout the workshop to exemplify various HPC concepts in Julia, namely:
- [Multithreading](./../multithreading/)
- [Distributed computing](./../mpi/)
- [GPU acceleration](./../gpu/)

The script [`diffusion_d2.jl`](./diffusion_2d.jl) provides the starting point; a vectorised 2D linear diffusion solver computing diffusive fluxes and their divergence in a `compute_flux!` and `diffusion_step!` function, respectively.

The follow-up script, [`diffusion_d2_loop.jl`](./diffusion_2d_loop.jl), implements a serial loop version of the previous script that we will use as a starting point for all our further experiments.

## Warm-up Task - running 2D diffusion

Your very first task is to get familiar with the script structure and output generated. Run the [`diffusion_2d-jl`](diffusion_2d.jl) script, verifying that plotting works and assess the reported effective memory throughput `T_eff` (in the REPL).

Repeat the same for the [`diffusion_2d_loop.jl`](diffusion_2d_loop.jl) script.
