#!/usr/bin/env bash

module load PrgEnv-gnu
module load cray-hdf5-parallel
module load python

module use /global/common/software/nersc/julia_hpc_24/modules/
module use /global/common/software/nersc/n9/julia/modules/
module load adios2 julia

readarray -t ijulia_boostrap < <(julia /global/cfs/cdirs/nstaff/blaschke/julia/kernels/bootstrap.jl)

echo "Check-and-install returned following output:"
_IFS=$IFS
IFS=$'\n'
for each in ${ijulia_boostrap[*]}
do
    echo $each
done
IFS=$_IFS

JULIA_EXEC=$(which julia)
KERNEL="${ijulia_boostrap[-1]}"
JULIA_NUM_THREADS=8

echo "Connecting using JULIA_EXEC=$JULIA_EXEC and KERNEL=$KERNEL"
exec $JULIA_EXEC -i --startup-file=yes --color=yes $KERNEL "$@"
