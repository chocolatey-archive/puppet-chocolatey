require 'spec_helper_acceptance'

describe 'Chocolatey features' do
  context 'MODULES-3034 Disable an Already Disabled Feature' do

    before(:all) do
      backup_config
    end

    after(:all) do
      reset_config
    end

    chocolatey_src = <<-PP
      chocolateyfeature {'failOnAutoUninstaller':
        ensure => disabled,
      }
    PP

    windows_agents.each do | agent |
      it 'should verify the features is disabled' do
        on(agent, config_content_command) do | result |
          assert_match(/false/, get_xml_value("//features/feature[@name='failOnAutoUninstaller']/@enabled", result.output).to_s, 'Was not disabled by default, please adjust test to find another value.')
        end
      end

      it 'Should apply the manifest to disable the feature' do
        execute_manifest_on(agent, chocolatey_src, :catch_failures => true)
      end

      it 'should verify the feature is still disabled' do
        on(agent, config_content_command) do | result |
          assert_match(/false/, get_xml_value("//features/feature[@name='failOnAutoUninstaller']/@enabled", result.output).to_s, 'Was not found disabled')
        end
      end
    end
  end

  context 'MODULES-3034 Disable an Enabled Feature' do

    before(:all) do
      backup_config
    end

    after(:all) do
      reset_config
    end

    chocolatey_src = <<-PP
      chocolateyfeature {'checksumFiles':
        ensure => disabled,
      }
    PP

    windows_agents.each do | agent |
      it 'should validate the feature is enabled' do
        on(agent, config_content_command) do | result |
          assert_match(/true/, get_xml_value("//features/feature[@name='checksumFiles']/@enabled", result.output).to_s, 'Was not enabled by default, please adjust test to find another value.')
        end
      end

      it 'should apply the manifest to disable the feature' do
        execute_manifest_on(agent, chocolatey_src)
      end

      it 'should validate the feature is now disabled' do
        on(agent, config_content_command) do | result |
          assert_match(/false/, get_xml_value("//features/feature[@name='checksumFiles']/@enabled", result.output).to_s, 'Was not found disabled')
        end
      end
    end
  end

  context 'MODULES-3034 Enable a Disabled Feature' do
    
    before(:all) do
      backup_config
    end

    after(:all) do
      reset_config
    end

    chocolatey_src = <<-PP
      chocolateyfeature {'failOnAutoUninstaller':
        ensure => enabled,
      }
    PP

    windows_agents.each do | agent |
      it 'Should verify the feature is disabled' do
        on(agent, config_content_command) do | result |
          assert_match(/false/, get_xml_value("//features/feature[@name='failOnAutoUninstaller']/@enabled", result.output).to_s, 'Was not disabled by default, please adjust test to find another value.')
        end
      end

      it 'should apply the manifest to enable the feature' do
        execute_manifest_on(agent, chocolatey_src, :catch_failures => true)
      end

      it 'Should verify the feature is now enabled' do
        on(agent, config_content_command) do | result |
          assert_match(/true/, get_xml_value("//features/feature[@name='failOnAutoUninstaller']/@enabled", result.output).to_s, 'Was not found enabled')
        end
      end
    end
  end

  context 'MODULES-3034 - Enable Already Enabled Feature' do

    before(:all) do
      backup_config
    end

    after(:all) do
      reset_config
    end

    chocolatey_src = <<-PP
      chocolateyfeature {'usePackageExitCodes':
        ensure => enabled,
      }
    PP

    windows_agents.each do | agent |
      it 'Should verify the feature is already enabled' do
        on(agent, config_content_command) do | result |
          assert_match(/true/, get_xml_value("//features/feature[@name='usePackageExitCodes']/@enabled", result.output).to_s, 'Was not enabled by default, please adjust test to find another value.')
        end
      end

      it 'should apply the manifest to enable the feature' do
        execute_manifest_on(agent, chocolatey_src, :catch_failures => true)
      end

      it 'Should verify the feature is still enabled' do
        on(agent, config_content_command) do | result |
          assert_match(/true/, get_xml_value("//features/feature[@name='usePackageExitCodes']/@enabled", result.output).to_s, 'Was not found enabled')
        end
      end
    end
  end

  context 'MODULES-3034 - Enable a non-existent feature' do

    before(:all) do
      backup_config
    end

    after(:all) do
      reset_config
    end

    chocolatey_src = <<-PP
      chocolateyfeature {'idontexistfeature123123':
        ensure => enabled,
      }
    PP

    windows_agents.each do | agent |
      it 'Should fail to apply the manifest' do
        execute_manifest_on(agent, chocolatey_src, :expect_failures => true) do | result |
          assert_match(/returned 1: Feature 'idontexistfeature123123' not found/, result.stderr, "stderr did not match expected")
        end
      end
    end
  end

  context 'MODULES-3034 - Enable non-existent feature' do

    before(:all) do
      backup_config
    end

    after(:all) do
      reset_config
    end

    chocolatey_src = <<-PP
      chocolateyfeature {'idontexistfeature123123':
        ensure => enabled,
      }
    PP

    windows_agents.each do | agent |
      it 'Should fail to apply the manifest' do
        execute_manifest_on(agent, chocolatey_src, :expect_failures => true) do | result |
          assert_match(/returned 1: Feature 'idontexistfeature123123' not found/, result.stderr, "stderr did not match expected")
        end
      end
    end
  end

  context 'MODULES-3034 - Attempt to remove feature' do

    before(:all) do
      backup_config
    end

    after(:all) do
      reset_config
    end

    chocolatey_src = <<-PP
      chocolateyfeature {'checksumFiles':
        ensure => absent,
      }
    PP

    windows_agents.each do | agent |
      it 'Should fail to apply the manifest' do
        execute_manifest_on(agent, chocolatey_src, :expect_failures => true) do | result |
          assert_match(/Error: Parameter ensure failed on Chocolateyfeature\[checksumFiles\]: Invalid value \"absent\"/, result.stderr, "stderr did not match expected")
        end
      end
    end
  end
end

