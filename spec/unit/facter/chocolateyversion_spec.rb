require 'facter'

describe 'chocolateyversion fact' do
  subject(:fact) { Facter.fact(:chocolateyversion) }

  context 'on Windows', :if => Puppet::Util::Platform.windows? do
    it "should return the value from running choco -v" do
      expected_value = '1.2.3'
      Facter::Util::Resolution.expects(:exec).returns(expected_value)

      subject.value.must == expected_value
    end

    it "should handle cleaning up spaces" do
      expected_value = '1.2.3'
      Facter::Util::Resolution.expects(:exec).returns(' ' + expected_value + ' ')

      subject.value.must == expected_value
    end

    it "should handle older versions of choco" do
      expected_value = '1.2.3'
      Facter::Util::Resolution.expects(:exec).returns('Please run chocolatey /? or chocolatey help - chocolatey v' + expected_value)

      subject.value.must == expected_value
    end
  end

  context 'on Linux', :if => Puppet.features.posix? do
    it "should return 0  on a non-windows system" do
      subject.value.must == "0"
    end
  end

  after :each do
    Facter.clear
    Facter.clear_messages
  end
end
