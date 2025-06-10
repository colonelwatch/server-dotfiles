# server-dotfiles

In case I need to nuke (or accidentally have nuked) the Debian install on my server or I switch to a new machine to run on, this repo documents everything I need to set it up from scratch, including a bootstrap script and a recovery script.

## Pre-install

0. Enable Wake On AC and set a battery charge limit at 70%

1. Disable any backup procedures targeting the server

## Install

2. Booting from the install disk for Debian 12 (non-free drivers now included by default), proceed through the non-graphical install process.
    * Time zone, keyboard, and language are self-explanatory
    * The hostname should be `kenny-server`
    * Disable the root user (leave the root password empty)
    * Set up the disk as follows:
        * Select a guided entire-disk install
        * Delete both the main and swap partitions
        * Create a new partition in the left-behind free space, ensuring that:
            * the file system is btrfs,
            * the partition *is* formatted (if applicable), and
            * the mount point is `/`
        * Resize the main partition so that it reaches the end of the disk
        * Finish setup, and dismiss the warning about not designating swap
    * Turn off all desktop environments and turn on the SSH server

## Post-install

3. Install `git` with the command `sudo apt install git`

4. Clone this repository with the command `git clone https://github.com/colonelwatch/server-dotfiles .dotfiles`, call `cd .dotfiles && ./bootstrap.sh`

5. Authorize thunderbolt dock through `boltctl`

6. Restart

## Post-bootstrap

7. SSH with tunneling into the server by running the command `ssh -L 53682:localhost:53682 kenny@kenny-server` on another machine with a web browser

8. Call `cd .dotfiles && ./recovery.sh`, which includes manual prompts and recovery

9. Restart

10. Call `cd .dotfiles && bats test`, which runs some checks

11. Reenable the backup procedures that were targeting the server
