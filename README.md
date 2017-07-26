# autominer: set up and run Ethereum rigs
Scripts to help setting up and running [Ethereum](https://ethereum.org) mining rigs.

## Choices
autominer is thought for rigs that consist on a headless computer with a number of GPUs. autominer uses [Ubuntu Server 16.4.2 LTS](https://www.ubuntu.com/download/server).

autominer uses [ethminer](https://github.com/ethereum-mining/ethminer).

autominer uses the [ethermine](https://ethermine.org), an Ethereum mining pool, but feel free to set it up to mine solo or to use another pool.

## Using automine
### About remote scripts
Most of the scripts are thought for running them from the computer you are working at, which typically is not the mining rig itself. The scripts starting with `ssh_*` and `rsync_*` are meant to be run from a different machine.

Because all the remote scripts rsync all the needed files to the rig before doing anything, you don't need to keep an up-to-date repository on the rig.

### Configuration
Make copies of `cfg/127.0.0.1.sample.sh` and `cfg/127.0.0.1.overclock.sample.json` with your rig's IP address and without `.sample` in the filename. You may have a number of rigs, with a copy of each config file. Be sure to replace all occurences of `FILL_THIS_IN` with something meaningful.

Before running any scripts, set RIG_IP or automine will not know which rig you are working with:

```shell
export RIG_IP=FILL_THIS_IN
```

### Getting ready to mine
1. `./ssh_install_driver.sh` will install the Linux driver for your GPU type.
1. `./ssh_install_autologin_desktop.sh` will be needed to get Xorg running in order to overclock.
1. `./ssh_build_ethminer.sh` will install the mining software.
1. `./ssh_update_bashrc.sh` will add useful lines to your `.bashrc`.
1. `./ssh_install_systemd_units.sh` will set autominer as a system service

You should now be able start automine using `mnr_up`. ethminer runs in a `screen` you can access by entering `mnr_screen`. The escape key for `screen` is set to C-z instead of the default C-a. You can also stop autominer by entering `mnr_down`.

### Overclocking
1. Run `ssh_configure_xorg.sh` to get an `/etc/X11/xorg.conf` with a display for each of your GPUs. It will also restart lightdm for you so that the changes are live.
1. Enter your overclocking choices to your copy of `cfg/127.0.0.1.overclock.sample.json`. You can set different overclocks for different card types or for each single card.
1. Restart the automine service (`mnr_down && mnr_up`) and find your Xorg process and overclock values on the `nvidia-smi` tab.

## Troubleshooting
### BIOS setup
Here are some settings you might want to check and change on your BIOS.

- Enable Above G4 Decoding (if you are running more than 3 GPUs)

- Set DMI Max Link Speed / PCIEX16_1 Link Speed / PCIe speed to Gen2 (no need to use Gen3 for mining)

- Disable Fast Boot (if you can't get to the BIOS, remove your boot SATA device)

### Loss of connectivity
Sometimes the ethernet device name will change from `dev/eth0` after booting with a new GPU on a PCI slot. This will cause your LAN and internet connection to go down, so you will need to run `common/optimize_os_services.sh` locally.

### Not getting an Xorg process per GPU
If you have a monitor connected to the rig while you run `ssh_configure_xorg.sh`, your `xorg.conf` may get reset to a default one after restaring `lightdm`.