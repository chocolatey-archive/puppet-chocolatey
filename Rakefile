require 'rake'
require 'rspec/core/rake_task'
require 'puppetlabs_spec_helper/rake_tasks'
begin
  require 'beaker/tasks/test' unless RUBY_PLATFORM =~ /win32/
rescue LoadError
  #Do nothing, only installed with system_tests group 
end

task :default => [:test]

desc 'Run RSpec'
RSpec::Core::RakeTask.new(:test) do |t|
  t.pattern = 'spec/{unit}/**/*.rb'
#  t.rspec_opts = ['--color']
end

desc 'Generate code coverage'
RSpec::Core::RakeTask.new(:coverage) do |t|
  t.rcov = true
  t.rcov_opts = ['--exclude', 'spec']
end

desc 'Executes reference tests (agent only) intended for use in CI'
task :reference_tests do
	command =<<-EOS
bundle exec beaker							\
	--debug									\
	--preserve-hosts never					\
	--config tests/configs/$PLATFORM 		\
	--keyfile ~/.ssh/id_rsa-acceptance		\
	--load-path tests/lib					\
	--type aio								\
	--pre-suite tests/reference/pre-suite	\
	--tests tests/reference/tests
	EOS
	sh command
end

desc 'Executes accetpance tests (master and agent) indened for use in CI'
task :acceptance_tests do
	command =<<-EOS
bundle exec beaker
	--debug									\
	--preserve-hosts never					\
	--config tests/configs/$PLATFORM 		\
	--keyfile ~/.ssh/id_rsa-acceptance		\
	--load-path tests/lib					\
	--type aio								\
	--pre-suite tests/acceptance/pre-suite	\
	--tests tests/acceptance/tests
	EOS
	sh command
end
