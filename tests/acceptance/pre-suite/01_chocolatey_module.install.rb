test_name 'MODULES-3138 - C97814 - Install Pre-suite Acceptance Test'

# Beaker option set if "BEAKER_FORGE_HOST" environment variable is present
if options[:forge_host]
  # Check to see if module version is specified.
  staging[:version] = ENV['MODULE_VERSION'] if ENV['MODULE_VERSION']

  step 'Install Chocolatey Module from Forge'
  install_dev_puppet_module_on(master, staging)
else
  step 'Install Chocolatey Module Dependencies'

  %w(puppetlabs-stdlib puppetlabs-powershell badgerious/windows_env).each do |dep|
    on(agent, puppet("module install #{dep}"))
  end
  #add badgerious

step 'Install Chocolatey Module'
proj_root = File.expand_path(File.join(File.dirname(__FILE__), '../../../'))
staging = { :module_name => 'puppetlabs-chocolatey' }
local = { :module_name => 'chocolatey', :source => proj_root, :target_module_path => master['distmoduledir'] }

# Check to see if module version is specified.
staging[:version] = ENV['MODULE_VERSION'] if ENV['MODULE_VERSION']

# in CI install from staging forge, otherwise from local
install_dev_puppet_module_on(master, options[:forge_host] ? staging : local)
