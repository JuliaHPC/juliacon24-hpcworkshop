# JuliaCon24 Workshop: Hands-on with Julia for HPC on GPUs and CPUs

Details: https://pretalx.com/juliacon2024/talk/NTQZJJ/

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

Ideally, you already do the following things before the workshop (but there will also be time to do them in Eindhoven):
* Make sure that you have [VS Code](https://code.visualstudio.com/download) installed on your laptop.
* Follow the [VS Code and Julia on Perlmutter](help/vscode_julia_on_perlmutter.md) instructions to run Julia within VS Code remotely on a Perlmutter login node.
* **On Perlmutter:**
  * Clone the workshop materials into `$SCRATCH/juliacon24-hpcworkshop`by running the following command in a (VS Code) terminal on Perlmutter.

         git clone https://github.com/JuliaHPC/juliacon24-hpcworkshop $SCRATCH/juliacon24-hpcworkshop
    
    * You will work in this folder during the workshop.
    * **Note:** You will have to run `git pull` on workshop day to get the latest version.
  * To prepare your `$HOME/.bashrc`, run the following command

         echo -e "export JULIA_DEPOT_PATH=\$SCRATCH/.julia\nexport PATH=\$SCRATCH/.julia/bin:\$PATH" >> $HOME/.bashrc

