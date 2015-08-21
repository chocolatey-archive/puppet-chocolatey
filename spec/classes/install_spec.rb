require 'spec_helper'

RSpec.describe 'chocolatey' do
  context 'contains install.pp with' do
    it { is_expected.to contain_windows_env('chocolatey_ChocolateyInstall_env').with_ensure('present') }
    it { is_expected.to contain_windows_env('chocolatey_ChocolateyInstall_env').with_variable('ChocolateyInstall') }
    it { is_expected.to contain_windows_env('chocolatey_ChocolateyInstall_env').that_notifies('Exec[install_chocolatey_official]') }

    it { is_expected.to contain_windows_env('chocolatey_PATH_env').with_ensure('present') }
    it { is_expected.to contain_windows_env('chocolatey_PATH_env').with_variable('PATH') }
    it { is_expected.to contain_windows_env('chocolatey_PATH_env').that_notifies('Exec[install_chocolatey_official]') }

    ['c:\local_folder', "C:\\ProgramData\\chocolatey"].each do |param_value|
        context "choco_install_location => #{param_value}" do
        let(:params) {{ :choco_install_location => param_value }}

        it { is_expected.to contain_exec('install_chocolatey_official').with_creates("#{param_value}\\bin\\choco.exe") }
        it { is_expected.to contain_windows_env('chocolatey_ChocolateyInstall_env').with_value("#{param_value}") }
        it { is_expected.to contain_windows_env('chocolatey_PATH_env').with_value("#{param_value}\\bin") }
      end
    end


    [1500, 35].each do |param_value|
      context "choco_install_timeout => #{param_value}" do
        let(:params) {{ :choco_install_timeout => param_value }}

        it { is_expected.to contain_exec('install_chocolatey_official').with_timeout("#{param_value}") }
      end
    end
  end
end
