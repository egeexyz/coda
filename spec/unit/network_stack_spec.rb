# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Network, Printing & Inter-Device Stack Configuration' do
  let(:nm_iwd_conf) { 'config/includes.chroot/etc/NetworkManager/conf.d/10-wifi-iwd.conf' }
  let(:nm_resolved_conf) { 'config/includes.chroot/etc/NetworkManager/conf.d/20-resolved.conf' }
  let(:sysctl_net_conf) { 'config/includes.chroot/etc/sysctl.d/85-network-performance.conf' }

  it 'configures NetworkManager with iwd Wi-Fi backend and systemd-resolved DNS' do
    expect(File.exist?(nm_iwd_conf)).to be true
    expect(File.read(nm_iwd_conf)).to match(/wifi\.backend=iwd/)

    expect(File.exist?(nm_resolved_conf)).to be true
    expect(File.read(nm_resolved_conf)).to match(/dns=systemd-resolved/)
  end

  it 'tunes kernel TCP/IP performance with BBR congestion control, FQ qdisc, and TFO' do
    expect(File.exist?(sysctl_net_conf)).to be true
    content = File.read(sysctl_net_conf)

    expect(content).to match(/net\.core\.default_qdisc\s*=\s*fq/)
    expect(content).to match(/net\.ipv4\.tcp_congestion_control\s*=\s*bbr/)
    expect(content).to match(/net\.ipv4\.tcp_fastopen\s*=\s*3/)
    expect(content).to match(/net\.ipv4\.tcp_mtu_probing\s*=\s*1/)
  end
end
