require 'spec_helper'
require 'stringio'

provider = Puppet::Type.type(:package).provider(:chocolatey)

describe provider do
  before(:each) do
    @resource = Puppet::Type.type(:package).new(
      :name     => "chocolatey",
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


  describe "when installing" do
    it "should use a command without versioned package" do
      @resource[:ensure] = :latest
      @provider.expects(:chocolatey).with('install', 'chocolatey')
      @provider.install
    end
  end
  
	describe "when uninstalling" do
		it "should call the remove operation" do
			@provider.expects(:chocolatey).with('uninstall', 'chocolatey')
			@provider.uninstall
		end
	end
		
		
	describe "when updating" do
    it "should use a command without versioned package" do
      @provider.expects(:chocolatey).with('update', 'chocolatey')
      @provider.update
    end
  end
	
	describe "when uninstalling" do
    it "should call the remove operation" do
      @provider.expects(:chocolatey).with('uninstall', 'chocolatey')
      @provider.uninstall
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


	
end