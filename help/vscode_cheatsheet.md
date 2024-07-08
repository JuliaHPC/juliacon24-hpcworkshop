# VS Code Cheatsheet

## SSH → Perlmutter

1) In VS Code, press `F1` and run the `Remote-SSH: Open SSH Host...` command.
   - If the command isn't available, make sure that [Remote - SSH extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh) is installed (but it should be available out of the box).
2) Enter `trainXY@perlmutter.nersc.gov` (with `trainXY` replaced by your training account) and press enter.
3) In the popup input box, enter your password and press enter.

After a second or two, you should have VS Code running on a Perlmutter login node! 🎉

## Basics

* Run a command: Press `F1` or `CTRL/CMD + SHIFT + P`

* Open a terminal: `` Ctrl + ` ``

* Open a folder from the terminal: `code -r .`

* Search for a file: `CTRL/CMD + T`

* Search for a function in a file: `CTRL/CMD + R`

## Julia

* Open the REPL: `ALT/OPTION + J` followed by `ALT/OPTION + O`

* Restart the REPL: `ALT/OPTION + J` followed by `ALT/OPTION + R`

* Kill the REPL: `ALT/OPTION + J` followed by `ALT/OPTION + K`

* Change the Julia environment: `ALT/OPTION + J` followed by `ALT/OPTION + E`