#!/bin/bash

# Load julia
ml use /global/common/software/nersc/n9/julia/modules
ml julia

# Set depot path (only for the workshop)
export JULIA_DEPOT_PATH=$SCRATCH/.julia:/global/common/software/ntrain1/.julia

# Pass on all arguments to julia
exec julia "${@}"
