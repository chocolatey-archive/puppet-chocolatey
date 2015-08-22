require 'spec_helper'

RSpec.describe 'chocolatey' do

  let(:facts) {
    {
      :choco_version      => '0.9.9.8',
      :choco_install_path => 'C:\ProgramData\chocolatey',
    }
  }

  context 'contains config.pp with' do
    [true, false].each do |param_value|
      feature_enable = 'enable'
      feature_enable = 'disable' if !param_value

      context "enable_autouninstaller => #{param_value}" do
        let(:params) {{ :enable_autouninstaller => param_value }}

        it { is_expected.to contain_exec("chocolatey_autouninstaller_#{feature_enable}") }

        it {
          is_expected.to contain_exec("chocolatey_autouninstaller_#{feature_enable}").with_command("C:\\ProgramData\\chocolatey\\bin\\choco.exe feature -r #{feature_enable} -n autoUninstaller")
        }
      end
    end
  end
end
