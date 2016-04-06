require 'facter'

describe 'choco_install_path fact' do
  subject(:fact) { Facter.fact(:choco_install_path) }

  context 'on Windows', :if => Puppet::Util::Platform.windows? do
    it "should return install path from registry if it exists" do
      expected_value = 'C:\somewhere'
      Win32::Registry.any_instance.expects(:[]).with('ChocolateyInstall').returns(expected_value)

      subject.value.must == expected_value
    end

    it "should return the default install path if environment variable does not exist" do
      expected_value = 'C:\ProgramData\chocolatey'
      Win32::Registry.any_instance.expects(:[]).with('ChocolateyInstall').raises(Win32::Registry::Error.new(2), 'file not found yo')

      subject.value.must == expected_value
    end
  end

  context 'on Linux', :if => Puppet.features.posix? do
    it "should return the default install path on a non-windows system" do
      subject.value.must == 'C:\ProgramData\chocolatey'
    end
  end

  after :each do
    Facter.clear
    Facter.clear_messages
  end
end
