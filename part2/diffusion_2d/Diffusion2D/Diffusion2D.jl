"2D linear diffusion solver"
module Diffusion2D

using Printf
using CairoMakie

Base.@kwdef struct Parameters
    # physical parameters
    L::Float64 = 10.0               # physical length
    D::Float64 = 1.0                # diffusion constant
    ns::Int64 = 64                  # number of spacial grid points (along one dimension)
    nt::Int64 = 10 * ns             # number of timesteps
    ds::Float64 = L / ns            # delta between neighboring grid points
    dt::Float64 = ds^2 / (D * 8.2)  # delta between neighboring time points
end

abstract type AbstractImplementation end

Base.@kwdef struct Multithreading <: AbstractImplementation
    parallel_init::Bool = false
    static::Bool = false
    params::Parameters = Parameters()
    do_viz::Bool = true
    nout::Int64 = floor(Int, params.nt / 5)
end

Base.@kwdef struct SerialLoop <: AbstractImplementation
    params::Parameters = Parameters()
    do_viz::Bool = true
    nout::Int64 = floor(Int, params.nt / 5)
end

Base.@kwdef struct SerialVectorized <: AbstractImplementation
    params::Parameters = Parameters()
    do_viz::Bool = true
    nout::Int64 = floor(Int, params.nt / 5)
end

include("shared.jl")
include("serial_vectorized.jl")
include("serial_loop.jl")
include("multithreading.jl")

export Parameters,
       AbstractImplementation,
       Multithreading,
       SerialLoop,
       SerialVectorized,
       run

end # module
