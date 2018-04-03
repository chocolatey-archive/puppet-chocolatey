shared_examples 'a password that doesn\'t change' do |manifest, modify_manfiest, key|

  password = ''
    
  windows_agents.each do |agent|
    # Should apply the password here.
    # 'password' variable is set to the password hash value.
    it 'Should apply the manifest to set the password' do
      execute_manifest_on(agent, manifest, :catch_failures => true)
      on(agent, config_content_command) do |result|
        password = get_xml_value("//config/add[@key='#{key}']/@value", result.output).to_s
        assert_match(/.+/, password, 'Value did not match')
      end
    end

    it 'should validate the value' do
      # Apply a manifest with a modified password value
      execute_manifest_on(agent, modify_manfiest, :catch_failures => true)
      on(agent, config_content_command) do |result|
        # Verify here that the hash value in the config did not change.
        assert_match(password, get_xml_value("//config/add[@key='#{key}']/@value", result.output).to_s, 'Value should not have changed')
      end
    end
  end
end

