# autominer: set up and run Ethereum rigs
Scripts to help setting up and running [Ethereum](https://ethereum.org) mining rigs.

## Choices
autominer is thought for rigs that consist on a headless computer with a number of GPUs. autominer uses [Ubuntu Server 16.4.2 LTS](https://www.ubuntu.com/download/server).

autominer uses [ethminer](https://github.com/ethereum-mining/ethminer).

autominer uses the [ethermine](https://ethermine.org), an Ethereum mining pool, but feel free to set it up to mine solo or to use another pool.

## Getting your OS ready
1. Download the [Ubuntu Server 16.4.2 LTS](https://www.ubuntu.com/download/server) ISO image to your computer.
1. Flash it on a pendrive using [UNetbootin](https://unetbootin.github.io), or burn it to a disk.
1. Boot the rig from your pendrive or disk. You should have an SDD or HDD to install the OS to.
1. As you install Ubuntu, make sure you choose to install OpenSSH.

## Using automine

### Initializing the automine command

Automine does its work using a number of different scripts.  It is possible to use the scripts directly, but is more convenient to use them via the single command, `automine`.

**Important:** To initialize this command, please add the following to your `.bash_profile` or your `.bashrc` file

```bash

AUTOMINE_REPO=<path/to/your/automine/repo>
[ -f $AUTOMINE_REPO/_automine.bash.inc ] && source $AUTOMINE_REPO/_automine.bash.inc


```

Once you've added this, restart your shell, and you will have a new command `automine` that has a few subcommands that can be discovered via autocompletion.  The main command you will use is `automine remote_run`.


### About remote scripts

Most of the scripts are intended to be run from the computer you are working at, which typically is not the mining rig itself.  This is done using the `automine remote_run` command. 

E.g., to run the `upgrade_system` command:

```bash
RIG_HOST=<hostname-of-rig> automine remote_run upgrade_system
```

Before it runs the specified command, `automine remote_run` syncs all the files it needs to the rig, so it is not necessary to keep an up-to-date repository on the rigs.

### Configuration

Create a directory to hold the rig configuration.  This location defaults to this is `$HOME/.automine/rig_config`.

In this directory, make a copy of `cfg/127.0.0.1.automine_config.sample.json` with your rig's IP address or hostname and without `.sample` in the filename. You may have a number of rigs, with a copy of each config file. Be sure to replace all occurences of `FILL_THIS_IN` with something meaningful, or remove them if that's more appropriate.

You may use an alternate to the default location `$HOME/.automine/rig_config`.  When doing so, you must export the path of the directory in the environment variable 'AUTOMINE_CFG_DIR' when running any of the automine commands.

Every automine command needs to know the hostname of the rig being worked on.  This may be set in a number of ways.

1. Before running any command, export the RIG_HOST hostname

   ```shell
   export RIG_HOST=<the-rig-host-name>
   automine remote_run update_bashrc
   ```

2. Set the RIG_HOST var in the same command-line as the automine command

   ```shell
   RIG_HOST=<the-rig-host-name> automine remote_run update_bashrc
   ```

3. Setting the rig hostname using with the -a option of the automine command

   ```shell
   automine -a <the-rig-host-name> remote_run update_bashrc
   ```

The rest of this doc assumes that `RIG_HOST` is exported


### Getting ready to mine
1. `automine remote_run install_driver` will install the Linux driver for your GPU type.
1. `automine remote_run install_autologin_desktop` will install and configure Xorg, needed to overclock NVIDIA GPUs.
1. `automine remote_run upgrade_system` will upgrade the system, and potential upgrade the drivers if necessary
1. `automine remote_run build_ethminer` will install the mining software.
1. `automine remote_run install_systemd_units` will install automine as a user-owned systemd service

### Bash shortcuts

`automine remote_run update_bashrc` will add useful lines to `.bashrc`

These lines add functions that can be used during interactive SSH sessions.

E.g the ability to start automine service using `mnr_up`, to access service's screen session using `mnr_screen`, and to stop it using `mnr_down`.
*N.B.* the escape key for `screen` is set to C-z instead of the default C-a.

Also, it sets up the shell PATH variable so that any of the applicable `automine remote_run` commands can also be re-run on the rig using `automine_run`
E.g.

```bash

automine_run upgrade_system

```

### Mining

1. `automine remote_run minerctl start` will start the automine systemd service, runs the mining software in a screen session

1. `automine remote_run show_screen` will attach to the automine service's screen session via ssh

### Overclocking

1. `automine remote_run configure_xorg` will update `/etc/X11/xorg.conf` with a display for each of the nvidia GPUs.

   - It takes of care restarting lightdm; the configuration update is applied immediately
   - **N.B.** This needs to be done after any hard reboot where the number GPUs changes
   
1. Update the overclocking choices your copy of `cfg/127.0.0.1.automine_config.sample.json`. 
   - For Nvidia cards, you can set different overclocks for different card types.
   
1. Use `automine remote_run show_screen` to view the screen session

   - For Nvidia cards, switch to the `nvidia-smi` window and ensure there is an Xorg process for each GPU and note the current power levels
   - exit the screen session, e.g, using 'C-z d'
   
1. `automine remote_run apply_overclocks` to update the GPUS to use the overclock settings

   - Use `automine remote_run show_screen` to view the screen session again, and
     confirm that mining and the GPUs are OK
     
1. `automine remote_run apply_overclocks persist` to make the overclocks persist whenever the machine restarts

    - without the 'persist' argument, the overclocks need to be re-applied after any maintenance reboot.  
    - **N.B.** do this once the overclock settings are stable
    
1. `automine remote_run apply_overclocks transient` applies the overclocks, but
   removes persistence if it is present

   
### Maintenance suggestions

1. `automine remote_run upgrade_system` should be run regularly (e.g, weekly) to update the base Ubuntu system.
   - It's important to pick up security upgrades and compatible driver updates
   - If the `apt-get update` output indicate that packages have been held back, re-run the upgrade_system command with those packages as arguments.  E.g,:
     - `automine remote_run upgrade_system <pkg1> <pkg2> ... <pkgn>`
   - **N.B** This command reboots the rig, so after it is run, the mining software will need to be restarted using `automine remote_run minerctl restart`
   
1. `automine remote_run optimize_os_services` should be run at least once
   - It does a number of useful things, but probably the most important is it install basic intrusion detection packages and updates SSH config settings
   
1. `automine remote_run build_ethminer` should be run from time to time to pick up improvements to the mining software


## Troubleshooting
### BIOS setup
Here are some settings you might want to check and change on your BIOS.

- Enable Above G4 Decoding (if you are running more than 3 GPUs)

- Set DMI Max Link Speed / PCIEX16_1 Link Speed / PCIe speed to Gen2 (no need to use Gen3 for mining)

- Disable Fast Boot (if you can't get to the BIOS, remove your boot SATA device)

### Loss of connectivity
Sometimes the ethernet device name will change from `dev/eth0` after booting with a new GPU on a PCI slot. This will cause your LAN and internet connection to go down, so you will need to run `common/optimize_os_services.sh` locally.

### Not getting an Xorg process per GPU
If you have a monitor connected to the rig while you run `automine remote_run configure_xorg`, your `xorg.conf` may get reset to a default one after restaring `lightdm`.
