# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Hi-Fi Audio & Real-time Scheduling Configuration' do
  let(:limits_path) { 'config/includes.chroot/etc/security/limits.d/25-pipewire.conf' }
  let(:pipewire_conf_path) { 'config/includes.chroot/etc/pipewire/pipewire.conf.d/10-hifi.conf' }
  let(:pulse_conf_path) { 'config/includes.chroot/etc/pipewire/pipewire-pulse.conf.d/10-hifi.conf' }
  let(:hook_path) { 'config/hooks/live/0100-hobby-setup.hook.chroot' }
  let(:package_list_path) { 'config/package-lists/hobby.list.chroot' }

  it 'provisions PAM limits granting real-time scheduling priority to audio group' do
    expect(File.exist?(limits_path)).to be true
    content = File.read(limits_path)
    expect(content).to match(/@audio\s+-\s+rtprio\s+95/)
    expect(content).to match(/@audio\s+-\s+nice\s+-19/)
    expect(content).to match(/@audio\s+-\s+memlock\s+unlimited/)
  end

  it 'configures PipeWire with sample rates and resampling' do
    expect(File.exist?(pipewire_conf_path)).to be true
    content = File.read(pipewire_conf_path)
    expect(content).to match(/48000/)
    expect(content).to match(/192000/)
    expect(content).to match(/resample\.quality\s*=\s*4/)
  end

  it 'configures PipeWire-Pulse buffer parameters' do
    expect(File.exist?(pulse_conf_path)).to be true
    content = File.read(pulse_conf_path)
    expect(content).to match(/pulse\.default\.req/)
  end

  it 'purges rtkit daemon in chroot setup hook and installs pipewire-alsa' do
    hook_content = File.read(hook_path)
    expect(hook_content).to match(/apt-get purge -y rtkit/)

    packages = File.read(package_list_path)
    expect(packages).to match(/^pipewire-alsa$/)
  end
end
