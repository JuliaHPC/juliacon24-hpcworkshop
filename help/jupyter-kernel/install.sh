#!/usr/bin/env bash

kernel_dir=${HOME}/.local/share/jupyter/kernels
mkdir -p $kernel_dir
cp -r  /global/cfs/cdirs/nstaff/blaschke/olcf_nersc_24/julia-tutorial $kernel_dir
