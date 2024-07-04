# Working with VS Code and Julia on NERSC's Perlmutter

## Running VS Code on a login node

1) In VS Code, press `F1` and run the `Remote-SSH: Open SSH Host...` command.
   - If the command isn't available, make sure that [Remote - SSH extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh) is installed (should already be available out of the box).
2) Enter `trainXY@perlmutter.nersc.gov` (with `trainXY` replaced by your training account) and press enter.
3) In the popup input box, enter your password and press enter.

After a second or two, you should have VS Code running on a Perlmutter login node! 🎉 

## Making the Julia extension work (one time setup)

1) Install the [Julia VS Code extension](https://marketplace.visualstudio.com/items?itemName=julialang.language-julia) within **VS Code running on the Perlmutter login node**. To do so, open the extensions view (`CTRL/CMD + SHIFT + X`), search for `julia`, and click on install.

Now, the crux is to make the Julia extension use the system Julia module when it wants to start Julia. To this end, we create a wrapper script  in `$HOME` which 1) loads the Julia module and 2) passes all user arguments on to the (then available) Julia binary:

2) In your home directory (`cd $HOME`), create a wrapper script called `julia_wrapper.sh` with the following content:
    ```bash
    #!/bin/bash
    
    # Make julia available
    ml use /global/common/software/nersc/n9/julia/modules
    ml julia
    
    # Pass on all arguments to julia
    exec julia "${@}"
    ```

    (The script `julia_wrapper.sh` is also available in the root of the workshop repository. You can also copy it from there if you like.)

3) Make the script executable by running `chmod +x $HOME/julia_wrapper.sh`.

4) Now, we must point the Julia executable to the wrapper script. Open the VS Code Settings and search for `Julia executable`. Insert `~/julia_wrapper.sh` into the text field under `Julia: Executable Path`.

If `ALT/OPTION + J` followed by `ALT/OPTION + O` (**or** pressing `F1` and executing the `Julia: Start REPL` command) successfully spins up the integrated Julia REPL, you know that the setup is working! 🎉
