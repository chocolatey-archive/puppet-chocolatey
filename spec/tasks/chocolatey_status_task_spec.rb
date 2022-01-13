# frozen_string_literal: true

require 'spec_helper'
require_relative '../../tasks/status.rb'

describe ChocolateyStatusTask do
  subject { described_class.new.task }

  before(:each) do
    sucess_status = double
    allow(sucess_status).to receive(:==).with(0).and_return(true)
    allow(sucess_status).to receive(:exited?).and_return(true)
    allow(sucess_status).to receive(:exitstatus).and_return(0)
    allow(Open3).to receive(:capture2).with('choco', 'list', '--local-only', '--no-color', '--limit-output').and_return([<<~OUTPUT, sucess_status])
    chocolatey|0.11.3
    puppet-bolt|3.20.0
    OUTPUT
  end

  it { is_expected.to eq({ status: [{ package: 'chocolatey', version: '0.11.3' }, { package: 'puppet-bolt', version: '3.20.0' }] }) }
end
