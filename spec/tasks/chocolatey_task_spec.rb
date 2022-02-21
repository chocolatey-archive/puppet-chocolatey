# frozen_string_literal: true

require 'spec_helper'
require_relative '../../tasks/init.rb'

describe ChocolateyTask do
  subject { described_class.new.task(action: action, package: package, version: version) }

  let(:package) { 'puppet-bolt' }
  let(:version) { nil }

  let(:sucess_status) do
    res = double
    allow(res).to receive(:==).with(0).and_return(true)
    allow(res).to receive(:exited?).and_return(true)
    allow(res).to receive(:exitstatus).and_return(0)
    res
  end

  context 'when action=install' do
    let(:action) { 'install' }

    context 'without version' do
      before(:each) do
        allow(Open3).to receive(:capture2).with('choco', 'install', 'puppet-bolt', '--yes', '--no-color', '--no-progress').and_return(['', sucess_status])
      end

      it { is_expected.to eq(nil) }
    end

    context 'with version' do
      let(:version) { '3.21.0' }

      before(:each) do
        allow(Open3).to receive(:capture2).with('choco', 'install', 'puppet-bolt', '--yes', '--no-color', '--no-progress', '--version', '3.21.0').and_return(['', sucess_status])
      end

      it { is_expected.to eq(nil) }
    end
  end

  context 'when action=upgrade' do
    let(:action) { 'upgrade' }

    context 'without version' do
      before(:each) do
        allow(Open3).to receive(:capture2).with('choco', 'upgrade', 'puppet-bolt', '--yes', '--no-color', '--no-progress').and_return(['', sucess_status])
      end

      it { is_expected.to eq(nil) }
    end

    context 'with version' do
      let(:version) { '3.21.0' }

      before(:each) do
        allow(Open3).to receive(:capture2).with('choco', 'upgrade', 'puppet-bolt', '--yes', '--no-color', '--no-progress', '--version', '3.21.0').and_return(['', sucess_status])
      end

      it { is_expected.to eq(nil) }
    end
  end

  context 'when action=uninstall' do
    let(:action) { 'uninstall' }

    context 'without version' do
      before(:each) do
        allow(Open3).to receive(:capture2).with('choco', 'uninstall', 'puppet-bolt', '--yes', '--no-color', '--no-progress').and_return(['', sucess_status])
      end

      it { is_expected.to eq(nil) }
    end

    context 'with version' do
      let(:version) { '3.21.0' }

      before(:each) do
        allow(Open3).to receive(:capture2).with('choco', 'uninstall', 'puppet-bolt', '--yes', '--no-color', '--no-progress', '--version', '3.21.0').and_return(['', sucess_status])
      end

      it { is_expected.to eq(nil) }
    end
  end
end
