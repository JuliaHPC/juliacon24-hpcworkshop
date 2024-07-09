#!/bin/bash

# Making module / ml available
# ------------------------------------------------------------
export MODULEPATH=/global/common/software/nersc/n9/julia/modules:/opt/cray/pe/lmod/modulefiles/perftools/23.12.0:/opt/cray/pe/lmod/modulefiles/comnet/gnu/12.0/ofi/1.0:/opt/cray/pe/lmod/modulefiles/mix_compilers:/opt/cray/pe/lmod/modulefiles/compiler/gnu/12.0:/opt/cray/pe/lmod/modulefiles/mpi/gnu/12.0/ofi/1.0/cray-mpich/8.0:/opt/cray/pe/lmod/modulefiles/net/ofi/1.0:/opt/cray/pe/lmod/modulefiles/cpu/x86-milan/1.0:/opt/cray/pe/modulefiles/Linux:/opt/cray/pe/modulefiles/Core:/opt/cray/pe/lmod/lmod/modulefiles/Core:/opt/cray/pe/lmod/modulefiles/core:/opt/cray/pe/lmod/modulefiles/craype-targets/default:/global/common/software/nersc/pe/modulefiles_hotfixes:/opt/nersc/pe/modulefiles:/usr/share/lmod/lmod/modulefiles/Core:/opt/cray/modulefiles
source /usr/share/lmod/lmod/init/profile
export LMOD_SYSTEM_DEFAULT_MODULES=craype-x86-milan:craype-network-ofi:perftools-base:xpmem:PrgEnv-gnu:cpe:gpu
module --initial_load restore
# ------------------------------------------------------------

# Load julia
ml use /global/common/software/nersc/n9/julia/modules
ml julia

# Pass on all arguments to julia
exec julia "${@}"