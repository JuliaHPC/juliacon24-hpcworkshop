# 2D linear diffusion solver - GPU cuda version
using Printf
using JLD2
using CUDA
include(joinpath(@__DIR__, "../shared.jl"))

# convenience macros simply to avoid writing nested finite-difference expression
macro qx(ix, iy) esc(:(-D * (C[$ix+1, $iy] - C[$ix, $iy]) * inv(ds))) end
macro qy(ix, iy) esc(:(-D * (C[$ix, $iy+1] - C[$ix, $iy]) * inv(ds))) end

function diffusion_step_kernel!(params, C2, C)
    (; ds, dt, D) = params
    #
    # !! TODO !!
    #
    # We want to replace the nested loop over spatial dimensions by "vecotized" CUDA indices.
    # Based off of the serial kernel (see README.md or diffusion_2d_loop.jl) implement
    # the CUDA variant using CUDA.jl taking care the handle to range in an appropriate
    # manner (see "TODO..." below).
    #
    ix = # TODO  # CUDA vectorised unique index
    iy = # TODO  # CUDA vectorised unique index
    if # TODO select correct range
        @inbounds C2[ix+1, iy+1] = C[ix+1, iy+1] - dt * ((@qx(ix + 1, iy + 1) - @qx(ix, iy + 1)) * inv(ds) +
                                                         (@qy(ix + 1, iy + 1) - @qy(ix + 1, iy)) * inv(ds))
    end
    return nothing
end

function diffusion_step!(params, C2, C)
    (; nthreads, nblocks) = params
    #
    # !! TODO !!
    #
    # Complete the CPU wrapper function calling the `diffusion_step_kernel!`
    # using the `@cuda` macro and appropriate launch parameters (see "TODO..." below).
    #
    @cuda # TODO
    return nothing
end

function run_diffusion(; ns=64, nt=100, do_save=false)
    params   = init_params_gpu(; ns, nt, do_save)
    C, C2    = init_arrays_gpu(params)
    t_tic = 0.0
    # Time loop
    for it in 1:nt
        # time after warmup (ignore first 10 iterations)
        (it == 11) && (t_tic = Base.time())
        # diffusion
        diffusion_step!(params, C2, C)
        C, C2 = C2, C # pointer swap
    end
    # synchronize the gpu before querying the final time
    # TODO # Add synchronization
    t_toc = (Base.time() - t_tic)
    print_perf(params, t_toc)
    do_save && jldsave(joinpath(@__DIR__, "out_gpu.jld2"); C = Array(C), l = params.L)
    return nothing
end

# Running things...

# enable visualization by default
(!@isdefined do_save) && (do_save = true)
# enable execution by default
(!@isdefined do_run) && (do_run = true)

if do_run
    if !isempty(ARGS)
        run_diffusion(; ns=parse(Int, ARGS[1]), do_save)
    else
        run_diffusion(; ns=256, do_save)
    end
end
