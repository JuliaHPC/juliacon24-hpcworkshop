# Getting Started at NERSC

This place we keep onboarding instructions. Please also refer to the [cheat sheets](../help/).

Also, if you're intersted in applying for a NERSC account, please take a look at [Rebecca's slides](../help/NERSC%20Education%20Resources.pdf)

## Important: Before you go on your own ways

We've taken some shortcuts in order to help you start being productive quickly. If you're using NERSC for more than just training purposes, please consider the following

1. We put your software environtment on `$SCRATCH` -- this is a temporary place. For production software please use:
   - Containers: https://docs.nersc.gov/development/containers/
   - `/global/common/software/$YOUR_PROJECT_ID`
   - `$HOME` or `$CFS` for your source code

2. The [setup script](../setup.sh) convfigures your `.bashrc`. Please understand these, and configure your user environment in a way that works for you. **Make sure that important job scripts, and software environments don't rely on shell configurations**

3. We put our shared code into a `shared.jl` and include this in our Julia programs. This is fine for small-scale runs (couple dozen nodes). Ideally you want to be able to precompile though, for this to work, you want to package your program up [as julia packages](https://pkgdocs.julialang.org/v1/creating-packages/)
