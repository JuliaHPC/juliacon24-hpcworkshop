# Diffusion 2D - Multithreading

In this part, we want to use multithreading (shared-memory parallelism) to parallelize our Diffusion 2D example.

The starting point is the serial loop version [`diffusion_2d_loop.jl`](./../diffusion_2d/diffusion_2d_loop.jl). The file [`diffusion_2d_threads.jl`](./diffusion_2d_threads.jl) in this folder is a slightly modified copy of this version. Specifically, we included the serial initialization of the arrays `C` and `C2` in form of the function `init_arrays_threads` and left the computational kernel (`diffusion_step!`) mostly unimplemented. Note that there are few code stubs (indicated by `TODO` comments) that you will implement in the tasks below.

## Task 1 - Multithreading `diffusion_step!`

### Part A

Your first task is to take the diffusion kernel from `diffusion_2d_loop.jl` - recited below for your convenience - and use `@threads` to parallelize it. See the `TODO` comments inside of the `diffusion_step!` function.

You shall implement two variants, one that uses static scheduling and another that uses dynamic scheduling. A variable `static` will be used to switch between the two cases .

(To test the correctness of your implementation, you can do an "eye test" and just look at the resulting plots.)

**Question:**
* Should you parallelize the inner or the outer loop?
    * (You can try both and compare the two in terms of performance if you are unsure.)

**Serial kernel from diffusion_2d_loop.jl:**
```julia
for iy in 1:size(C, 2)-2
    for ix in 1:size(C, 1)-2
        @inbounds C2[ix+1, iy+1] = C[ix+1, iy+1] - dt * ((@qx(ix+1, iy+1) - @qx(ix, iy+1)) / ds +
                                                         (@qy(ix+1, iy+1) - @qy(ix+1, iy)) / ds)
    end
end
```

### Part B

Let's make a first rough performance comparison. Run your implementation using 8 Julia threads and using 1 Julia thread and compare the timings/`T_eff` ("strong scaling"). Perform this comparison for three values of `ns`, for example 512, 2048, and 6144.

Note that you don't have to implement the other `TODO`s in the file. The code should run just fine if you've implemented `diffusion_step!`.

**How to run the code?**

You can either perform the rough benchmark in an interactive Julia session or use the script `job_compare_threads_serial.sh`.

* Interactive:
  * Set `do_visualize=false`.
  * Use `include("diffusion_2d_threads.jl")` to run the code.

* Script::
  * Either just run the script on the current node (`sh job_compare_threads_serial.sh`) or submit it as a job to SLURM (`sbatch job_compare_threads_serial.sh`). In the latter case, the output will end up in a file called `slurm_compare_threads_serial.out`.

**Questions:**
* What do you observe?
* Are you happy with the performance improvement?
  * Consider taking ratios of the timings (i.e. $t_{serial}$ / $t_{parallel}$) and compare it to 8 (naively anticipating perfect scaling).

## Task 2 - Parallel initialization and thread pinning

As has been stated before the hands-on, how we pin the Julia threads and how/whether we initialize the data (`C`, `C2`) in serial or parallel can heavily influence the performance of our code. Let's put this to the test!

### Part A

Go ahead and parallelize the initialization of `C` and `C2` in the function `init_arrays_threads` (see the `TODO`s therein) in the same way as you've parallelized the kernel in `diffusion_step!` above.

The variable `parallel_init` (`true` or `false`) is used to switch between parallel and serial initialization. Similarly, the variable `static` (`true` or `false`) is used to switch between static and dynamic scheduling.

(To test the correctness of your implementation, you can do an "eye test" and just look at the resulting plots.)

### Part B

Now, we want to systematically compare the performance of our code for
* different combinations of `parallel_init` and `static`,
* different values of `ns` (512, 2048, and 6144), and
* different pinning schemes (`:cores`, `:sockets`, `:numa`)

While you are more than invited to play around with these degrees of freedom in an interactive Julia session running on a **compute node**, this will likely become rather cumbersome very quickly.
(We still invite you to play around a little bit with ThreadPinning's `threadinfo` and `pinthreads`!)

To simplify things, we've prepared the script `job_bench_threads.sh` for you, which you can simply submit to SLURM (`sbatch job_bench_threads.sh`). The output will end up in the file `slurm_bench_threads.out`.

**Questions:**
* First, compare the `static=true` results with increasing `ns` (that is, ignore the dynamic scheduling runs for now). Can you qualitatively explain the performance difference/similarity between the three pinning strategies? And maybe also why it changes with increasing `ns`?
* Why does dynamic scheduling (most of the time) give worse performance than static scheduling?
* The output also shows single-threaded timings. Consider the timing ratio ($t_{serial}$ / $t_{parallel}$) for the best performing cases. Is it an improvement over what you found above (i.e. closer to a factor of 8)?
