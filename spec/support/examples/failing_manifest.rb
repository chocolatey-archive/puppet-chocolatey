shared_examples 'a failing manifest' do |manifest, expected_error|

  windows_agents.each do |agent|

    it 'Should fail to apply a bad manifest' do
      execute_manifest_on(agent, manifest, :expect_failures => true) do
        assert_match(expected_error, stderr, "stderr did not match expected error")
      end
    end
  end
end

