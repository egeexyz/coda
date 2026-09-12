#!/usr/bin/fish

# Source helper library if available
if test -f /usr/local/lib/codalib.fish
    source /usr/local/lib/codalib.fish
else if test -f /usr/local/lib/hobbylib.fish
    source /usr/local/lib/hobbylib.fish
else if test -f (status dirname)/../lib/hobbylib.fish
    source (status dirname)/../lib/hobbylib.fish
else
    function log_info; echo "[INFO]  $argv"; end
    function log_error; echo "[ERROR] $argv" >&2; end
end

# Locate tuning source directory (in-tree repo or packaged /usr/share/coda/tunes)
set -l script_dir (realpath (dirname (status filename)))
set -l src_base ""

if test -d "$script_dir/../../../../config/includes.chroot/etc"
    set src_base (realpath "$script_dir/../../../../config/includes.chroot/etc")
else if test -d "$script_dir/../config/includes.chroot/etc"
    set src_base (realpath "$script_dir/../config/includes.chroot/etc")
else if test -d /usr/share/coda/tunes/etc
    set src_base /usr/share/coda/tunes/etc
else
    log_error "Could not find system tune source directory."
    exit 1
end

log_info "Deploying and reenforcing Coda system tuning defaults..."

set -l sync_pairs \
    "os-release:/etc/os-release" \
    "sysctl.d:/etc/sysctl.d" \
    "pipewire:/etc/pipewire" \
    "security/limits.d:/etc/security/limits.d" \
    "systemd/zram-generator.conf:/etc/systemd/zram-generator.conf" \
    "systemd/journald.conf.d:/etc/systemd/journald.conf.d" \
    "NetworkManager/conf.d:/etc/NetworkManager/conf.d" \
    "modules-load.d:/etc/modules-load.d" \
    "udev/rules.d:/etc/udev/rules.d" \
    "systemd/system-sleep:/etc/systemd/system-sleep" \
    "modprobe.d:/etc/modprobe.d"

for pair in $sync_pairs
    set -l parts (string split ':' -- $pair)
    set -l src "$src_base/$parts[1]"
    set -l dest $parts[2]

    test -e $src; or continue

    if test -f $src
        set -l dest_dir (dirname $dest)
        sudo mkdir -p $dest_dir
        sudo cp --backup=numbered $src $dest
        log_info "Deployed: $dest"
    else if test -d $src
        sudo mkdir -p $dest
        sudo cp -r --backup=numbered $src/. $dest/
        log_info "Deployed: $dest/"
    end
end

log_info "Re-enforcing sysctl settings across running kernel..."
sudo sysctl --system

log_info "Loading kernel modules and triggering udev rules..."
sudo modprobe kyber_iosched 2>/dev/null; or true
sudo udevadm control --reload; or true
sudo udevadm trigger --subsystem-match=block; or true

log_info "Coda system tunes successfully deployed."
