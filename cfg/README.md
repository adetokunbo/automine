# Rig configuration

This directory should contain files that configure the rigs.

- `<myhostname>.sh` sets up Environment variables used both to set up the rig at `myhostname`, and to run other scripts on `myhostname`

- `<myhostname>.overclock.json` is used to configure the script that sets overclock settings on `myhostname`
   
It's empty apart from some sample files

## Overclock configuration

Files that match the pattern `<hostname>.overclock.json` are used to configure overclocking of nvidia GPUs.

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

There is an example in the sample [overclock.json](./127.0.0.1.overclock.sample.json) file in this directory.
