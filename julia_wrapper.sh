#!/bin/bash

# Load julia
ml use /global/common/software/nersc/n9/julia/modules
ml julia

# Pass on all arguments to julia
exec julia "${@}"