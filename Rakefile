require 'rake'
require 'rspec/core/rake_task'
require 'puppetlabs_spec_helper/rake_tasks'
begin
  require 'beaker/tasks/test' unless RUBY_PLATFORM =~ /win32/
rescue LoadError
  #Do nothing, only installed with system_tests group 
end

# These lint exclusions are in puppetlabs_spec_helper but needs a version above 0.10.3 
# Line length test is 80 chars in puppet-lint 1.1.0
PuppetLint.configuration.send('disable_80chars')
# Line length test is 140 chars in puppet-lint 2.x
PuppetLint.configuration.send('disable_140chars')

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
bundle exec beaker                          \
    --debug                                 \
    --preserve-hosts never                  \
    --config tests/configs/$PLATFORM        \
    --keyfile ~/.ssh/id_rsa-acceptance      \
    --load-path tests/lib                   \
    --type aio                              \
    --pre-suite tests/reference/pre-suite   \
    --tests tests/reference/tests           
    EOS
    sh command
end

desc 'Executes accetpance tests (master and agent) indened for use in CI'
task :acceptance_tests do
    command =<<-EOS
bundle exec beaker                          \
    --debug                                 \
    --preserve-hosts never                  \
    --config tests/configs/$PLATFORM        \
    --keyfile ~/.ssh/id_rsa-acceptance      \
    --load-path tests/lib                   \
    --pre-suite tests/acceptance/pre-suite  \
    --tests tests/acceptance/tests          
    EOS
    sh command
end

task :acceptance_tests => [:basic_enviroment_variable_check, :acceptance_enviroment_varible_check]
task :reference_tests => [:basic_enviroment_variable_check]

task :basic_enviroment_variable_check do
    abort("PLATFORM variable not present, aborting test.") unless ENV["PLATFORM"]
    abort("MODULE_VERSION variable not present, aborting test.") unless ENV["MODULE_VERSION"]
end

task :acceptance_enviroment_varible_check do
    if ENV["BEAKER_PE_DIR"] && ENV["PE_DIST_DIR"]
        abort("Either BEAKER_PE_DIR or PE_DIST_DIR variable should be set but not both, aborting test.")
    end
    if !ENV["BEAKER_PE_DIR"] && !ENV["PE_DIST_DIR"]
        abort("Neither BEAKER_PE_DIR or PE_DIST_DIR variable is set, aborting test.")
    end
end

