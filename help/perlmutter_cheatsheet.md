# Perlmutter Cheatsheet

## Managing jobs

### Submitting a job
`sbatch job_script.sh`

### List your submitted jobs
`squeue -u trainXY`, where `trainXY` is your account name.

Tip: `watch -n 1 'squeue -u trainXY'`

### Canceling a job

`scancel <jobid>` where `<jobid>` is the id of the job (can be found with `squeue`, see above).

## Interactive sessions on compute nodes

### CPU
```bash
salloc --nodes 1 --qos interactive --time 01:00:00 --constraint cpu --account=ntrain1
```
(see the file `cpunode.sh` which you can simply run with `sh cpunode.sh`)

### GPU
```bash
salloc --nodes 1 --qos interactive --time 01:00:00 --constraint gpu --gpus 4 --account=ntrain1
```
(see the file `gpunode.sh` which you can simply run with `sh gpunode.sh`)

## Examplatory job scripts

### CPU (full node)
```bash
#!/bin/bash
#SBATCH --time=00:05:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=256
#SBATCH --constraint=cpu
#SBATCH --account=ntrain1

# Load julia
ml use /global/common/software/nersc/n9/julia/modules
ml julia

julia --project --threads 8 whatever.jl
```

### MPI

* "tasks" in SLURM correspond to MPI ranks
* **If you want more than 8 nodes, you need to specify `#SBATCH --qos=regular`.**

```bash
#!/bin/bash
#SBATCH --time=00:10:00
#SBATCH --nodes=9
#SBATCH --ntasks-per-node=1
#SBATCH --constraint=cpu
#SBATCH --account=ntrain1
#SBATCH --qos=regular

# Load julia
ml use /global/common/software/nersc/n9/julia/modules
ml julia

mpiexecjl --project -n 9 julia mpicode.jl
```
