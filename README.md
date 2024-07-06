# JuliaCon24 Workshop: Hands-on with Julia for HPC on GPUs and CPUs

**Instructors:** [Carsten Bauer](https://github.com/carstenbauer), [Ludovic Räss](https://github.com/luraess), and [Johannes Blaschke](https://github.com/JBlaschke) (remote).

**Where:** TU-Eindhoven 0.244

**When:** July 9th, 1:30 PM (CEST)

**More:** https://pretalx.com/juliacon2024/talk/NTQZJJ/

## Applying for NERSC Training Account (Urgent!)

To get the most out of the workshop, you need to apply for a NERSC training account **before the workshop (as early as possible)**! The reason for this is that everyone who applies for an account has to be checked, which can take some time (between a few minutes and a week) depending on their personal background (e.g. nationality and affiliation).

**Please only apply for an account if you 1) have a workshop ticket and 2) really plan to participate in the JuliaCon 2024 workshop on Tuesday, July 9 in person!**

### Sign up for an account

To apply for an account:
1. Go to https://iris.nersc.gov/train
2. Fill out the application form with your details and **use the training code that you've received by email**.
3. Iris will display your training account's login credials **only once**. **Take a screenshot of your login credials**, you will not be able to change or recover these after you close this tab!
4. You can already start experimenting once your account has been approved. Your training account will be availabe until July 14th (end of JuliaCon). Accounts get deleted afterwards, so remember to **backup your data** before July 14th.

**If your institution is not listed in the drop down menu at  https://iris.nersc.gov/train:** Please choose "Training Account Only - Org Not Listed", and put your organization name in the "Department" field next.

If you are facing any issues, please reach out to Carsten Bauer (crstnbr@gmail.com).

## Prepare for the workshop

You can already do the following steps before the workshop (but there will also be time to do them in Eindhoven).

To begin with, make sure that you have [VS Code](https://code.visualstudio.com/download) installed on your laptop.

### VS Code → Perlmutter (via SSH)

1) In VS Code, press `F1` and run the `Remote-SSH: Open SSH Host...` command.
   - If the command isn't available, make sure that [Remote - SSH extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh) is installed (but it should be available out of the box).
2) Enter `trainXY@perlmutter.nersc.gov` (with `trainXY` replaced by your training account) and press enter.
3) In the popup input box, enter your password and press enter.

After a second or two, you should have VS Code running on a Perlmutter login node! 🎉 


### On Perlmutter
* Clone the workshop materials into `$SCRATCH/juliacon24-hpcworkshop`by running the following command.

       git clone https://github.com/JuliaHPC/juliacon24-hpcworkshop $SCRATCH/juliacon24-hpcworkshop
  
  * You will work in this folder during the workshop.
* Change into the workshop repository that you've just cloned (`cd $SCRATCH/juliacon24-hpcworkshop`) and run the following command(s).

      ./setup.sh
      . $HOME/.bashrc
  
  * The setup script
    * instantiates the Julia environment
    * installs MPI.jl's `mpiexecjl` wrapper
    * modifies your `$HOME/.bashrc` to
      * permanently put your Julia depot onto the parallel file system (`$SCRATCH/.julia`)
      * auto-load the Julia module when you login (such that the `julia` command is available)
      * make `mpiexecjl` available (i.e. modify `$PATH`)
     
* Let's now turn to the Julia VS Code extension.

  1) Installing the extension
      - Open the extensions view (press `CTRL/CMD + SHIFT + X`).
      - Search for `julia`.
      - Click on `install`.
  2) Pointing it to `julia_wrapper.sh`
      - Open the VS Code Settings (press `CTRL/CMD + ,`).
      - Click on the tab `Remote [SSH: perlmutter.nersc.gov]`.
      - Search for `Julia executable`.
      - Insert `/pscratch/sd/t/trainXY/juliacon24-hpcworkshop/julia_wrapper.sh` - with `trainXY` replaced by you training account name - into the text field under `Julia: Executable Path`.
   3) If `ALT/OPTION + J` followed by `ALT/OPTION + O` (**or** pressing `F1` and executing the `Julia: Start REPL` command) successfully spins up the integrated Julia REPL, you know that the setup is working! 🎉
        
**If you have already done the steps above before the workshop (if not, skip this):**

You should make sure that you have the latest version of the materials on workshop day. To that end, perform the following steps **on Perlmutter** at the beginning of the workshop:

* Switch to the workshop repository `cd $SCRATCH/juliacon24-hpcworkshop`.
* Run `git pull`.
* Rerun the setup script: `./setup.sh`.
