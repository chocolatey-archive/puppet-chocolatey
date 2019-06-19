require 'spec_helper_acceptance'

describe 'chocolateyconfig' do
  context 'create chocolateyconfig resource' do
    include_context 'backup and reset config'

    let(:pp_chocolateysource) do
      <<-MANIFEST
        chocolateyconfig {'hello123':
          ensure => present,
          value  => 'this guy',
        }
      MANIFEST
    end

    it 'applies manifest, sets config' do
      idempotent_apply(pp_chocolateysource)
      run_shell(config_content_command) do |result|
        expect(get_xml_value("//config/add[@key='hello123']/@value", result.stdout).to_s).to match(%r{this guy})
      end
    end
  end

  context 'add value to existing chocolateyconfig' do
    include_context 'backup and reset config'

    let(:pp_chocolateysource) do
      <<-MANIFEST
        chocolateyconfig {'proxy':
          ensure => present,
          value  => 'https://somewhere',
        }
      MANIFEST
    end

    it 'applies manifest, sets config' do
      idempotent_apply(pp_chocolateysource)
      run_shell(config_content_command) do |result|
        expect(get_xml_value("//config/add[@key='proxy']/@value", result.stdout).to_s).to match(%r{https\:\/\/somewhere})
      end
    end
  end

  context 'change config value on existing chocolateyconfig' do
    include_context 'backup and reset config'

    let(:pp_chocolateysource) do
      <<-MANIFEST
        chocolateyconfig {'proxyUser':
          value => 'bob',
        }
      MANIFEST
    end

    let(:pp_chocolateysource_changed) do
      <<-MANIFEST
        chocolateyconfig {'proxyuser':
          value => 'tim',
        }
      MANIFEST
    end

    it 'applies manifest, sets up initial state' do
      idempotent_apply(pp_chocolateysource)
      run_shell(config_content_command) do |result|
        expect(get_xml_value("//config/add[@key='proxyUser']/@value", result.stdout).to_s).to match(%r{bob})
      end
    end

    it 'applies manifest, sets config' do
      idempotent_apply(pp_chocolateysource_changed)
      run_shell(config_content_command) do |result|
        expect(get_xml_value("//config/add[@key='proxyUser']/@value", result.stdout).to_s).to match(%r{tim})
      end
    end
  end

  context "create chocolateyconfig containing 'password' in name" do
    include_context 'backup and reset config'

    let(:config_value) do
      pp_chocolateysource_changed = <<-MANIFEST
        chocolateyconfig {'proxyPassword':
          value => 'secrect',
        }
      MANIFEST

      idempotent_apply(pp_chocolateysource_changed)
      result = run_shell(config_content_command)
      get_xml_value("//config/add[@key='proxyPassword']/@value", result.stdout).to_s
    end

    let(:pp_chocolateysource) do
      <<-MANIFEST
        chocolateyconfig {'proxyPassword':
          value => 'secrect2',
        }
      MANIFEST
    end

    it "applies manifest, doesn't change password field" do
      idempotent_apply(pp_chocolateysource)
      run_shell(config_content_command) do |result|
        expect(get_xml_value("//config/add[@key='proxyPassword']/@value", result.stdout).to_s).to eq(config_value)
      end
    end
  end

  context 'create chocolateyconfig with no value set' do
    include_context 'backup and reset config'

    let(:pp_chocolateysource) do
      <<-MANIFEST
        chocolateyconfig {'bob':
          ensure => present,
        }
      MANIFEST
    end

    it 'raises error' do
      apply_manifest(pp_chocolateysource, expect_failures: true) do |result|
        expect(result.exit_code).to eq(1)
        expect(result.stderr).to match(%r{Unless ensure => absent, value is required})
      end
    end
  end

  context "remove value fom chocolateyconfig containing 'password' in name" do
    include_context 'backup and reset config'

    let(:pp_chocolateysource) do
      <<-MANIFEST
        chocolateyconfig {'proxyPassword':
          value => 'secret',
        }
      MANIFEST
    end

    let(:pp_chocolateysource_changed) do
      <<-MANIFEST
        chocolateyconfig {'proxyPassword':
          ensure => absent,
        }
      MANIFEST
    end

    it 'applies manifest, sets initial state' do
      idempotent_apply(pp_chocolateysource)
      run_shell(config_content_command) do |result|
        expect(get_xml_value("//config/add[@key='proxyPassword']/@value", result.stdout).to_s).to match(%r{.+})
      end
    end

    it 'applies manifest, removes key from config' do
      idempotent_apply(pp_chocolateysource_changed)
      run_shell(config_content_command) do |result|
        expect(get_xml_value("//config/add[@key='proxyPassword']/@value", result.stdout).to_s).not_to match(%r{.+})
      end
    end
  end

  context 'remove value from chocolateyconfig' do
    include_context 'backup and reset config'

    let(:pp_chocolateysource) do
      <<-MANIFEST
        chocolateyconfig {'amadeupvalue':
          ensure => present,
          value => '10',
        }
      MANIFEST
    end

    let(:pp_chocolateysource_changed) do
      <<-MANIFEST
        chocolateyconfig {'amadeupvalue':
          ensure => absent,
        }
      MANIFEST
    end

    it 'applies manifest, sets initial state' do
      idempotent_apply(pp_chocolateysource)
      run_shell(config_content_command) do |result|
        expect(get_xml_value("//config/add[@key='amadeupvalue']/@value", result.stdout).to_s).to match(%r{10})
      end
    end

    it 'applies manifest, removes key from config' do
      idempotent_apply(pp_chocolateysource_changed)
      run_shell(config_content_command) do |result|
        expect(get_xml_value("//config/add[@key='amadeupvalue']/@value", result.stdout).to_s).not_to match(%r{.+})
      end
    end
  end
end
