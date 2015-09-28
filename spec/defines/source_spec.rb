require 'spec_helper'

RSpec.describe 'chocolatey::source', :type => :define do
  let (:title) { 'choco_source' }

  context 'with older choco installed' do
    let(:facts) {
      {
        :chocolateyversion  => '0.9.8.33',
        :choco_install_path => 'C:\ProgramData\chocolatey',
      }
    }

    context "ensure => present" do
      let(:params) { {
        :ensure       => 'present',
        :source_name  => 'somewhere',
        :location     => 'this',
      } }

      it 'should compile successfully' do
        catalogue
      end

      it { is_expected.not_to contain_exec('chocolatey_source_somewhere_add') }
      it { is_expected.not_to contain_exec('chocolatey_source_somewhere_enable') }
      it { is_expected.not_to contain_exec('chocolatey_source_somewhere_remove') }
      it { is_expected.not_to contain_exec('chocolatey_source_somewhere_disable') }
    end

    context "ensure => absent" do
      let(:params) { {
        :ensure       => 'absent',
        :source_name  => 'somewhere',
      } }

      it 'should compile successfully' do
        catalogue
      end

      it { is_expected.not_to contain_exec('chocolatey_source_somewhere_add') }
      it { is_expected.not_to contain_exec('chocolatey_source_somewhere_enable') }
      it { is_expected.not_to contain_exec('chocolatey_source_somewhere_remove') }
      it { is_expected.not_to contain_exec('chocolatey_source_somewhere_disable') }
    end

    context "enable => false" do
      let(:params) { {
        :ensure       => 'present',
        :source_name  => 'somewhere',
        :enable       => false,
      } }

      it 'should compile successfully' do
        catalogue
      end

      it { is_expected.not_to contain_exec('chocolatey_source_somewhere_add') }
      it { is_expected.not_to contain_exec('chocolatey_source_somewhere_enable') }
      it { is_expected.not_to contain_exec('chocolatey_source_somewhere_remove') }
      it { is_expected.not_to contain_exec('chocolatey_source_somewhere_disable') }
    end
  end

  context 'without choco installed' do
    let(:facts) {
      {
        :chocolateyversion  => '0',
        :choco_install_path => 'C:\ProgramData\chocolatey',
      }
    }
    context "ensure => present" do
      let(:params) { {
        :ensure       => 'present',
        :source_name  => 'somewhere',
        :location     => 'this',
      } }

      it 'should compile successfully' do
        catalogue
      end

      it { is_expected.to contain_exec('chocolatey_source_somewhere_add') }
      it { is_expected.to contain_exec('chocolatey_source_somewhere_enable') }
      it { is_expected.not_to contain_exec('chocolatey_source_somewhere_remove') }
      it { is_expected.not_to contain_exec('chocolatey_source_somewhere_disable') }
    end

    context "ensure => absent" do
      let(:params) { {
        :ensure       => 'absent',
        :source_name  => 'somewhere',
      } }

      it 'should compile successfully' do
        catalogue
      end

      it { is_expected.not_to contain_exec('chocolatey_source_somewhere_add') }
      it { is_expected.not_to contain_exec('chocolatey_source_somewhere_enable') }
      it { is_expected.to contain_exec('chocolatey_source_somewhere_remove') }
      it { is_expected.not_to contain_exec('chocolatey_source_somewhere_disable') }
    end

    context "enable => false" do
      let(:params) { {
        :ensure       => 'present',
        :source_name  => 'somewhere',
        :enable       => false,
      } }

      it 'should compile successfully' do
        catalogue
      end

      it { is_expected.not_to contain_exec('chocolatey_source_somewhere_add') }
      it { is_expected.not_to contain_exec('chocolatey_source_somewhere_enable') }
      it { is_expected.not_to contain_exec('chocolatey_source_somewhere_remove') }
      it { is_expected.to contain_exec('chocolatey_source_somewhere_disable') }
    end


  end

  context 'with choco.exe installed' do
    let(:facts) {
      {
        :chocolateyversion  => '0.9.9.8',
        :choco_install_path => 'C:\ProgramData\chocolatey',
      }
    }

    context "ensure => present" do
      let(:params) { {
        :ensure       => 'present',
        :source_name  => 'somewhere',
        :location     => 'this',
      } }

      it 'should compile successfully' do
        catalogue
      end

      it { is_expected.to contain_exec('chocolatey_source_somewhere_add') }
      it { is_expected.to contain_exec('chocolatey_source_somewhere_enable') }
      it { is_expected.not_to contain_exec('chocolatey_source_somewhere_remove') }
      it { is_expected.not_to contain_exec('chocolatey_source_somewhere_disable') }
    end

    context "ensure => absent" do
      let(:params) { {
        :ensure       => 'absent',
        :source_name  => 'somewhere',
      } }

      it 'should compile successfully' do
        catalogue
      end

      it { is_expected.not_to contain_exec('chocolatey_source_somewhere_add') }
      it { is_expected.not_to contain_exec('chocolatey_source_somewhere_enable') }
      it { is_expected.to contain_exec('chocolatey_source_somewhere_remove') }
      it { is_expected.not_to contain_exec('chocolatey_source_somewhere_disable') }
    end

    context "enable => false" do
      let(:params) { {
        :ensure       => 'present',
        :source_name  => 'somewhere',
        :enable       => false,
      } }

      it 'should compile successfully' do
        catalogue
      end

      it { is_expected.not_to contain_exec('chocolatey_source_somewhere_add') }
      it { is_expected.not_to contain_exec('chocolatey_source_somewhere_enable') }
      it { is_expected.not_to contain_exec('chocolatey_source_somewhere_remove') }
      it { is_expected.to contain_exec('chocolatey_source_somewhere_disable') }
    end
  end
end
