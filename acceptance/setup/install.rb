require 'beaker/puppet_install_helper'

step 'Install Puppet'
run_puppet_install_helper

step 'Install Certs'
install_ca_certs

step 'Install Module'
proj_root = File.expand_path(File.join(File.dirname(__FILE__), '../..'))
hosts.each do |host|
  install_dev_puppet_module_on(host, :source => proj_root, :module_name => 'chocolatey')
end
