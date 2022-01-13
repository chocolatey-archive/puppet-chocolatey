# frozen_string_literal: true

require 'spec_helper'
require_relative '../../tasks/outdated.rb'

describe ChocolateyOutdatedTask do
  subject { described_class.new.task }

  before(:each) do
    sucess_status = double
    allow(sucess_status).to receive(:==).with(0).and_return(true)
    allow(sucess_status).to receive(:exited?).and_return(true)
    allow(sucess_status).to receive(:exitstatus).and_return(0)
    allow(Open3).to receive(:capture2).with('choco', 'outdated', '--no-color', '--limit-output').and_return([<<~OUTPUT, sucess_status])
    puppet-bolt|3.20.0|3.21.0|false
    OUTPUT
  end

  it { is_expected.to eq({ status: [{ package: 'puppet-bolt', version: '3.20.0', available_version: '3.21.0', pinned: false }] }) }
end
