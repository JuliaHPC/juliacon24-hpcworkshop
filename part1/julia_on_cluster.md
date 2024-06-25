# Working with Julia on HPC Clusters

## Getting Started

### Use the regular Julia binaries

* [juliaup](https://github.com/JuliaLang/juliaup) or download from [julialang.org](https://julialang.org/downloads/).
* Is there a Julia module on the cluster available?
  * Example: Binaries + system MPI + MPI.jl preferences
  * More information for admins: [Julia On HPC Clusters](https://juliahpc.github.io/JuliaOnHPCClusters/sysadmin_julia/)
* Compiling Julia from source?
  * Generally unnecessary.
  * Can be required for certain profiling, though.

### Set [`JULIA_DEPOT_PATH`](https://docs.julialang.org/en/v1/manual/environment-variables/#JULIA_DEPOT_PATH) appropriately

**Rule of thumb:** Put Julia on the parallel file system (PFS), which is often called "*scratch*".

**Why?**
* `$HOME` typically has rather tight quotas
* `$HOME` may be read-only within compute jobs
* `$HOME` might be backed up (unnecessarily)

**Watch out:** Files on the PFS ("*scratch*") may be deleted automatically after a certain time period. (Pro tip: `touch` the files recursively every once in a while, e.g. in a cron job, to circumvent deletion 😉).

### (On heterogeneous clusters: [`JULIA_CPU_TARGET`](https://docs.julialang.org/en/v1/manual/environment-variables/#JULIA_CPU_TARGET))

Login nodes and (groups of) compute nodes might have different CPU types.

**Issue:** A possibly parallel compute job might retrigger package precompilation on compute nodes.

Julia supports **multiversioning**:

```bash
export JULIA_CPU_TARGET="generic;znver3,clone_all;skylake,clone_all"
```

Will compile three different variants: one for Intel Skylake, one for AMD Zen 3, and a generic fallback.

More information:
* [JULIA_CPU_TARGET](https://docs.julialang.org/en/v1/manual/environment-variables/#JULIA_CPU_TARGET)
* [Specifying multiple system image targets](https://docs.julialang.org/en/v1/devdocs/sysimg/#Specifying-multiple-system-image-targets)


## Workflow

### Visual Studio Code (VS Code)

**Challenges:**
* Running VS Code on cluster nodes
* Making the Julia extension work (i.e. making it aware of a Julia module on the cluster).

#### Running VS Code on a NERSC Perlmutter login node

* We need the [Remote - SSH extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh) (if not already installed).
* We need **direct SSH access** to the node (ideally password-less ⇒ SSH config).

1) In VS Code, press `F1` and run the `Remote-SSH: Open SSH Host...` command.
2) Enter `accountname@perlmutter.nersc.gov` (with `accountname` replaced by your training account) and press enter.
3) In the popup input box, enter your password and press enter.

After a second or two, you should have VS Code running on a Perlmutter login node! 🎉 

#### Making the Julia extension work

The first thing you want to do is to install the [Julia VS Code extension](https://marketplace.visualstudio.com/items?itemName=julialang.language-julia). To do so, open the extensions view (`CTRL + SHIFT + X` or `CMD + SHIFT + X`), search for `julia`, and click on install.

Now, the crux is to make the Julia extension use the system Julia module when it wants to start Julia. To this end, we create a wrapper script `julia_wrapper.sh` in `$HOME` which 1) loads the Julia module and 2) passes all user arguments on to the (then available) Julia binary:

```bash
#!/bin/bash

# Make julia available
ml use /global/common/software/nersc/n9/julia/modules
ml julia

# Pass on all arguments to julia
exec julia "${@}"
```

(Note that on some systems the `module` / `ml` command isn't available out of the box and extra, system-specific logic for loading it needs to be added.)

To make the script executable, run `chmod +x julia_wrapper.sh`.

Finally, we must point the Julia executable to the wrapper script. Open the VS Code Settings and search for `Julia executable`. Insert `~/julia_wrapper.sh` into the text field under `Julia: Executable Path`.

If `ALT/OPTION + J` followed by `ALT/OPTION + O` (or executing the `Julia: Start REPL` command) successfully spins up the integrated Julia REPL, you know that the setup is working! 🎉

#### Running VS Code on a NERSC Perlmutter compute(!) node

**Why?**
* Accelerator access (e.g. GPU)
* Running more expensive computations/visualizations interactively.

**Option 1 (recommended):** `SSH ProxyJump` from the login node to the compute node.
* Won't work for your training account during this workshop.
* Works with proper NERSC account.

**Option 2:** VS Code [Remote Tunnels](https://code.visualstudio.com/docs/remote/tunnels)
* Works even without direct SSH access to the compute nodes. 👍
* Microsoft will provide the tunnel (through the internet). 👎
* Requires a Microsoft/GitHub account.


### Jupyter

https://jupyter.nersc.gov
