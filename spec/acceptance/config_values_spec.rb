require 'spec_helper_acceptance'

describe 'Chocolatey Config' do

  context 'MODULES-3035 - Add New Config Item' do

    before(:all) do
      backup_config
    end

    after(:all) do
      reset_config
    end

    chocolatey_src = <<-PP
      chocolateyconfig {'hello123':
        ensure => present,
        value  => 'this guy',
      }
    PP

    it_behaves_like 'a successful config change', chocolatey_src, 'hello123', /this guy/
  end

  context 'MODULES-3035 - Add a Value to an Existing Config Setting' do

    before(:all) do
      backup_config
    end

    after(:all) do
      reset_config
    end

    chocolatey_src = <<-PP
      chocolateyconfig {'proxy':
        ensure => present,
        value  => 'https://somewhere',
      }
    PP
    
    it_behaves_like 'a successful config change', chocolatey_src, 'proxy', /https\:\/\/somewhere/
  end

  context 'MODULES-3035 - Config Settings Change Config Value' do

    before(:all) do
      backup_config
    end

    after(:all) do
      reset_config
    end

    chocolatey_src = <<-PP
      chocolateyconfig {'proxyUser':
        value => 'bob',
      }
    PP

    chocolatey_src_change = <<-PP
      chocolateyconfig {'proxyuser':
        value => 'tim',
      }
    PP

    # Add the config item
    it_behaves_like 'a successful config change', chocolatey_src, 'proxyUser', /bob/

    # Now that it exists, change its value
    it_behaves_like 'a successful config change', chocolatey_src_change, 'proxyUser', /tim/
  end

  context 'MODULES-3035 Ensure Config Value with Password In Name' do

    before(:all) do
      backup_config
    end

    after(:all) do
      reset_config
    end

    chocolatey_src = <<-PP
      chocolateyconfig {'proxyPassword':
        value => 'secrect',
      }
    PP

    chocolatey_src_change = <<-PP
      chocolateyconfig {'proxyPassword':
        value => 'secrect2',
      }
    PP

    # The password should set one time and then not change.
    it_behaves_like 'a password that doesn\'t change', chocolatey_src, chocolatey_src_change, 'proxyPassword'
  end

  context 'MODULES-3035 - Fail to Set Present With No Value' do

    before(:all) do
      backup_config
    end

    after(:all) do
      reset_config
    end

    chocolatey_src = <<-PP
      chocolateyconfig {'bob':
        ensure => present,
      }
    PP

    expected_error = /Unless ensure => absent, value is required./

    # A manifest with present set, but no values to enforce should not run.
    it_behaves_like 'a failing manifest', chocolatey_src, expected_error
  end

  context 'MODULES-3035 - Config Settings Remove Value with Password in the Name' do

    before(:all) do
      backup_config
    end

    after(:all) do
      reset_config
    end

    chocolatey_src = <<-PP
      chocolateyconfig {'proxyPassword':
        value => 'secret',
      }
    PP

    chocolatey_src_change = <<-PP
      chocolateyconfig {'proxyPassword':
        ensure => absent,
      }
    PP

    # The password will end up a hash, so we specify a regex that just verifies a hash exists.
    it_behaves_like 'a successful config change', chocolatey_src, 'proxyPassword', /(.+)/

    it_behaves_like 'a manifest that removes a config value', chocolatey_src_change, 'proxyPassword'
  end

  context 'MODULES-3035 - Remove Value from Config Setting' do

    before(:all) do
      backup_config
    end

    after(:all) do
      reset_config
    end

    chocolatey_src = <<-PP
      chocolateyconfig {'commandExecutionTimeoutSeconds':
        ensure => absent,
      }
    PP

    it_behaves_like 'a manifest that removes a config value', chocolatey_src, 'commandExecutionTimeoutSeconds'
  end
end

