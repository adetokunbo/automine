# Rig configuration

This directory contain samples of files that configure the rigs.
Appropriately named and updated copies of the sample file should be copied to the configuration directory, which defaults to `<my-home-dir>/.automine/rig_config`.  E.g,

- `<my-home-dir>/.automine/rig_config/<myhostname>.automine_config.json` is used to configure the script that sets overclock settings on `myhostname`
   
## Environment

The environment section specifies environment values that are used
- locally where the control scripts are run
- and also by scripts on the rig

There are few required values, like RIG_USER AND RIG_TYPE, and various optional
ones that depend on the type of rig or the control commands that need to be run

## Ethminer options

The ethminer section specifies command line flags to use with the ethminer binary. Here also, there is a mix of required and optional fields.

The ethminer section optionally contains a nested environment section.  This specifies environment values to be set when the ethminer command is run.


## Overclock configuration

Files that match the pattern `<myhostname>.automine_config.json` are used to configure overclocking of nvidia GPUs.

The nvidia section contains named json configuration objects that can either

1. configure all GPUs of the same name, e.g. 'Geforce GTX 970'
2. configure all GPUs with the same pci.sub\_device\_id.
   
_(2)_ is more specific, and allows different overclocks for devices of the same
name, but different manufacturers.  To find the sub\_device\_id, use the `nvidia-smi` tool.

```bash
$ nvidia-smi --query-gpu=name,pci.sub_device_id,index --format=csv,noheader
0, 0x143819DA, 86.06.39.00.1C, GeForce GTX 1060 6GB
1, 0x11D710DE, 86.06.45.00.61, GeForce GTX 1060 6GB

```

There is an example in the sample [automine_config.json](./127.0.0.1.automine_config.sample.json) file in this directory.

The amd section is a json configuration object that configures the gpu clock
limit and memory overdrive for all GPUs on the rig
