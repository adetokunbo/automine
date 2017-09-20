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

### About remote scripts
Most of the scripts are intended to be run from the computer you are working at, which typically is not the mining rig itself.  This is done using `automine_remote_run.sh`. E.g., to run the upgrade_system command:

```bash
RIG_HOST=<hostname-of-rig> ./automine_remote_run.sh upgrade_system
```

Before it runs the specified command, `automine_remote_run.sh` syncs all the files it needs to the rig, so it is not necessary to keep an up-to-date repository on the rigs.

### Configuration
Create a directory to hold your rig configuration.  The expected value for this is `<my-home-dir>/.automine/rig_config`.  In this directory, make a copy of `cfg/127.0.0.1.automine_config.sample.json` with your rig's IP address or hostname and without `.sample` in the filename. You may have a number of rigs, with a copy of each config file. Be sure to replace all occurences of `FILL_THIS_IN` with something meaningful.

You can use a different directory instead of `<my-home-dir>/.automine/rig_config`.  When doing so, you must export the path of the directory in the environment variable 'AUTOMINE_CFG_DIR' when running any of the automine commands.

Before running any scripts, set RIG_HOST or automine will not know which rig you are working with:

```shell
export RIG_HOST=FILL_THIS_IN
```

### Getting ready to mine
1. `./automine_remote_run.sh install_driver` will install the Linux driver for your GPU type.
1. `./automine_remote_run.sh install_autologin_desktop` will install and configure Xorg, needed to overclock NVIDIA GPUs.
1. `./automine_remote_run.sh build_ethminer` will install the mining software.
1. `./automine_remote_run.sh update_bashrc` will add useful lines to your `.bashrc`.
1. `./automine_remote_run.sh install_systemd_units` will set autominer as a system service

You should now be able start automine using `mnr_up`. ethminer runs in a `screen` you can access by entering `mnr_screen`. The escape key for `screen` is set to C-z instead of the default C-a. You can also stop autominer by entering `mnr_down`.

### Overclocking
1. Run `./automine_remote_run.sh configure_xorg` to get an `/etc/X11/xorg.conf` with a display for each of your GPUs. It will also restart lightdm for you so that the changes are live.
1. Enter your overclocking choices to your copy of `cfg/127.0.0.1.automine_config.sample.json`. For Nvidia cards, you can set different overclocks for different card types or for each single card.
1. Restart the automine service (`mnr_down && mnr_up`) and find your Xorg process and overclock values on the `nvidia-smi` tab.
1. With the automine service running, run `sudo nvidia/overclock.py` for Nvidia cards or `sudo DISPLAY=:0 amdgpu/overclock.py` for AMD cards, and check that the cards are doing alright.

## Troubleshooting
### BIOS setup
Here are some settings you might want to check and change on your BIOS.

- Enable Above G4 Decoding (if you are running more than 3 GPUs)

- Set DMI Max Link Speed / PCIEX16_1 Link Speed / PCIe speed to Gen2 (no need to use Gen3 for mining)

- Disable Fast Boot (if you can't get to the BIOS, remove your boot SATA device)

### Loss of connectivity
Sometimes the ethernet device name will change from `dev/eth0` after booting with a new GPU on a PCI slot. This will cause your LAN and internet connection to go down, so you will need to run `common/optimize_os_services.sh` locally.

### Not getting an Xorg process per GPU
If you have a monitor connected to the rig while you run `./automine_remote_run.sh configure_xorg`, your `xorg.conf` may get reset to a default one after restaring `lightdm`.
