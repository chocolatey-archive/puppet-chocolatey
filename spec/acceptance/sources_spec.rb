require 'spec_helper_acceptance'

describe 'Chocolatey Source' do
  context 'MODULES-3037 - Add Priority to an Existing Source' do

    before(:all) do
      backup_config
    end

    after(:all) do
      reset_config
    end

    windows_agents.each do | agent |

      it 'Should Apply the Manifest' do
        chocolatey_src = <<-PP
          chocolateysource {'chocolatey':
            ensure   => present,
            location => 'https://chocolatey.org/api/v2',
            priority => 1,
          }
        PP

        execute_manifest_on(agent, chocolatey_src, :catch_failures => true)
      end

      it 'Should now have proper priority' do
        on(agent, config_content_command) do |result|
          assert_match(/1/, get_xml_value("//sources/source[@id='chocolatey']/@priority", result.output).to_s, 'Priority did not match')
        end
      end
    end
  end

  context 'MODULES-4418 - Add Bypass Proxy to an Existing Source' do

    before(:all) do
      backup_config
    end

    after(:all) do
      reset_config
    end

    windows_agents.each do | agent |

      it 'Should Apply the Manifest' do
        chocolatey_src = <<-PP
          chocolateysource {'chocolatey':
            ensure   => present,
            location => 'https://chocolatey.org/api/v2',
            bypass_proxy => true,
          }
        PP

        execute_manifest_on(agent, chocolatey_src, :catch_failures => true)
      end

      it 'Should now bypass system proxies' do
        on(agent, config_content_command) do |result|
          assert_match(/true/, get_xml_value("//sources/source[@id='chocolatey']/@bypassProxy", result.output).to_s, 'Bypass Proxy did not match')
        end
      end
    end
  end

  context 'MODULES-5897 - Add Self Service to an Existing Source' do

    before(:all) do
      backup_config
    end

    after(:all) do
      reset_config
    end

    windows_agents.each do | agent |

      it 'Should Apply the Manifest' do
        chocolatey_src = <<-PP
          chocolateysource {'chocolatey':
            ensure             => present,
            location           => 'https://chocolatey.org/api/v2',
            allow_self_service => true,
          }
        PP

        execute_manifest_on(agent, chocolatey_src, :catch_failures => true)
      end

      it 'Should now mark the source as usable for self-service' do
        on(agent, config_content_command) do |result|
          assert_match(/true/, get_xml_value("//sources/source[@id='chocolatey']/@selfService", result.output).to_s, 'Self Service did not match')
        end
      end
    end
  end

  context 'MODULES-5898 - Add Admin Only to an Existing Source' do

    before(:all) do
      backup_config
    end

    after(:all) do
      reset_config
    end

    windows_agents.each do | agent |

      it 'Should Apply the Manifest' do
        chocolatey_src = <<-PP
          chocolateysource {'chocolatey':
            ensure   => present,
            location => 'https://chocolatey.org/api/v2',
            admin_only => true,
          }
        PP

        execute_manifest_on(agent, chocolatey_src, :catch_failures => true)
      end

      it 'Should now set the source as visible only to administrators' do
        on(agent, config_content_command) do |result|
          assert_match(/true/, get_xml_value("//sources/source[@id='chocolatey']/@adminOnly", result.output).to_s, 'Admin Only did not match')
        end
      end
    end
  end

  context 'MODULES-3037 - Add Source With All Options' do

    before(:all) do
      backup_config
    end

    after(:all) do
      reset_config
    end

    windows_agents.each do | agent |

      it 'Should Apply the Manifest' do
        chocolatey_src = <<-PP
          chocolateysource {'test':
            ensure             => present,
            location           => 'c:\\packages',
            priority           => 2,
            user               => 'bob',
            password           => 'yes',
            bypass_proxy       => true,
            allow_self_service => true,
            admin_only         => true,
          }
        PP

        execute_manifest_on(agent, chocolatey_src, :catch_failures => true)
      end

      it 'Should have the correct properties' do
        on(agent, config_content_command) do | result |
          assert_match(/c:\\packages/, get_xml_value("//sources/source[@id='test']/@value", result.output).to_s, 'Location did not match')
          assert_match(/2/, get_xml_value("//sources/source[@id='test']/@priority", result.output).to_s, 'Priority did not match')
          assert_match(/bob/, get_xml_value("//sources/source[@id='test']/@user", result.output).to_s, 'User did not match')
          assert_match(/.+/, get_xml_value("//sources/source[@id='test']/@password", result.output).to_s, 'Password was not saved')
          assert_match(/false/, get_xml_value("//sources/source[@id='test']/@disabled", result.output).to_s, 'Disabled did not match')
          assert_match(/true/, get_xml_value("//sources/source[@id='test']/@bypassProxy", result.output).to_s, 'Bypass Proxy did not match')
          assert_match(/true/, get_xml_value("//sources/source[@id='test']/@selfService", result.output).to_s, 'Self Service did not match')
          assert_match(/true/, get_xml_value("//sources/source[@id='test']/@adminOnly", result.output).to_s, 'Admin Only did not match')
        end
      end
    end
  end

  context 'MODULES-3037 - Add Source Minimal' do

    before(:all) do
      backup_config
    end

    after(:all) do
      reset_config
    end

    windows_agents.each do | agent |
      it 'Should Apply the Manifest' do
        chocolatey_src = <<-PP
          chocolateysource {'test':
            location => 'c:\\packages',
          }
        PP

        execute_manifest_on(agent, chocolatey_src, :catch_failures => true)
      end

      it 'Should verify the results' do
        on(agent, config_content_command) do |result|
          assert_match(/c:\\packages/, get_xml_value("//sources/source[@id='test']/@value", result.output).to_s, 'Location did not match')
          assert_match(/false/, get_xml_value("//sources/source[@id='test']/@disabled", result.output).to_s, 'Disabled did not match')
        end
      end
    end
  end

  context 'MODULES-3037 - Add Source Happy Path' do

    before(:all) do
      backup_config
    end

    after(:all) do
      reset_config
    end

    windows_agents.each do | agent |
      it 'Should Apply the manifest' do
        chocolatey_src = <<-PP
          chocolateysource {'test':
            ensure   => present,
            location => 'c:\\packages',
          }
        PP

        execute_manifest_on(agent, chocolatey_src, :catch_failures => true)
      end

      it 'Should verify results' do
        on(agent, config_content_command) do | result |
          assert_match(/c:\\packages/, get_xml_value("//sources/source[@id='test']/@value", result.output).to_s, 'Location did not match')
          assert_match(/false/, get_xml_value("//sources/source[@id='test']/@disabled", result.output).to_s, 'Disabled did not match')
        end
      end
    end
  end

  context 'MODULES-3037 - Add User/Password to an Existing Source' do

    before(:all) do
      backup_config
    end

    after(:all) do
      reset_config
    end

    windows_agents.each do | agent |
      it 'Should apply the manifest' do
        chocolatey_src = <<-PP
          chocolateysource {'chocolatey':
            ensure   => present,
            location => 'https://chocolatey.org/api/v2',
            user     => 'tim',
            password => 'test',
          }
        PP

        execute_manifest_on(agent, chocolatey_src, :catch_failures => true)
      end

      it 'Should verify the results' do
        on(agent, config_content_command) do |result|
          assert_match(/tim/, get_xml_value("//sources/source[@id='chocolatey']/@user", result.output).to_s, 'User did not match')
          # we are not able to verify password other than if it has a value - it will be encrypted in a non-verifyable way
          assert_match(/.+/, get_xml_value("//sources/source[@id='chocolatey']/@password", result.output).to_s, 'Password was not saved')
        end
      end
    end
  end

  context 'MODULES-3037 - Change Existing Priority' do

    before(:all) do
      backup_config
    end
    
    after(:all) do
      reset_config
    end

    windows_agents.each do | agent |
      it 'Should apply a manifest to set priority' do
        chocolatey_src = <<-PP
          chocolateysource {'chocolatey':
            ensure   => present,
            location => 'https://chocolatey.org/api/v2',
            priority => 1,
          }
        PP

        execute_manifest_on(agent, chocolatey_src, :catch_failures => true)
      end

      it 'Should verify the setup was added' do
        on(agent, config_content_command) do | result |
          assert_match(/1/, get_xml_value("//sources/source[@id='chocolatey']/@priority", result.output).to_s, 'Priority setup did not match')
        end
      end

      it 'Should apply a manifest to change the priority' do
        chocolatey_src_change = <<-PP
          chocolateysource {'chocolatey':
            ensure   => present,
            location => 'https://chocolatey.org/api/v2',
            priority => 5,
          }
        PP

        execute_manifest_on(agent, chocolatey_src_change, :catch_failures => true)
      end

      it 'Should verify results' do
        on(agent, config_content_command) do | result |
          assert_match(/5/, get_xml_value("//sources/source[@id='chocolatey']/@priority", result.output).to_s, 'Priority change did not match')
        end
      end
    end
  end

  context 'MODULES-4418 - Change Existing Bypass Proxy Setting' do

    before(:all) do
      backup_config
    end
    
    after(:all) do
      reset_config
    end

    windows_agents.each do | agent |
      it 'Should apply a manifest to set bypass_proxy' do
        chocolatey_src = <<-PP
          chocolateysource {'chocolatey':
            ensure   => present,
            location => 'https://chocolatey.org/api/v2',
            bypass_proxy => true,
          }
        PP

        execute_manifest_on(agent, chocolatey_src, :catch_failures => true)
      end

      it 'Should verify the setup was added' do
        on(agent, config_content_command) do | result |
          assert_match(/true/, get_xml_value("//sources/source[@id='chocolatey']/@bypassProxy", result.output).to_s, 'Bypass Proxy setup did not match')
        end
      end

      it 'Should apply a manifest to set bypass_proxy to false' do
        chocolatey_src_change = <<-PP
          chocolateysource {'chocolatey':
            ensure   => present,
            location => 'https://chocolatey.org/api/v2',
            bypass_proxy => false,
          }
        PP

        execute_manifest_on(agent, chocolatey_src_change, :catch_failures => true)
      end

      it 'Should verify results' do
        on(agent, config_content_command) do | result |
          assert_match(/false/, get_xml_value("//sources/source[@id='chocolatey']/@bypassProxy", result.output).to_s, 'Bypass Proxy change did not match')
        end
      end
    end
  end

  context 'MODULES-5897 - Change Existing Self Service Setting' do

    before(:all) do
      backup_config
    end
    
    after(:all) do
      reset_config
    end

    windows_agents.each do | agent |
      it 'Should apply a manifest to set allow_self_service' do
        chocolatey_src = <<-PP
          chocolateysource {'chocolatey':
            ensure             => present,
            location           => 'https://chocolatey.org/api/v2',
            allow_self_service => true,
          }
        PP

        execute_manifest_on(agent, chocolatey_src, :catch_failures => true)
      end

      it 'Should verify the setup was added' do
        on(agent, config_content_command) do | result |
          assert_match(/true/, get_xml_value("//sources/source[@id='chocolatey']/@selfService", result.output).to_s, 'Self Service setup did not match')
        end
      end

      it 'Should apply a manifest to set allow_self_service to false' do
        chocolatey_src_change = <<-PP
          chocolateysource {'chocolatey':
            ensure             => present,
            location           => 'https://chocolatey.org/api/v2',
            allow_self_service => false,
          }
        PP

        execute_manifest_on(agent, chocolatey_src_change, :catch_failures => true)
      end

      it 'Should verify results' do
        on(agent, config_content_command) do | result |
          assert_match(/false/, get_xml_value("//sources/source[@id='chocolatey']/@selfService", result.output).to_s, 'Self Service change did not match')
        end
      end
    end
  end

  context 'MODULES-5898 - Change Existing Admin Only Setting' do

    before(:all) do
      backup_config
    end
    
    after(:all) do
      reset_config
    end

    windows_agents.each do | agent |
      it 'Should apply a manifest to set admin_only' do
        chocolatey_src = <<-PP
          chocolateysource {'chocolatey':
            ensure   => present,
            location => 'https://chocolatey.org/api/v2',
            admin_only => true,
          }
        PP

        execute_manifest_on(agent, chocolatey_src, :catch_failures => true)
      end

      it 'Should verify the setup was added' do
        on(agent, config_content_command) do | result |
          assert_match(/true/, get_xml_value("//sources/source[@id='chocolatey']/@adminOnly", result.output).to_s, 'Admin Only setup did not match')
        end
      end

      it 'Should apply a manifest to set admin_only to false' do
        chocolatey_src_change = <<-PP
          chocolateysource {'chocolatey':
            ensure   => present,
            location => 'https://chocolatey.org/api/v2',
            admin_only => false,
          }
        PP

        execute_manifest_on(agent, chocolatey_src_change, :catch_failures => true)
      end

      it 'Should verify results' do
        on(agent, config_content_command) do | result |
          assert_match(/false/, get_xml_value("//sources/source[@id='chocolatey']/@adminOnly", result.output).to_s, 'Admin Only change did not match')
        end
      end
    end
  end

  context 'MODULES-3037 - Change Source Location for an Existing Source' do

    before(:all) do
      backup_config
    end

    after(:all) do
      reset_config
    end

    windows_agents.each do | agent |
      it 'Should Apply a manifest' do
        chocolatey_src = <<-PP
          chocolateysource {'chocolatey':
            ensure   => present,
            location => 'c:\\packages',
          }
        PP

        execute_manifest_on(agent, chocolatey_src, :catch_failures => true)
      end

      it 'Should verify the results' do
        on(agent, config_content_command) do | result |
          assert_match(/c:\\packages/, get_xml_value("//sources/source[@id='chocolatey']/@value", result.output).to_s, 'Location did not match')
        end
      end
    end
  end

  context 'MODULES-3037 - Change User/Password in an existing source.' do

    before(:all) do
      backup_config
    end

    after(:all) do
      reset_config
    end

    windows_agents.each do | agent |
      it 'Should apply a manifest to create a username/pass' do
        chocolatey_src = <<-PP
          chocolateysource {'chocolatey':
            ensure   => present,
            location => 'https://chocolatey.org/api/v2',
            user     => 'tim',
            password => 'test',
          }
        PP

        execute_manifest_on(agent, chocolatey_src, :catch_failures => true)
      end

      it 'Should verify the results' do
        on(agent, config_content_command) do | result |
          assert_match(/tim/, get_xml_value("//sources/source[@id='chocolatey']/@user", result.output).to_s, 'User setup did not match')
          # we are not able to verify password other than if it has a value - it will be encrypted in a non-verifyable way
          assert_match(/.+/, get_xml_value("//sources/source[@id='chocolatey']/@password", result.output).to_s, 'Password was not saved')
        end
      end

      it 'Should apply a manifest to change the values' do
        chocolatey_src_change = <<-PP
          chocolateysource {'chocolatey':
            ensure   => present,
            location => 'https://chocolatey.org/api/v2',
            user     => 'bob',
            password => 'newpass',
          }
        PP

        execute_manifest_on(agent, chocolatey_src_change, :catch_failures => true)
      end

      it 'Should validate the results' do
        on(agent, config_content_command) do | result |
          assert_match(/bob/, get_xml_value("//sources/source[@id='chocolatey']/@user", result.output).to_s, 'User change did not match')
          assert_match(/.+/, get_xml_value("//sources/source[@id='chocolatey']/@password", result.output).to_s, 'Password no longer exists')
        end
      end
    end
  end

  context 'MODULES-3037 - Disable an Existing resource' do

    before(:all) do
      backup_config
    end
    
    after(:all) do
      reset_config
    end

    windows_agents.each do | agent |
      it 'Should apply a manifest to disable the resource' do
        chocolatey_src = <<-PP
          chocolateysource {'chocolatey':
            ensure   => disabled,
          }
        PP

        execute_manifest_on(agent, chocolatey_src, :catch_failures => true)
        execute_manifest_on(agent, chocolatey_src, :catch_changes => true)
      end

      it 'Should verify the results' do
        on(agent, config_content_command) do | result |
          assert_match(/true/, get_xml_value("//sources/source[@id='chocolatey']/@disabled", result.output).to_s, 'Disabled did not match')
        end
      end
    end
  end

  context 'MODULES-3037 Disable an Existing Source' do

    before(:all) do
      backup_config
    end

    after(:all) do
      reset_config
    end

    windows_agents.each do | agent |
      it 'Should Apply a manifest' do
        chocolatey_src = <<-PP
          chocolateysource {'chocolatey':
            ensure   => disabled,
          }
        PP

        execute_manifest_on(agent, chocolatey_src, :catch_failures => true)
      end

      it 'Should verify the results' do
        on(agent, config_content_command) do | result |
          assert_match(/true/, get_xml_value("//sources/source[@id='chocolatey']/@disabled", result.output).to_s, 'Disabled did not match')
        end
      end
    end
  end

  context 'MODULES-3037 Add Source Sad Path: Fail to apply manifest without location' do

    before(:all) do
      backup_config
    end

    after(:all) do
      reset_config
    end

    windows_agents.each do | agent |
      it 'Should fail to apply a bad manifest with the correct error' do
        chocolatey_src = <<-PP
          chocolateysource {'chocolatey':
            ensure   => present,
          }
        PP

        execute_manifest_on(agent, chocolatey_src, :expect_failures => true) do | result |
          assert_match(/Error: Validation of Chocolateysource\[chocolatey\] failed: A non-empty location/, result.stderr, "stderr did not match expected")
        end
      end
    end
  end

  context 'MODULES-3037 - Add Source Sad Path: Fail to apply bad manifest' do

    before(:all) do
      backup_config
    end

    after(:all) do
      reset_config
    end

    windows_agents.each do | agent |
      it 'Should fail to apply a manifest' do
        chocolatey_src = <<-PP
          chocolateysource {'test':
            ensure   => sad,
            location => 'c:\\packages',
          }
        PP

        execute_manifest_on(agent, chocolatey_src, :expect_failures => true) do | result |
          assert_match(/Error: Parameter ensure failed on Chocolateysource\[test\]: Invalid value "sad"/, result.stderr, "stderr did not match expected")
        end
      end
    end
  end

  context 'MODULES-3037 - Add Source Sad Path: Set password with no user' do

    before(:all) do
      backup_config
    end

    after(:all) do
      reset_config
    end

    windows_agents.each do | agent |
      it 'Should fail to apply a manifest' do
        chocolatey_src = <<-PP
          chocolateysource {'chocolatey':
            ensure   => present,
            location => 'https://chocolatey.org/api/v2',
            password => 'test',
          }
        PP

        execute_manifest_on(agent, chocolatey_src, :expect_failures => true) do | result |
          assert_match(/Error: Validation of Chocolateysource\[chocolatey\] failed: If specifying user\/password, you must specify both values/, result.stderr, "stderr did not match expected")
        end
      end
    end
  end

  context 'MODULES-3037 - Add Source Sad Path: Set user with no password' do

    before(:all) do
      backup_config
    end

    after(:all) do
      reset_config
    end

    windows_agents.each do | agent |
      it 'Should fail to apply a manifest' do
        chocolatey_src = <<-PP
          chocolateysource {'chocolatey':
            ensure   => present,
            location => 'https://chocolatey.org/api/v2',
            user => 'tim',
          }
        PP

        execute_manifest_on(agent, chocolatey_src, :expect_failures => true) do | result |
          assert_match(/Error: Validation of Chocolateysource\[chocolatey\] failed: If specifying user\/password, you must specify both values/, result.stderr, "stderr did not match expected")
        end
      end
    end
  end

  context 'MODULES-3037 - Remove an Existing Source' do

    before(:all) do
      backup_config
    end

    after(:all) do
      reset_config
    end

    windows_agents.each do | agent |
      it 'Should apply a manifest' do
        chocolatey_src = <<-PP
          chocolateysource {'chocolatey':
            ensure   => absent,
          }
        PP

        execute_manifest_on(agent, chocolatey_src, :catch_failures => true)
      end

      it 'Should verify the result' do
        on(agent, config_content_command) do | result |
          assert_not_match(/chocolatey/, get_xml_value("//sources/source[@id='chocolatey']/@id", result.output).to_s, 'Source was not removed')
        end
      end
    end
  end

  context 'MODULES-3037 Remove Priority from an Existing Source' do

    before(:all) do
      backup_config
    end

    after(:all) do
      reset_config
    end

    windows_agents.each do | agent |
      chocolatey_src = <<-PP
        chocolateysource {'chocolatey':
          ensure   => present,
          location => 'https://chocolatey.org/api/v2',
          priority => 1,
        }
      PP

      chocolatey_src_remove = <<-PP
        chocolateysource {'chocolatey':
          ensure   => present,
          location => 'https://chocolatey.org/api/v2',
        }
      PP

      it 'Should apply a manifest' do
        execute_manifest_on(agent, chocolatey_src, :catch_failures => true)
      end

      it 'Should verify setup' do
        on(agent, config_content_command) do | result |
          assert_match(/1/, get_xml_value("//sources/source[@id='chocolatey']/@priority", result.output).to_s, 'Priority did not match')
        end
      end

      it 'Should apply remove manifest' do
        execute_manifest_on(agent, chocolatey_src_remove, :catch_failures => true)
      end

      it 'Should verify results' do
        on(agent, config_content_command) do | result |
          assert_match(/0/, get_xml_value("//sources/source[@id='chocolatey']/@priority", result.output).to_s, 'Priority change did not match')
        end
      end
    end
  end

  context 'MODULES-4418 Remove Bypass Proxy from an Existing Source' do

    before(:all) do
      backup_config
    end

    after(:all) do
      reset_config
    end

    windows_agents.each do | agent |
      chocolatey_src = <<-PP
        chocolateysource {'chocolatey':
          ensure   => present,
          location => 'https://chocolatey.org/api/v2',
          bypass_proxy => true,
        }
      PP

      chocolatey_src_remove = <<-PP
        chocolateysource {'chocolatey':
          ensure   => present,
          location => 'https://chocolatey.org/api/v2',
        }
      PP

      it 'Should apply a manifest' do
        execute_manifest_on(agent, chocolatey_src, :catch_failures => true)
      end

      it 'Should verify setup' do
        on(agent, config_content_command) do | result |
          assert_match(/true/, get_xml_value("//sources/source[@id='chocolatey']/@bypassProxy", result.output).to_s, 'Bypass Proxy did not match')
        end
      end

      it 'Should apply remove manifest' do
        execute_manifest_on(agent, chocolatey_src_remove, :catch_failures => true)
      end

      it 'Should verify results' do
        on(agent, config_content_command) do | result |
          assert_match(/false/, get_xml_value("//sources/source[@id='chocolatey']/@bypassProxy", result.output).to_s, 'Bypass Proxy change did not match')
        end
      end
    end
  end

  context 'MODULES-5897 Remove Self Service from an Existing Source' do

    before(:all) do
      backup_config
    end

    after(:all) do
      reset_config
    end

    windows_agents.each do | agent |
      chocolatey_src = <<-PP
        chocolateysource {'chocolatey':
          ensure             => present,
          location           => 'https://chocolatey.org/api/v2',
          allow_self_service => true,
        }
      PP

      chocolatey_src_remove = <<-PP
        chocolateysource {'chocolatey':
          ensure   => present,
          location => 'https://chocolatey.org/api/v2',
        }
      PP

      it 'Should apply a manifest' do
        execute_manifest_on(agent, chocolatey_src, :catch_failures => true)
      end

      it 'Should verify setup' do
        on(agent, config_content_command) do | result |
          assert_match(/true/, get_xml_value("//sources/source[@id='chocolatey']/@selfService", result.output).to_s, 'Self Service did not match')
        end
      end

      it 'Should apply remove manifest' do
        execute_manifest_on(agent, chocolatey_src_remove, :catch_failures => true)
      end

      it 'Should verify results' do
        on(agent, config_content_command) do | result |
          assert_match(/false/, get_xml_value("//sources/source[@id='chocolatey']/@selfService", result.output).to_s, 'Self Service change did not match')
        end
      end
    end
  end

  context 'MODULES-5898 Remove Admin Only from an Existing Source' do

    before(:all) do
      backup_config
    end

    after(:all) do
      reset_config
    end

    windows_agents.each do | agent |
      chocolatey_src = <<-PP
        chocolateysource {'chocolatey':
          ensure   => present,
          location => 'https://chocolatey.org/api/v2',
          admin_only => true,
        }
      PP

      chocolatey_src_remove = <<-PP
        chocolateysource {'chocolatey':
          ensure   => present,
          location => 'https://chocolatey.org/api/v2',
        }
      PP

      it 'Should apply a manifest' do
        execute_manifest_on(agent, chocolatey_src, :catch_failures => true)
      end

      it 'Should verify setup' do
        on(agent, config_content_command) do | result |
          assert_match(/true/, get_xml_value("//sources/source[@id='chocolatey']/@adminOnly", result.output).to_s, 'Admin Only did not match')
        end
      end

      it 'Should apply remove manifest' do
        execute_manifest_on(agent, chocolatey_src_remove, :catch_failures => true)
      end

      it 'Should verify results' do
        on(agent, config_content_command) do | result |
          assert_match(/false/, get_xml_value("//sources/source[@id='chocolatey']/@adminOnly", result.output).to_s, 'Admin Only change did not match')
        end
      end
    end
  end

  context 'MODULES-3037 - Remove User/Password From an Existing Source' do

    before(:all) do
      backup_config
    end

    after(:all) do
      reset_config
    end

    windows_agents.each do | agent |
      chocolatey_src = <<-PP
        chocolateysource {'chocolatey':
          ensure   => present,
          location => 'https://chocolatey.org/api/v2',
          user     => 'tim',
          password => 'test',
        }
      PP

      chocolatey_src_remove = <<-PP
        chocolateysource {'chocolatey':
          ensure   => present,
          location => 'https://chocolatey.org/api/v2',
        }
      PP

      it 'Should apply a manifest' do
        execute_manifest_on(agent, chocolatey_src, :catch_failures => true)
      end

      it 'Should verify setup' do
        on(agent, config_content_command) do | result |
          assert_match(/tim/, get_xml_value("//sources/source[@id='chocolatey']/@user", result.output).to_s, 'User setup did not match')
          # we are not able to verify password other than if it has a value - it will be encrypted in a non-verifyable way
          assert_match(/.+/, get_xml_value("//sources/source[@id='chocolatey']/@password", result.output).to_s, 'Password was not saved')
        end
      end

      it 'Should apply remove manifest' do
        execute_manifest_on(agent, chocolatey_src_remove, :catch_failures => true)
      end

      it 'Should verify results' do
        on(agent, config_content_command) do | result |
          assert_not_match(/.+/, get_xml_value("//sources/source[@id='chocolatey']/@user", result.output).to_s, 'User was not removed')
          assert_not_match(/.+/, get_xml_value("//sources/source[@id='chocolatey']/@password", result.output).to_s, 'Password was not removed')
        end
      end
    end
  end
end

