require 'spec_helper'

describe 'chocolatey' do
  let(:facts) do
    {
      chocolateyversion: '0.9.9.8',
      choco_install_path: 'C:\ProgramData\chocolatey',
      choco_temp_dir: 'C:\Temp',
      path: 'C:\something',
    }
  end

  context 'contains install.pp' do
    ['c:\local_folder', 'C:\\ProgramData\\chocolatey'].each do |param_value|
      context "choco_install_location => #{param_value}" do
        let(:params) { { choco_install_location: param_value } }

        it { is_expected.to contain_exec('install_chocolatey_official').with_creates("#{param_value}\\bin\\choco.exe") }
      end
    end

    [1500, 35].each do |param_value|
      context "choco_install_timeout_seconds => #{param_value}" do
        let(:params) { { choco_install_timeout_seconds: param_value } }

        it { is_expected.to contain_exec('install_chocolatey_official').with_timeout(param_value.to_s) }
      end
    end

    context 'use_7zip => false' do
      let(:params) { { use_7zip: false } }

      it {
        is_expected.not_to contain_file('C:\Temp\7za.exe')
      }
    end

    context 'use_7zip => true' do
      context 'seven_zip_download_url default' do
        let(:params) { { use_7zip: true } }

        it { is_expected.to contain_file('C:\Temp\7za.exe').with_source('https://chocolatey.org/7za.exe') }
      end
      context "seven_zip_download_url => 'https://packages.organization.net/7za.exe'" do
        let(:params) do
          {
            use_7zip: true,
            seven_zip_download_url: 'https://packages.organization.net/7za.exe',
          }
        end

        it { is_expected.to contain_file('C:\Temp\7za.exe').with_source('https://packages.organization.net/7za.exe') }
      end
    end
  end
end
