#/bin/bash
# Install the AMDGPU drivers and SDK on this rig.

install_amdgpu() {
    cd $HOME/.automine/lib/install

    # Derived from instructions @ http://bit.ly/2ygD4D3
    echo "Installing the AMDGPU driver"

    local download_tar=amdgpu-pro-${AMDGPU_VERSION}.tar.xz
    local download_url=https://www2.ati.com/drivers/linux/ubuntu/$download_tar
    local referer_url=http://support.amd.com

    [[ -f $download_tar ]] || wget --referer=$referer_url $download_url
    tar -Jxvf $download_tar
    [[ -f amdgpu-pro-${AMDGPU_VERSION}/amdgpu-pro-install ]] || {
        echo "Could not find the driver installer"
        return 1
    }
    cd amdgpu-pro-${AMDGPU_VERSION}
    ./amdgpu-pro-install  # takes 5-10 mins
}

install_amdgpu_sdk() {
    cd $HOME/.automine/lib/install

    echo "Installing the AMD GPU SDK"
    local download_tar=AMD-APP-SDKInstaller-${AMDGPU_SDK_VERSION}-linux64.tar.bz2
    tar -xf $download_tar
    [[ -f ./AMD-APP-SDK-${AMDGPU_SDK_VERSION}-linux64.sh ]] || {
        echo "Could not find the SDK installer"
        return 1
    }
    sudo ./AMD-APP-SDK-${AMDGPU_SDK_VERSION}-linux64.sh
}

set -u  # fail if any specified environment variables are unset
install_amdgpu
install_amdgpu_sdk
