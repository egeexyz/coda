#!/usr/bin/fish

# Local system sync and diff utility for Coda
# Syncs real configuration files from repository into /etc (no symlinks)

set -l script_dir (realpath (dirname (status filename)))
set -l repo_root (realpath "$script_dir/..")
cd $repo_root

set -l action $argv[1]
test -z "$action"; and set action sync

set -l sync_pairs \
    "config/includes.chroot/etc/os-release:/etc/os-release" \
    "config/includes.chroot/etc/sysctl.d:/etc/sysctl.d" \
    "config/includes.chroot/etc/pipewire:/etc/pipewire" \
    "config/includes.chroot/etc/security/limits.d:/etc/security/limits.d" \
    "config/includes.chroot/etc/systemd/zram-generator.conf:/etc/systemd/zram-generator.conf" \
    "config/includes.chroot/etc/systemd/journald.conf.d:/etc/systemd/journald.conf.d" \
    "config/includes.chroot/etc/NetworkManager/conf.d:/etc/NetworkManager/conf.d" \
    "config/includes.chroot/etc/modules-load.d:/etc/modules-load.d" \
    "config/includes.chroot/etc/udev/rules.d:/etc/udev/rules.d" \
    "config/includes.chroot/etc/systemd/system-sleep:/etc/systemd/system-sleep" \
    "config/includes.chroot/etc/modprobe.d:/etc/modprobe.d"

switch $action
    case diff
        echo "Comparing repo configs with local system (/etc)..."
        for pair in $sync_pairs
            set -l parts (string split ':' -- $pair)
            set -l src $parts[1]
            set -l dest $parts[2]

            if test -f $src
                if test -e $dest
                    diff -u $dest $src; or true
                else
                    echo "New file: $src -> $dest"
                end
            else if test -d $src
                for file in (find $src -type f)
                    set -l rel (string replace "$src/" "" -- $file)
                    set -l target "$dest/$rel"
                    if test -e $target
                        diff -u $target $file; or true
                    else
                        echo "New file: $file -> $target"
                    end
                end
            end
        end

    case sync
        echo "Syncing repo configs to local system (/etc)..."
        for pair in $sync_pairs
            set -l parts (string split ':' -- $pair)
            set -l src $parts[1]
            set -l dest $parts[2]

            if test -f $src
                set -l dest_dir (dirname $dest)
                sudo mkdir -p $dest_dir
                sudo cp --backup=numbered $src $dest
                echo "Copied: $src -> $dest"
            else if test -d $src
                sudo mkdir -p $dest
                sudo cp -r --backup=numbered $src/. $dest/
                echo "Copied: $src/ -> $dest/"
            end
        end

        echo "Reloading sysctl..."
        sudo sysctl --system

        echo "Loading kyber module and reloading udev rules..."
        sudo modprobe kyber_iosched 2>/dev/null; or true
        sudo udevadm control --reload; or true
        sudo udevadm trigger --subsystem-match=block; or true

    case '*'
        echo "Usage: "(status basename)" [sync|diff]"
        exit 1
end
