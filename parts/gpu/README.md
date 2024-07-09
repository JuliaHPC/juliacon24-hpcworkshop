# Diffusion 2D - GPU acceleration

In this part, we want to use GPU computing and multi-GPUs (distributed memory parallelization) to accelerate our Diffusion 2D example.

The starting point is the serial loop version [`diffusion_2d_loop.jl`](./../diffusion_2d/diffusion_2d_loop.jl). The file [`diffusion_2d_cuda.jl`](./diffusion_2d_cuda.jl) in this folder is a slightly modified copy of this version. Specifically, we included the gpu initialization of the arrays `C` and `C2` in form of the function `init_arrays_gpu` and left the computational kernel (`diffusion_step_kernel!`) and the wrapper function (`diffusion_step!`) mostly unimplemented.

In a second step, we will merge the CUDA and MPI codes in order to achieve a multi-GPU diffusion solver. For this task, the starting point is the [`diffusion_2d_mpi.jl`](./../mpi/diffusion_2d_mpi.jl) script. The file [`diffusion_2d_cuda_mpi.jl`](./diffusion_2d_cuda_mpi.jl) in this folder is a slightly modified copy of this version. Specifically, we included the gpu mpi initialization of the arrays `C` and `C2` in form of the function `init_arrays_gpu_mpi` and left the `update_halo!` and `init_bufs` functions mostly unimplemented. We also did not yet implement the GPU selection from local MPI rank.

Note that there are few code stubs (indicated by `TODO` comments) that you will implement in the tasks below.

Recall that on the GPU, you need to explicitly specify the data type to be `Float64` as CUDA.jl defaults to `Float32`.

## Reminder

Remember that, on Perlmutter, **you can't run GPU or MPI processes on a login node**. You have two options to work on a compute node:

1) **Interactive session**: You can try to get an interactive session on a compute node by running `sh get_gpu_compute_node_interactive.sh` (but unfortunately, we don't have a node for everyone). **If you can get one**, you can:
    - single GPU script: launch Julia from the interactive session and run the single GPU script. Alternatively, you can run `sh job_bench_gpu.sh`.
    - multi-GPU: run the GPU MPI code by `mpiexecjl --project -n 4 julia diffusion_2d_cuda_mpi.jl`. Alternatively, you can run `sh job_gpu_mpi_singlenode.sh`.

2) **Compute job**: You can always submit a job that runs the code: `sbatch job_gpu_mpi_singlenode.sh`. The output will land in `slurm_gpu_mpi_singlenode.out`. Check out the [Perlmutter cheetsheet](../../help/perlmutter_cheatsheet.md) to learn more about jobs.

## Task 1 - CUDA `diffusion_step_kernel!`

### Part A

Your first task is to take the diffusion kernel from `diffusion_2d_loop.jl` and replace the nested loop over spatial dimensions by "vecotized" CUDA indices. See the `TODO` comments inside of the `diffusion_step_kernel!` function. Make sure to correctly handle the ranges where the computation should occur given that we do not want to update the boundary cells of `C2` array.

Then you should complete the wrapper function `diffusion_step!` we are using the call the GPU kernel (which allows us to have the same function call signature in the `run_diffusion` function). Use the appropriate CUDA launch parameters.

Note that the number of threads and blocks used to execute the kernel is defined in `init_params_gpu` from [`shared.jl`](./../shared.jl) as:
```julia
nthreads = 32, 8              # number of threads per block
nblocks  = cld.(ns, nthreads) # number of blocks
```

**Question:**
* How did you implement the appropriate range selection?

### Part B

Let's make a rough performance benchmark. Run your implementation on a single Nvidia A100 GPU and compare timings/`T_eff` ("strong scaling"). Perform this comparison for five values of `ns`, for example 512, 2048, 4096, 8192 and 16384.

**How to run the code?**

You can either perform the rough benchmark in an interactive Julia session or use the script `job_bench_gpu.sh`.

* Interactive:
  * Set `do_visualize=false`.
  * Use `include("diffusion_2d_cuda.jl")` to run the code.

* Script:
  * Either just run the script on the current node (`sh job_bench_gpu.sh`) or submit it as a job to SLURM (`sbatch job_bench_gpu.sh`). In the latter case, the output will end up in a file called `slurm_bench_gpu.out`.

**Questions:**
* What do you observe?
* What about the performance as function of `ns`?
  * How does it compare to peak memory throughput of the Nvidia A100 (memcopy only)?

## Task 2 - Multi-GPUs

In this second task, we will see how to combine GPUs and MPI in order to achieve distributed memory parallelization on multiple GPUs. This step is the gateway to run Julia at scale on latest GPU-accelerated supercomputers such as NERSC's Perlmutter.

We will first make the required changes to the code (Part A), test our implementation (Part B) and perform a weak scaling test (Part C).

### Part A

Complete the `update_halo!` and `init_bufs` functions taking inspiration from the CPU MPI script and making sure to use the the correct data type for the GPU buffers (see the `TODO`s therein).

Then, in the `run_diffusion` function, we need to implement a procedure to map the GPUs from each node to MPI processes running on that same node. There are various ways to achieve this. We will here use an MPI shared memory communicator to detect all ranks on the same node:
1. We can use `MPI.Comm_split_type(comm, MPI.COMM_TYPE_SHARED, me)` from MPI.jl passing the existing communicator `comm` and the global rank `me` to retrieve the node-local communicator `comm_l`.
2. We then need to retrieve the rank from `comm_l` which will give us the node local rank `me_l`.
3. We can then use to select the GPU device upon `gpu_id = CUDA.device!(me_l)`.

### Part B

We will now run the GPU MPI code on a single node using all 4 A100 Nvidia GPUs on that node and assess whether the GPU selection works and asses the correctness of the implementation doing an "eye test" looking at the plotting results.

**How to run the code?**

You can run the GPU MPI script using the script `job_bench_gpu_mpi_singlenode.sh`, submitting it as a job to SLURM (`sbatch job_bench_gpu_mpi_singlenode.sh`). The output will end up in a file called `slurm_bench_gpu_mpi.out`.

Then, try running the same job but this time on 4 nodes, using 1 GPU per node. You can achieve this by using the `job_bench_gpu_mpi_multinode.sh` script we prepared for you.

**How to visualize the results?**

The code will save one output file per rank, having hte rank ID in the filename such as `out_$(me).jld2`.

You can run the [`visualize_mpi.jl`](./visualize_mpi.jl) script in order to visualise the results. The visualization script defines the `vizme2D_mpi(nprocs)` function, which takes `nprocs` as argument, defualting to `(2, 2)`, our default MPI topology.

**Questions:**
* Do you observe correct diffusion results, for both the singlenode and multinode configurations?
  * Is each MPI rank accessing a different GPU from that node?

### Part C

As a last step, we will realize a weak scaling to assess the parallel efficiency of our implementation. For this we should set the spatial resolution `ns` to the value that was showing best performance in the strong scaling experiment from Task 1, possibly adapting `nt` such that the code executes not much longer than 1 second and setting `do_save = false`.

Then one should run the GPU MPI script on one MPI rank (thus one GPU) in order to assess the baseline performance. Once this is done, one should increase the number of MPI ranks, while keeping the same local problem size, making the global problem scale linearly with the computing resources. Performance tests could be achieved for 1, 4, 9, 16, (64) ranks. Parallel efficiency can be reported by normalising the $T_\mathrm{eff}$ or wall-time obtained for tests > 1 rank by the single rank performance.

**Questions:**
* What parallel efficiency do you observe?
  * If it drops, what workaround could one implement?
