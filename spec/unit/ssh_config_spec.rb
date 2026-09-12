# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'SSH Configuration & Bootstrapping' do
  let(:sshd_hardened_path) { 'config/includes.chroot/etc/ssh/sshd_config.d/99-hobby-hardened.conf' }
  let(:skel_ssh_config_path) { 'config/includes.chroot/etc/skel/.ssh/config' }
  let(:skel_authorized_keys_path) { 'config/includes.chroot/etc/skel/.ssh/authorized_keys' }
  let(:ssh_override_path) { 'config/includes.chroot/etc/systemd/system/ssh.service.d/override.conf' }

  it 'provisions hardened sshd server drop-in' do
    expect(File.exist?(sshd_hardened_path)).to be true
    content = File.read(sshd_hardened_path)
    expect(content).to match(/PermitRootLogin\s+no/)
    expect(content).to match(/PubkeyAuthentication\s+yes/)
    expect(content).to match(/X11Forwarding\s+no/)
    expect(content).to match(/MaxAuthTries\s+\d+/)
  end

  it 'provisions skeleton user ~/.ssh config and authorized_keys' do
    expect(File.exist?(skel_ssh_config_path)).to be true
    expect(File.exist?(skel_authorized_keys_path)).to be true

    config_content = File.read(skel_ssh_config_path)
    expect(config_content).to match(/AddKeysToAgent\s+yes/)
    expect(config_content).to match(/ServerAliveInterval\s+60/)
  end

  it 'ensures systemd automatically generates fresh host keys on boot' do
    expect(File.exist?(ssh_override_path)).to be true
    override_content = File.read(ssh_override_path)
    expect(override_content).to match(/ssh-keygen\s+-A/)
  end
end
