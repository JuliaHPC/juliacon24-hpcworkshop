## Perlmutter Cheatsheet

#### Login (Terminal)
```bash
ssh trainXY@perlmutter.nersc.gov
```

To get Julia (if not auto-loaded in your `.bashrc`):

```bash
ml use /global/common/software/nersc/n9/julia/modules
ml julia
```

Afterwards, the `julia` command is available.

### Getting a compute node

#### Interactive

##### CPU
```bash
salloc --nodes 1 --qos interactive --time 01:00:00 --constraint cpu --account=ntrain
```
(see the file `cpunode.sh` which you can simply run with `sh cpunode.sh`)

##### GPU
```bash
salloc --nodes 1 --qos interactive --time 01:00:00 --constraint gpu --gpus 4 --account=ntrain
```
(see the file `gpunode.sh` which you can simply run with `sh gpunode.sh`)

#### Job scripts

##### CPU (full node)
```bash
#!/bin/bash
#SBATCH --time=00:05:00
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=256
#SBATCH --constraint=cpu
#SBATCH --account=ntrain

# Load julia
ml use /global/common/software/nersc/n9/julia/modules
ml julia

julia --project --threads 8 whatever.jl
```

##### MPI

**If you want more than 8 nodes, you need to specify `#SBATCH --qos=regular`.**

```bash
#!/bin/bash
#SBATCH --time=00:10:00
#SBATCH --nodes=9
#SBATCH --ntasks-per-node=1
#SBATCH --constraint=cpu
#SBATCH --account=ntrain
#SBATCH --qos=regular

# Load julia
ml use /global/common/software/nersc/n9/julia/modules
ml julia

mpiexecjl --project -n 9 julia mpicode.jl
```
