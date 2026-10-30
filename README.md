# XFCE + xrdp Remote Desktop Setup

A small bash script that installs a full remote-desktop environment on a
Debian server: XFCE desktop, LightDM, and xrdp (so you can connect over
RDP from any standard remote desktop client, or proxy it through something
like Apache Guacamole).

## Compatibility

Debian 13 (trixie). Should also work on Debian 11/12 and Ubuntu
20.04+/derivatives, since it only uses `apt` and `systemd`, but it's been
tested specifically against Debian 13.

## What it does

1. Updates and upgrades apt packages (non-interactively, so it won't hang
   waiting for a prompt)
2. Installs `task-xfce-desktop`, `xfce4-goodies`, `lightdm`,
   `network-manager-gnome`, `pulseaudio`, `pavucontrol`, `xrdp`, `xorgxrdp`
3. Sets the system to boot into graphical mode by default
   (`systemctl set-default graphical.target`) and enables `lightdm`
4. Installs an xrdp reconnect hook (`/etc/xrdp/reconnectwm.sh`, the original
   is kept as `reconnectwm.sh.orig`). xrdp starts its channel helper
   (`xrdp-chansrv`: clipboard, drives, sound) only for a new session, so if
   it dies every later reconnect has no clipboard. The hook restarts it when
   nothing is listening on its socket and logs that to syslog
   (tag `xrdp-reconnect`).
5. Enables and starts `xrdp` so the box is reachable over RDP immediately

## Usage

```bash
sudo bash install_xfce_xrdp.sh
```

It's safe to re-run — every step is idempotent (already-installed packages
are skipped, already-enabled services are left alone).

After it finishes, connect to the server's IP on port 3389 with any RDP
client (Remmina, Windows' Remote Desktop Connection, FreeRDP, or through a
gateway like Guacamole) using any local user account with a password set.

## License

Use at your own risk.
