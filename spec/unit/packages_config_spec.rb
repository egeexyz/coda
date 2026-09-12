# frozen_string_literal: true

require 'spec_helper'
require 'yaml'

RSpec.describe 'Calamares Packages Configuration' do

  it 'provisions fwupd.conf with uefi-dbx and msr plugins disabled' do
    fwupd_conf = 'config/includes.chroot/etc/fwupd/fwupd.conf'
    expect(File.exist?(fwupd_conf)).to be true
    content = File.read(fwupd_conf)
    expect(content).to match(/DisabledPlugins=.*uefi-dbx/)
    expect(content).to match(/DisabledPlugins=.*msr/)
  end

  it 'provisions broad hardware firmware and cpu microcode in hobby package list' do
    hobby_list = 'config/package-lists/hobby.list.chroot'
    expect(File.exist?(hobby_list)).to be true
    content = File.read(hobby_list)
    expect(content).to match(/^amd64-microcode$/)
    expect(content).to match(/^intel-microcode$/)
    expect(content).to match(/^firmware-linux-nonfree$/)
    expect(content).to match(/^firmware-intel-sound$/)
    expect(content).to match(/^firmware-libertas$/)
    expect(content).to match(/^firmware-ti-connectivity$/)
    expect(content).to match(/^intel-media-va-driver-non-free$/)
  end

  it 'provisions linux filesystem utilities in hobby package list for live and installed systems' do
    hobby_list = 'config/package-lists/hobby.list.chroot'
    expect(File.exist?(hobby_list)).to be true
    content = File.read(hobby_list)
    expect(content).to match(/^btrfs-progs$/)
    expect(content).to match(/^f2fs-tools$/)
    expect(content).to match(/^udftools$/)
    expect(content).to match(/^xfsprogs$/)
    expect(content).to match(/^e2fsprogs$/)
    expect(content).to match(/^dosfstools$/)
  end
end


