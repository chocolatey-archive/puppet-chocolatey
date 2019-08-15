require 'spec_helper_acceptance'

describe 'chocolateysource resource' do
  context 'create resource' do
    include_context 'backup and reset config'

    let(:pp_remove) do
      <<-MANIFEST
        chocolateysource {'chocolatey':
          ensure             => absent,
        }
      MANIFEST
    end

    let(:pp_chocolateysource) do
      <<-MANIFEST
        chocolateysource {'chocolatey':
          ensure             => present,
          location           => 'https://chocolatey.org/api/v2',
          priority           => 2,
          user               => 'bob',
          password           => 'yes',
          bypass_proxy       => true,
          allow_self_service => true,
          admin_only         => true,
        }
      MANIFEST
    end

    it 'applies manifest, sets config' do
      apply_manifest(pp_remove)
      apply_manifest(pp_chocolateysource, debug: true) do |result|
        expect(result.stdout).to match(%r{Debug: Executing: '\[redacted\]'})
      end
      run_shell(config_content_command, acceptable_exit_codes: [0]) do |result|
        expect(get_xml_value("//sources/source[@id='chocolatey']/@value", result.stdout).to_s).to match(%r{https:\/\/chocolatey.org\/api\/v2})
        expect(get_xml_value("//sources/source[@id='chocolatey']/@priority", result.stdout).to_s).to match(%r{2})
        expect(get_xml_value("//sources/source[@id='chocolatey']/@user", result.stdout).to_s).to match(%r{bob})
        expect(get_xml_value("//sources/source[@id='chocolatey']/@password", result.stdout).to_s).to match(%r{.+})
        expect(get_xml_value("//sources/source[@id='chocolatey']/@disabled", result.stdout).to_s).to match(%r{false})
        expect(get_xml_value("//sources/source[@id='chocolatey']/@bypassProxy", result.stdout).to_s).to match(%r{true})
        expect(get_xml_value("//sources/source[@id='chocolatey']/@selfService", result.stdout).to_s).to match(%r{true})
        expect(get_xml_value("//sources/source[@id='chocolatey']/@adminOnly", result.stdout).to_s).to match(%r{true})
      end
    end
  end

  context 'change existing resource' do
    include_context 'backup and reset config'

    let(:pp_chocolateysource) do
      <<-MANIFEST
        chocolateysource {'chocolatey':
          ensure             => present,
          location           => 'https://chocolatey.org/api/v2',
          priority           => 2,
          user               => 'bob',
          password           => 'yes',
          bypass_proxy       => true,
          allow_self_service => true,
          admin_only         => true,
        }
      MANIFEST
    end

    let(:pp_chocolateysource_changed) do
      <<-MANIFEST
        chocolateysource {'chocolatey':
          ensure             => present,
          location           => 'c:\\packages',
          priority           => 5,
          user               => 'doot',
          password           => 'password123',
          bypass_proxy       => false,
          allow_self_service => false,
          admin_only         => false,
        }
      MANIFEST
    end

    it 'applies manifests' do
      idempotent_apply(pp_chocolateysource)
      idempotent_apply(pp_chocolateysource_changed)
    end

    it 'sets changed config' do
      run_shell(config_content_command) do |result|
        expect(get_xml_value("//sources/source[@id='chocolatey']/@value", result.stdout).to_s).to match(%r{c:\\packages})
        expect(get_xml_value("//sources/source[@id='chocolatey']/@priority", result.stdout).to_s).to match(%r{5})
        expect(get_xml_value("//sources/source[@id='chocolatey']/@user", result.stdout).to_s).to match(%r{doot})
        expect(get_xml_value("//sources/source[@id='chocolatey']/@password", result.stdout).to_s).to match(%r{.+})
        expect(get_xml_value("//sources/source[@id='chocolatey']/@disabled", result.stdout).to_s).to match(%r{false})
        expect(get_xml_value("//sources/source[@id='chocolatey']/@bypassProxy", result.stdout).to_s).to match(%r{false})
        expect(get_xml_value("//sources/source[@id='chocolatey']/@selfService", result.stdout).to_s).to match(%r{false})
        expect(get_xml_value("//sources/source[@id='chocolatey']/@adminOnly", result.stdout).to_s).to match(%r{false})
      end
    end
  end

  context 'remove values from an existing resource' do
    include_context 'backup and reset config'

    let(:pp_chocolateysource) do
      <<-MANIFEST
        chocolateysource {'chocolatey':
          ensure             => present,
          location           => 'https://chocolatey.org/api/v2',
          priority           => 2,
          user               => 'bob',
          password           => 'yes',
          bypass_proxy       => true,
          allow_self_service => true,
          admin_only         => true,
        }
      MANIFEST
    end

    let(:pp_chocolateysource_remove) do
      <<-MANIFEST
        chocolateysource {'chocolatey':
          ensure   => present,
          location => 'https://chocolatey.org/api/v2',
        }
      MANIFEST
    end

    it 'applies manifest, sets config' do
      idempotent_apply(pp_chocolateysource)
      run_shell(config_content_command) do |result|
        expect(get_xml_value("//sources/source[@id='chocolatey']/@value", result.stdout).to_s).to match(%r{https:\/\/chocolatey.org\/api\/v2})
        expect(get_xml_value("//sources/source[@id='chocolatey']/@priority", result.stdout).to_s).to match(%r{2})
        expect(get_xml_value("//sources/source[@id='chocolatey']/@user", result.stdout).to_s).to match(%r{bob})
        expect(get_xml_value("//sources/source[@id='chocolatey']/@password", result.stdout).to_s).to match(%r{.+})
        expect(get_xml_value("//sources/source[@id='chocolatey']/@disabled", result.stdout).to_s).to match(%r{false})
        expect(get_xml_value("//sources/source[@id='chocolatey']/@bypassProxy", result.stdout).to_s).to match(%r{true})
        expect(get_xml_value("//sources/source[@id='chocolatey']/@selfService", result.stdout).to_s).to match(%r{true})
        expect(get_xml_value("//sources/source[@id='chocolatey']/@adminOnly", result.stdout).to_s).to match(%r{true})
      end
    end

    it 'applies manifest, unsets config attributes' do
      idempotent_apply(pp_chocolateysource_remove)
      run_shell(config_content_command) do |result|
        expect(get_xml_value("//sources/source[@id='chocolatey']/@value", result.stdout).to_s).to match(%r{https:\/\/chocolatey.org\/api\/v2})
        expect(get_xml_value("//sources/source[@id='chocolatey']/@priority", result.stdout).to_s).to match(%r{0})
        expect(get_xml_value("//sources/source[@id='chocolatey']/@user", result.stdout).to_s).to match(%r{})
        expect(get_xml_value("//sources/source[@id='chocolatey']/@password", result.stdout).to_s).to match(%r{})
        expect(get_xml_value("//sources/source[@id='chocolatey']/@disabled", result.stdout).to_s).to match(%r{})
        expect(get_xml_value("//sources/source[@id='chocolatey']/@bypassProxy", result.stdout).to_s).to match(%r{false})
        expect(get_xml_value("//sources/source[@id='chocolatey']/@selfService", result.stdout).to_s).to match(%r{false})
        expect(get_xml_value("//sources/source[@id='chocolatey']/@adminOnly", result.stdout).to_s).to match(%r{false})
      end
    end
  end

  context 'specify only location' do
    include_context 'backup and reset config'

    let(:pp_chocolateysource) do
      <<-MANIFEST
        chocolateysource {'test':
          location => 'c:\\packages',
        }
      MANIFEST
    end

    it 'applies manifest, sets config' do
      idempotent_apply(pp_chocolateysource)
      run_shell(config_content_command) do |result|
        expect(get_xml_value("//sources/source[@id='test']/@value", result.stdout).to_s).to match(%r{c:\\packages})
        expect(get_xml_value("//sources/source[@id='test']/@disabled", result.stdout).to_s).to match(%r{false})
      end
    end
  end

  context 'disable resource' do
    include_context 'backup and reset config'

    let(:pp_chocolateysource) do
      <<-MANIFEST
        chocolateysource {'chocolatey':
          ensure   => disabled,
        }
      MANIFEST
    end

    it 'applies manifest, sets config' do
      idempotent_apply(pp_chocolateysource)
      run_shell(config_content_command) do |result|
        expect(get_xml_value("//sources/source[@id='chocolatey']/@disabled", result.stdout).to_s).to match(%r{true})
      end
    end
  end

  context 'exceptions' do
    include_context 'backup and reset config'

    context 'when without location set' do
      let(:pp_chocolateysource) do
        <<-MANIFEST
          chocolateysource {'chocolatey':
            ensure   => present,
          }
        MANIFEST
      end

      it 'raises an error' do
        apply_manifest(pp_chocolateysource, expect_failures: true) do |result|
          expect(result.exit_code).to eq(1)
          expect(result.stderr).to match(%r{Error: Validation of Chocolateysource\[chocolatey\] failed: A non-empty location})
        end
      end
    end

    context 'when invalid ensure' do
      let(:pp_chocolateysource) do
        <<-MANIFEST
          chocolateysource {'test':
            ensure   => sad,
            location => 'c:\\packages',
          }
        MANIFEST
      end

      it 'raises an error' do
        apply_manifest(pp_chocolateysource, expect_failures: true) do |result|
          expect(result.exit_code).to eq(1)
          expect(result.stderr).to match(%r{Error: Parameter ensure failed on Chocolateysource\[test\]: Invalid value "sad"})
        end
      end
    end

    context 'when password set and user not set' do
      let(:pp_chocolateysource) do
        <<-MANIFEST
          chocolateysource {'chocolatey':
            ensure   => present,
            location => 'https://chocolatey.org/api/v2',
            password => 'test',
          }
        MANIFEST
      end

      it 'raises an error' do
        apply_manifest(pp_chocolateysource, expect_failures: true) do |result|
          expect(result.exit_code).to eq(1)
          expect(result.stderr).to match(%r{Error: Validation of Chocolateysource\[chocolatey\] failed: If specifying user\/password, you must specify both values})
        end
      end
    end

    context 'when user set and password not set' do
      let(:pp_chocolateysource) do
        <<-MANIFEST
          chocolateysource {'chocolatey':
            ensure   => present,
            location => 'https://chocolatey.org/api/v2',
            user => 'tim',
          }
        MANIFEST
      end

      it 'raises an error' do
        apply_manifest(pp_chocolateysource, expect_failures: true) do |result|
          expect(result.exit_code).to eq(1)
          expect(result.stderr).to match(%r{Error: Validation of Chocolateysource\[chocolatey\] failed: If specifying user\/password, you must specify both values})
        end
      end
    end
  end
end
