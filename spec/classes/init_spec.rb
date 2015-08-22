require 'spec_helper'

describe 'chocolatey' do

  [{},{:chocolatey_download_url => 'https://somewhere'}].each do |params|
    context "#{params}" do
      let(:params) { params }

      it 'should have a catalogue' do
        catalogue
      end
      #it { is_expected.to compile }
      #it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_class('chocolatey') }
      it { is_expected.to contain_class('chocolatey::params') }
      it { is_expected.to contain_class('chocolatey::install') }
      it { is_expected.to contain_class('chocolatey::config') }
    end
  end
end
