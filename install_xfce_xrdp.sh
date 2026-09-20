#!/usr/bin/env bash
set -e

echo "=== Starting XFCE Desktop installation for Debian 13 ==="

# 1. Update repositories
export DEBIAN_FRONTEND=noninteractive
sudo -E apt update && sudo -E apt upgrade -y

# 2. Install XFCE Desktop, LightDM, and essential tools
sudo -E apt install -y \
    task-xfce-desktop \
    xfce4-goodies \
    lightdm \
    network-manager-gnome \
    pulseaudio \
    pavucontrol \
    xrdp \
    xorgxrdp

# 3. Set the display manager and boot into graphical mode (GUI)
sudo systemctl set-default graphical.target
sudo systemctl enable lightdm

# 4. Enable xrdp for remote desktop access (e.g. so a Guacamole or other
#    RDP gateway can proxy connections to this host)
sudo systemctl enable xrdp
sudo systemctl restart xrdp

echo "================================================="
echo " Installation complete! Reboot your system now:"
echo " sudo reboot"
echo "================================================="
