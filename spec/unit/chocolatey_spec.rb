# vim: set ts=2 sw=2 ai et ruler:
require 'spec_helper'
require 'stringio'

provider = Puppet::Type.type(:package).provider(:chocolatey)

describe provider do

  let (:chocolatey) {'c:\blah\chocolatey.cmd'}

  before(:each) do
    ENV['ChocolateyInstall'] = 'c:\blah'

    @resource = Puppet::Type.type(:package).new(
      :name     => 'chocolatey',
      :ensure   => :present,
      :provider => :chocolatey
    )
    @provider = provider.new(@resource)

    # Stub all file and config tests
    provider.stubs(:healthcheck)
  end

  it "should have an install method" do
    @provider.should respond_to(:install)
  end

  it "should have a latest method" do
    @provider.should respond_to(:uninstall)
  end

  it "should have an update method" do
    @provider.should respond_to(:update)
  end

  it "should have a latest method" do
    @provider.should respond_to(:latest)
  end

  context "parameter :source" do
    it "should default to nil" do
      @resource[:source].should be_nil
    end

    it "should accept c:\\packages" do
      @resource[:source] = 'c:\packages'
    end

    it "should accept http://somelocation/packages" do
      @resource[:source] = 'http://somelocation/packages'
    end
  end

  describe "when installing" do
    it "should use a command without versioned package" do
      @resource[:ensure] = :latest
      @provider.expects(:chocolatey).with('install', 'chocolatey', nil)
      @provider.install
    end

    it "should use source if it is specified" do
      @resource[:source] = 'c:\packages'
      @provider.expects(:chocolatey).with('install','chocolatey', nil, '-source', 'c:\packages')
      @provider.install
    end
  end

  describe "when uninstalling" do
    it "should call the remove operation" do
      @provider.expects(:chocolatey).with('uninstall', 'chocolatey', nil)
      @provider.uninstall
    end
  end

  describe "when updating" do
    it "should use a command without versioned package" do
      @provider.expects(:chocolatey).with('update', 'chocolatey', nil)
      @provider.update
    end

    it "should use source if it is specified" do
      @resource[:source] = 'c:\packages'
      @provider.expects(:chocolatey).with('update','chocolatey', nil, '-source', 'c:\packages')
      @provider.update
    end
  end

  describe "query" do
    it "should return a hash when chocolatey and the package are present" do
      provider.expects(:instances).returns [provider.new({
        :ensure   => "1.2.5",
        :name     => "chocolatey",
        :provider => :chocolatey,
      })]

      @provider.query.should == {
        :ensure   => "1.2.5",
        :name     => "chocolatey",
        :provider => :chocolatey,
      }
    end

    it "should return nil when the package is missing" do
      provider.expects(:instances).returns []
      @provider.query.should == nil
    end
  end

  describe "when fetching a package list" do
    it "should invoke provider listcmd" do
      provider.expects(:listcmd)
      provider.instances
    end

    it "should query chocolatey" do
      provider.expects(:execpipe).with() do |args|
        args[1] =~ /list/
        args[2] =~ /-lo/
      end
      provider.instances
    end

    it "should return installed packages with their versions" do
      provider.expects(:execpipe).yields(StringIO.new(%Q(package1 1.23\n\package2 2.00\n)))
      packages = (provider.instances)

      packages.length.should == 2

      packages[0].properties.should == {
        :provider => :chocolatey,
        :ensure => "1.23",
        :name => 'package1'
      }

      packages[1].properties.should == {
        :provider => :chocolatey,
        :ensure => "2.00",
        :name => 'package2'
      }
    end

    it "should return nil on error" do
      provider.expects(:execpipe).raises(Puppet::ExecutionFailure.new("ERROR!"))
      provider.instances.should be_nil
    end

  end
end
