# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'System & GPU Acceleration Performance Tuning' do
  let(:sysctl_path) { 'config/includes.chroot/etc/sysctl.d/80-system-performance.conf' }

  it 'provisions sysctl configuration with max_map_count and split_lock_mitigate' do
    expect(File.exist?(sysctl_path)).to be true
    content = File.read(sysctl_path)
    expect(content).to match(/vm\.max_map_count\s*=\s*2147483642/)
    expect(content).to match(/kernel\.split_lock_mitigate\s*=\s*0/)
    expect(content).to match(/vm\.dirty_ratio\s*=\s*10/)
    expect(content).to match(/vm\.dirty_background_ratio\s*=\s*5/)
  end
end
