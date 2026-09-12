# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'System & GPU Acceleration Performance Tuning' do
  let(:sysctl_path) { 'config/includes.chroot/etc/sysctl.d/80-system-performance.conf' }

  it 'provisions sysctl configuration with max_map_count and split_lock_mitigate' do
    expect(File.exist?(sysctl_path)).to be true
    content = File.read(sysctl_path)
    expect(content).to match(/vm\.max_map_count\s*=\s*2147483642/)
    expect(content).to match(/kernel\.split_lock_mitigate\s*=\s*0/)
    expect(content).to match(/vm\.dirty_bytes\s*=\s*268435456/)
    expect(content).to match(/vm\.dirty_background_bytes\s*=\s*67108864/)
  end
end
