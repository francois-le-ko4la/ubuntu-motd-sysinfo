#!/bin/sh
#
# DESCRIPTION:
# This script sets up a personalized motd on Ubuntu
#
# REQUIREMENTS:
# - Linux platform: Ubuntu 20.04+
# - python 3.6+
#
# USAGE:
#  sudo curl https://raw.githubusercontent.com/francois-le-ko4la/ubuntu-motd-sysinfo/main/setup_motd.sh | sudo sh
#

SCRIPT_PATH="/opt/scripts"
URL="https://raw.githubusercontent.com/francois-le-ko4la/ubuntu-motd-sysinfo/main"
PKG="python3-full gcc python3-dev"
LIB="distro distro-info netifaces psutil pyfiglet termcolor"

# Logging function
log() {
    echo "$(date --iso-8601=seconds) - MOTD - $1"
}

# Check if the platform is Linux
if [ "$(uname)" != "Linux" ]; then
    log "This script only works on Linux systems."
    exit 1
fi

# Check if the platform is Ubuntu 20.04 or newer
if [ -f /etc/os-release ]; then
    . /etc/os-release
    if [ "$ID" = "ubuntu" ] && [ "${VERSION_ID%.*}" -ge 20 ]; then
        log "Ubuntu 20.04 or newer detected."
    else
        log "Unsupported Ubuntu version. Exiting..."
        exit 1
    fi
else
    log "Unable to detect the operating system."
    exit 1
fi

log "Installing python3-full..."
sudo apt-get -yq install $PKG > /dev/null 2>&1 || { log "Installation of python3-full failed."; exit 1; }

log "Creating scripts repository..."
mkdir -p $SCRIPT_PATH
log "Creating python venv..."
python3 -m venv $SCRIPT_PATH/venv > /dev/null 2>&1 || { log "Creation of python venv failed."; exit 1; }
log "Installing libraries..."
$SCRIPT_PATH/venv/bin/python -m pip install --upgrade pip > /dev/null 2>&1
$SCRIPT_PATH/venv/bin/python -m pip install $LIB > /dev/null 2>&1 || { log "Installation of libraries failed."; exit 1; }
log "Downloading motd files..."
for file in 00-fprint-hostname 40-ubuntu-motd-sysinfo; do
    wget -q -O $SCRIPT_PATH/motd_$file $URL/$file > /dev/null 2>&1 || { log "Download of $file failed."; exit 1; }
    chmod +x $SCRIPT_PATH/motd_$file
    if [ -f "/etc/update-motd.d/$file" ]; then
        log "File $file exists. Deleting $file."
        rm /etc/update-motd.d/$file
    fi
    log "Creating link file /etc/update-motd.d/$file"
    ln -s $SCRIPT_PATH/motd_$file /etc/update-motd.d/$file
done

if [ -f "/etc/update-motd.d/50-landscape-sysinfo" ]; then
    chmod -x /etc/update-motd.d/50-landscape-sysinfo
    log "Permissions changed for /etc/update-motd.d/50-landscape-sysinfo."
else
    log "File '/etc/update-motd.d/50-landscape-sysinfo' does not exist. No action taken."
fi

log "Operation completed successfully."
