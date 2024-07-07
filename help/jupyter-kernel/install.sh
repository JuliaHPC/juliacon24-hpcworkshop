#!/usr/bin/env bash

kernel_dir=${HOME}/.local/share/jupyter/kernels
mkdir -p $kernel_dir
cp -r  ${SCRATCH}/juliacon24-hpcworkshop/help/jupyter-kernel/julia-tutorial $kernel_dir
