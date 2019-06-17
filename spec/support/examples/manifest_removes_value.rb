shared_examples 'a manifest that removes a config value' do |manifest, key|
  windows_agents.each do |agent|
    it 'applies the manifest that removes the value' do
      execute_manifest_on(agent, manifest, catch_failures: true)
    end

    it 'validates the key has been removed' do
      on(agent, config_content_command) do |result|
        assert_not_match(%r{.+}, get_xml_value("//config/add[@key='#{key}']/@value", result.output).to_s, 'Value should have been removed')
      end
    end
  end
end
