#/bin/bash
# Show info about the NVIDIA gpus on the system

show_info() {
    local info_type=${1:-''}
    case $info_type in
        'lspci')
            sudo lspci -vvv | grep -A 20 'VGA.*NVIDIA'
            ;;
        'mini')
            nvidia-smi --query-gpu=index,name,pci.bus,pci.sub_device_id,vbios_version --format=csv
            ;;
        *)
            nvidia-smi --query-gpu=index,name,pci.sub_device_id,clocks.max.sm,clocks.sm,clocks.max.mem,clocks.mem,power.limit,power.draw,power.min_limit,power.max_limit --format=csv
            ;;
    esac
}

show_info "$@"
