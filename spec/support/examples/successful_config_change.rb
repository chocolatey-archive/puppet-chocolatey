shared_examples 'a successful config change' do |manifest, key, expected_value|
    
  windows_agents.each do |agent|
    
    it 'Should apply the config manifest' do
        execute_manifest_on(agent, manifest, :catch_failures => true)
    end

    it 'should validate the value' do
      on(agent, config_content_command) do |result|
        assert_match(expected_value, get_xml_value("//config/add[@key='#{key}']/@value", result.output).to_s, 'Value did not match')
      end
    end
  end
end

