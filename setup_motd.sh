#!/bin/sh
#
# DESCRIPTION:
# This script sets up a personalized motd on Ubuntu
#
# REQUIREMENTS:
# - Linux platform: Ubuntu 20/04+
# - python 3.6+
#
# USAGE:
#  sudo curl https://raw.githubusercontent.com/francois-le-ko4la/LABs/master/ransim.sh | sudo sh
#

SCRIPT_PATH="/opt/scripts"
URL="https://raw.githubusercontent.com/francois-le-ko4la/ubuntu-motd-sysinfo/main"
PKG="python3-full gcc python3-dev figlet toilet toilet-fonts lolcat"
LIB="distro distro-info netifaces psutil"

# Logging function
log() {
    echo "$(date --iso-8601=seconds) - MOTD - $1"
}

# Check if the platform is Linux
if [ "$(uname)" != "Linux" ]; then
    echo "This script only works on Linux systems."
    exit 1
fi

# Check if the platform is Ubuntu 20.04 or newer
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [ "$ID" = "ubuntu" ] && [ "${VERSION_ID%.*}" -ge 20 ]; then
        log "Ubuntu 20.04 or newer detected."
    else
        echo "Unsupported Ubuntu version. Exiting..."
        exit 1
    fi
else
    echo "Unable to detect the operating system."
    exit 1
fi

log "Install python3-full..."
apt-get -yq install $PKG > /dev/null 2>&1

log "Create scripts repository..."
mkdir -p $SCRIPT_PATH
log "Create python venv..."
python3 -m venv $SCRIPT_PATH/venv > /dev/null 2>&1
log "Install lib..."
$SCRIPT_PATH/venv/bin/python -m pip install --upgrade pip > /dev/null 2>&1
$SCRIPT_PATH/venv/bin/python -m pip install $LIB > /dev/null 2>&1
log "Download motd files..."
for file in 00-fprint-hostname 40-ubuntu-motd-sysinfo
do
        wget -q -O $SCRIPT_PATH/motd_$file $URL/$file > /dev/null 2>&1
        chmod +x $SCRIPT_PATH/motd_$file
        if [ -f "/etc/update-motd.d/$file" ]; then
                log "File $file exists. Delete $file."
                rm /etc/update-motd.d/$file
        fi
        log "Create link file /etc/update-motd.d/$file"
        ln -s $SCRIPT_PATH/motd_$file /etc/update-motd.d/$file
done

if [ -f "/etc/update-motd.d/50-landscape-sysinfo" ]; then
    chmod -x /etc/update-motd.d/50-landscape-sysinfo
    log "Permissions changed for /etc/update-motd.d/50-landscape-sysinfo."
else
    # Si le fichier n'existe pas, afficher un message d'avertissement
    log "File '/etc/update-motd.d/50-landscape-sysinfo' does not exist. No action taken."
fi

log "Operation completed successfully."
