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

# 4. Keep the clipboard working after a reconnect. xrdp starts its channel
#    helper (xrdp-chansrv: clipboard, drives, sound) only when a new session is
#    created; if it dies, every later reconnect has no clipboard. reconnectwm.sh
#    runs on each reconnect and restarts the helper when nothing is listening on
#    its socket. Restarts are logged to syslog with the tag xrdp-reconnect.
if [ -f /etc/xrdp/reconnectwm.sh ] && [ ! -f /etc/xrdp/reconnectwm.sh.orig ]; then
    sudo cp -p /etc/xrdp/reconnectwm.sh /etc/xrdp/reconnectwm.sh.orig
fi
sudo tee /etc/xrdp/reconnectwm.sh >/dev/null <<'RECONNECT_EOF'
#!/bin/sh

# Write procedures here you want to execute on reconnect

# Restart the channel helper (xrdp-chansrv: clipboard, drives, sound) if it has died.
# sesman starts it only with a new session, so once it is gone every reconnect has no
# clipboard. Liveness is checked on its listening socket, not by process name: the
# containers' own xrdp helpers show up in the host's process list too.
chansrv="${XRDP_CHANSRV:-/usr/sbin/xrdp-chansrv}"
display="${DISPLAY:-:10}"
display="${display#*:}"
display="${display%%.*}"
sockdir="${XRDP_SOCKET_PATH:-/run/xrdp/sockdir/$(id -u)}"
sock="$sockdir/xrdp_chansrv_socket_$display"

if ! ss -xlH 2>/dev/null | grep -qF " $sock "; then
    [ -S "$sock" ] && rm -f "$sock"   # left behind by a helper that died
    DISPLAY=":$display" XRDP_SOCKET_PATH="$sockdir" \
    XRDP_PULSE_SINK_SOCKET="xrdp_chansrv_audio_out_socket_$display" \
    XRDP_PULSE_SOURCE_SOCKET="xrdp_chansrv_audio_in_socket_$display" \
        setsid "$chansrv" </dev/null >/dev/null 2>&1 &
    logger -t xrdp-reconnect "restarted xrdp-chansrv for display :$display (user $(id -un))"
fi
RECONNECT_EOF
sudo chmod 755 /etc/xrdp/reconnectwm.sh
sh -n /etc/xrdp/reconnectwm.sh

# 5. Enable xrdp for remote desktop access (e.g. so a Guacamole or other
#    RDP gateway can proxy connections to this host)
sudo systemctl enable xrdp
sudo systemctl restart xrdp

echo "================================================="
echo " Installation complete! Reboot your system now:"
echo " sudo reboot"
echo "================================================="
