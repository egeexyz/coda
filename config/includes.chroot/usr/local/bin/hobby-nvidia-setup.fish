#!/usr/bin/fish

# Source helper library if available
if test -f /usr/local/lib/hobbylib.fish
    source /usr/local/lib/hobbylib.fish
else if test -f (status dirname)/../lib/hobbylib.fish
    source (status dirname)/../lib/hobbylib.fish
else
    function log_info; echo "[INFO]  $argv"; end
    function log_error; echo "[ERROR] $argv" >&2; end
end

# 1. Enable 32-bit architecture for Proton / Wine / Steam / Heroic
log_info "Enabling i386 foreign architecture..."
sudo dpkg --add-architecture i386

# 2. Update package lists
log_info "Updating package lists..."
sudo nala update

# 3. Install kernel headers for DKMS module compilation
log_info "Installing kernel headers..."
sudo nala install -y linux-headers-(uname -r) linux-headers-amd64

# 4. Install driver and 32-bit graphics/vulkan runtime
log_info "Installing NVIDIA proprietary driver and 32-bit libraries..."
sudo nala install -y \
    nvidia-driver \
    nvidia-driver-libs:i386 \
    libvulkan1 \
    libvulkan1:i386

log_info "NVIDIA setup complete! Please reboot to load the driver."
