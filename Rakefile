require 'rake'
require 'rspec/core/rake_task'
require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet_blacksmith/rake_tasks' if Bundler.rubygems.find_name('puppet-blacksmith').any?
require 'puppet'

begin
  require 'beaker/tasks/test' unless RUBY_PLATFORM =~ /win32/
rescue LoadError
  #Do nothing, only installed with system_tests group
end


# If puppet does not support symlinks (e.g., puppet <= 3.5) we cannot use
# puppetlabs_spec_helper's `rake spec` task because it requires symlink
# support. Redefine `rake spec` to avoid calling `rake spec_prep` (requires
# symlinks to place fixtures) and restrict the pattern match only files under
# the 'unit' directory (tests in other dirs require fixtures).
if Puppet::Util::Platform.windows? and !Puppet::FileSystem.respond_to?(:symlink)
  ENV["SPEC"] = "./spec/{unit,integration}/**/*_spec.rb"
  Rake::Task[:spec].clear if Rake::Task.task_defined?(:spec)
  task :spec do
    Rake::Task[:spec_standalone].invoke
    Rake::Task[:spec_clean].invoke
  end
end

# These lint exclusions are in puppetlabs_spec_helper but needs a version above 0.10.3
# Line length test is 80 chars in puppet-lint 1.1.0
PuppetLint.configuration.send('disable_80chars')
# Line length test is 140 chars in puppet-lint 2.x
PuppetLint.configuration.send('disable_140chars')

task :default => [:spec]

desc 'Generate code coverage'
RSpec::Core::RakeTask.new(:coverage) do |t|
  t.rcov = true
  t.rcov_opts = ['--exclude', 'spec']
end

rototiller_gem_message = 'Ensure Rototiller gem is installed before using this task.'

desc "#{rototiller_gem_message}"
task :host_config

desc "#{rototiller_gem_message}"
task :acceptance_tests

desc "#{rototiller_gem_message}"
task :reference_tests

begin
  require 'rototiller'
  default_reference_platform = 'windows2012r2-64'
  default_acceptance_platform = 'centos7-64mdca-windows2012r2-64a'
  internal_pe_host_location = 'http://neptune.puppetlabs.lan/'
  internal_pe_version = '2016.5/ci-ready/'

  # Modify a rototiller command and add the common testing options
  def add_common_beaker_options_to(command)
    command.add_option do |debug|
      debug.name = '--debug'
    end
    command.add_option do |preserve_hosts|
      preserve_hosts.name = '--preserve-hosts'
      preserve_hosts.add_argument do |arg|
        arg.name = 'never'
        arg.add_env({:name => 'BEAKER_PRESERVEHOSTS', :message => 'Override the --preserve-hosts option'})
      end
    end
    command.add_option do |config|
      config.name = '--config'
      config.add_argument do |arg|
          arg.name = "tests/configs/#{ENV['PLATFORM']}"
        end
    end
    command.add_option do |keyfile|
      keyfile.name = '--keyfile'
      keyfile.add_argument do |arg|
        arg.name = "#{ENV['HOME']}/.ssh/id_rsa-acceptance"
        arg.add_env({:name => 'BEAKER_KEYFILE', :message => 'Override the --keyfile option'})
      end
    end
    command.add_option do |loadpath|
      loadpath.name = '--load-path'
      loadpath.add_argument do |arg|
        arg.name = 'tests/lib'
        arg.add_env({:name => 'BEAKER_LOADPATH', :message => 'Override the --load-path option' })
      end
    end
  end

  desc 'Generate Beaker Host config'
  rototiller_task :host_config, [:default_platform] do |t, args|
    # Create the directory, if it exists already you'll get an error, but this should not stop the execution
    config_dir = 'tests/configs/'
    begin
      sh "mkdir #{config_dir}"
    rescue => e
      puts e.message
    end
    t.add_env({:name => 'PLATFORM', :message => 'PLATFORM Must be set. For example "windows2012r2-64"', :default => args[:default_platform]})
    hosts_file = "#{config_dir}#{ENV['PLATFORM']}"
    t.add_command do |cmd|
      cmd.name = 'bundle exec beaker-hostgenerator'
      cmd.add_argument({:name => "#{ENV['PLATFORM']} > #{hosts_file}"})
    end
  end

  # Runs the reference tests in agent only configuration
  desc 'Executes reference tests (agent only) intended for use in CI'
  rototiller_task :reference_tests  do |task|
    Rake::Task[:host_config].invoke("#{default_reference_platform}") # pass the default_reference_platform to the host_config task
    task.add_command do |cmd|
      cmd.name = 'bundle exec beaker'

      add_common_beaker_options_to(cmd)

      cmd.add_option do |presuite|
        presuite.name = '--pre-suite'
        presuite.add_argument do |arg|
          arg.name = 'tests/reference/pre-suite'
          arg.add_env({:name => 'BEAKER_PRESUITE', :message => 'Override the --pre-suite option'})
        end
      end
      cmd.add_option do |tests|
        tests.name = '--tests'
        tests.add_argument do |arg|
          arg.name = 'tests/reference/tests'
          arg.add_env({:name => 'BEAKER_TESTSUITE', :message => 'Override the --tests option'})
        end
      end
      cmd.add_option do |type|
        type.name = '--type'
        type.add_argument do |arg|
          arg.name = 'aio'
          arg.add_env({:name => 'PLATFORM_TYPE', :message => 'Override the --type option'})
        end
      end
    end
  end

  desc 'Executes acceptance tests (master and agent) intended for use in CI'
  rototiller_task :acceptance_tests do |task|
    Rake::Task[:host_config].invoke("#{default_acceptance_platform}") # pass the default_acceptance_platform to the host_config task
    task.add_env({:name => 'BEAKER_PE_DIR', :message => 'BEAKER_PE_DIR Must be set.', :default => internal_pe_host_location + internal_pe_version})
    task.add_command do |cmd|
      cmd.name = 'bundle exec beaker'

      add_common_beaker_options_to(cmd)

      cmd.add_option do |presuite|
        presuite.name = '--pre-suite'
        presuite.add_argument do |arg|
          arg.name = 'tests/acceptance/pre-suite'
          arg.add_env({:name => 'BEAKER_PRESUITE', :message => 'Override the --pre-suite option'})
        end
      end
      cmd.add_option do |tests|
        tests.name = '--tests'
        tests.add_argument do |arg|
          arg.name = 'tests/acceptance/tests'
          arg.add_env({:name => 'BEAKER_TESTSUITE', :message => 'Override the --tests option'})
        end
      end
    end
  end
rescue LoadError => e
  STDERR.puts "Unable to load rototiller:"
  raise e
end

