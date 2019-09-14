require 'spec_helper'

describe 'chocolatey' do
  let(:facts) do
    {
      chocolateyversion: '0.9.9.8',
      choco_install_path: 'C:\ProgramData\chocolatey',
      path: 'C:\something',
    }
  end

  [{}].each do |params|
    context params.to_s do
      let(:params) { params }

      it 'compiles successfully' do
        catalogue
      end

      # it { is_expected.to compile }
      # it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_class('chocolatey') }
      it { is_expected.to contain_class('chocolatey::params') }
      it { is_expected.to contain_class('chocolatey::install') }
      it { is_expected.to contain_class('chocolatey::config') }
    end
  end

  context 'accepts install_proxy parameter' do
    let(:params) do
      {
        install_proxy: 'http://proxy.megacorp.com:3128',
      }
    end

    it 'compiles successfully' do
      catalogue
    end
  end

  context 'chocolatey_download_url =>' do
    ['https://chocolatey.org/api/v2/package/chocolatey/', 'http://location', 'file:///c:/somwhere/chocolatey.nupkg', '\\\\ciflocation\\share'].each do |param_value|
      context param_value.to_s do
        let(:params) do
          {
            chocolatey_download_url: param_value,
          }
        end

        it 'compiles successfully' do
          catalogue
        end
      end
    end

    invalid_url_values = ['bob', '4', '']
    not_a_string_values = [false, 3]

    invalid_url_values.each do |param_value|
      context "#{param_value} (invalid scenario)" do
        let(:params) do
          {
            chocolatey_download_url: param_value,
          }
        end

        let(:error_message) { %r{Stdlib::Filesource} }

        it {
          expect { catalogue }.to raise_error(Puppet::Error, error_message)
        }
      end
    end

    not_a_string_values.each do |param_value|
      context "#{param_value} (invalid scenario)" do
        let(:params) do
          {
            chocolatey_download_url: param_value,
          }
        end

        let(:error_message) { %r{Stdlib::Filesource} }

        it {
          expect { catalogue }.to raise_error(Puppet::Error, error_message)
        }
      end
    end
  end

  context 'choco_install_location =>' do
    ['C:\\ProgramData\\chocolatey', 'D:\\somewhere'].each do |param_value|
      context param_value.to_s do
        let(:params) do
          {
            choco_install_location: param_value,
          }
        end

        it 'compiles successfully' do
          catalogue
        end
      end
    end

    [1, false].each do |param_value|
      context "#{param_value} (invalid scenario)" do
        let(:params) do
          {
            choco_install_location: param_value,
          }
        end

        let(:error_message) { %r{Stdlib::Windowspath} }

        it {
          expect { catalogue }.to raise_error(Puppet::Error, error_message)
        }
      end
    end

    ['https://somewhere', '\\\\overhere', ''].each do |param_value|
      context "#{param_value} (invalid scenario)" do
        let(:params) do
          {
            choco_install_location: param_value,
          }
        end

        let(:error_message) { %r{Stdlib::Windowspath} }

        it {
          expect { catalogue }.to raise_error(Puppet::Error, error_message)
        }
      end
    end
  end

  context 'choco_install_timeout_seconds =>' do
    [1500, 8000].each do |param_value|
      context param_value.to_s do
        let(:params) do
          {
            choco_install_timeout_seconds: param_value,
          }
        end

        it 'compiles successfully' do
          catalogue
        end
      end
    end

    ['string', false, '', '1', '30'].each do |param_value|
      context "#{param_value} (invalid scenario)" do
        let(:params) do
          {
            choco_install_timeout_seconds: param_value,
          }
        end

        let(:error_message) { %r{expects an Integer value} }

        it {
          expect { catalogue }.to raise_error(Puppet::Error, error_message)
        }
      end
    end
  end

  ['use_7zip', 'enable_autouninstaller'].each do |boolean_param|
    context "#{boolean_param} =>" do
      [true, false].each do |param_value|
        context param_value.to_s do
          let(:params) do
            {
              boolean_param.to_sym => param_value,
            }
          end

          it 'compiles successfully' do
            catalogue
          end
        end
      end

      ['true', 'false', 'bob', 3, '4', ''].each do |param_value|
        context "#{param_value} (invalid scenario)" do
          let(:params) do
            {
              boolean_param.to_sym => param_value,
            }
          end

          let(:error_message) { %r{expects a Boolean value} }

          it {
            expect { catalogue }.to raise_error(Puppet::Error, error_message)
          }
        end
      end
    end
  end
end
