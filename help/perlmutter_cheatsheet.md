## Perlmutter Cheatsheet

### Login

#### VS Code

1) In VS Code, press `F1` and run the `Remote-SSH: Open SSH Host...` command.
2) Enter `trainXY@perlmutter.nersc.gov` (with `trainXY` replaced by your training account) and press enter.
3) In the popup input box, enter your password and press enter.

To make the Julia extension work, you have to do a few steps **once**. Please find them [here](vscode_julia_on_perlmutter.md#making-the-julia-extension-work).

#### Terminal
```bash
ssh trainXY@perlmutter.nersc.gov
```

To get Julia:

```bash
ml use /global/common/software/nersc/n9/julia/modules
ml julia
```

Afterwards, the `julia` command is available.

#### Jupyter

https://jupyter.nersc.gov/

### Getting a compute node

#### Interactive

##### CPU
```bash
salloc --nodes 1 --qos interactive --time 02:00:00 --constraint cpu --account=ntrain
```

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