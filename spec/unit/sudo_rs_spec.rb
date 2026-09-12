# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Sudo-rs System Configuration' do
  it 'includes sudo and sudo-rs in package list and sets up direct symlinks in chroot hook' do
    hobby_list = File.read('config/package-lists/hobby.list.chroot')
    expect(hobby_list).to match(/^sudo-rs$/)
    expect(hobby_list).to match(/^sudo$/)

    hook_content = File.read('config/hooks/live/0100-hobby-setup.hook.chroot')
    expect(hook_content).to match(%r{ln -sf /usr/bin/sudo-rs /usr/bin/sudo})
    expect(hook_content).to match(%r{ln -sf /usr/bin/sudo-rs /usr/local/bin/sudo})
    expect(hook_content).not_to match(/apt-get purge -y sudo/)
  end
end
