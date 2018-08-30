require 'beaker-pe'
require 'beaker-puppet'
require 'nokogiri'
require 'beaker-rspec'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'
require 'beaker/ca_cert_helper'
require 'beaker/testmode_switcher/dsl'

Dir["./spec/support/**/*.rb"].sort.each { |f| require f }

run_puppet_install_helper
configure_type_defaults_on(hosts)
install_ca_certs

hosts.each do |host|
  install_module_dependencies_on(host)
  install_module_on(host)
end

windows_agents.each do |agent|
  install_chocolatey
end
