# vim: set ts=2 sw=2 ai et ruler:

# lock dependencies and load paths, but lazy-load gems
require 'bundler/setup'
require 'jumanjiman_spec_helper/bundle'
JumanjimanSpecHelper::Bundle.setup

# add namespaced rake tasks
require 'jumanjiman_spec_helper/git'

# always keep clone config up-to-date
JumanjimanSpecHelper::Git.update_git_config

task :default do |t|
  puts %x!rake -T!
end

require 'rake/dsl_definition'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.rspec_opts = [
    '--color',
  ]
end
