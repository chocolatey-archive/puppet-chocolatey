# frozen_string_literal: true

require 'spec_helper'
require_relative '../../tasks/pin'

describe ChocolateyPinTask do
  subject { described_class.new.task(action: action, package: package, version: version) }

  let(:package) { nil }
  let(:version) { nil }

  let(:sucess_status) do
    res = double
    allow(res).to receive(:==).with(0).and_return(true)
    allow(res).to receive_messages(exited?: true, exitstatus: 0)
    res
  end

  context 'when action=list' do
    let(:action) { 'list' }

    before(:each) do
      allow(Open3).to receive(:capture2).with('choco', 'pin', 'list', '--no-color', '--limit-output').and_return([<<~OUTPUT, sucess_status])
        puppet-bolt|3.20.0
      OUTPUT
    end

    it { is_expected.to eq({ status: [{ package: 'puppet-bolt', version: '3.20.0' }] }) }
  end

  context 'when action=add' do
    let(:action) { 'add' }
    let(:package) { 'puppet-bolt' }

    context 'without version' do
      before(:each) { allow(Open3).to receive(:capture2).with('choco', 'pin', 'add', '--no-color', '--limit-output', '--name', 'puppet-bolt').and_return(['', sucess_status]) }

      it { is_expected.to eq(nil) }
    end

    context 'with version' do
      let(:version) { '3.21.0' }

      before(:each) { allow(Open3).to receive(:capture2).with('choco', 'pin', 'add', '--no-color', '--limit-output', '--name', 'puppet-bolt', '--version', '3.21.0').and_return(['', sucess_status]) }

      it { is_expected.to eq(nil) }
    end
  end

  context 'when action=remove' do
    let(:action) { 'remove' }
    let(:package) { 'puppet-bolt' }

    context 'without version' do
      before(:each) { allow(Open3).to receive(:capture2).with('choco', 'pin', 'remove', '--no-color', '--limit-output', '--name', 'puppet-bolt').and_return(['', sucess_status]) }

      it { is_expected.to eq(nil) }
    end

    context 'with version' do
      let(:version) { '3.21.0' }

      before(:each) do
        allow(Open3).to receive(:capture2).with('choco', 'pin', 'remove', '--no-color', '--limit-output', '--name', 'puppet-bolt', '--version', '3.21.0').and_return(['', sucess_status])
      end

      it { is_expected.to eq(nil) }
    end
  end
end
