RSpec.shared_context 'backup and reset config' do
  before(:all) { backup_config } # rubocop:disable RSpec/BeforeAfterAll
  after(:all) { reset_config } # rubocop:disable RSpec/BeforeAfterAll
end
