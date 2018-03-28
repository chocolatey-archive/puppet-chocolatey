# Not sure if these are still neeed.
# require 'net/http'
# require 'uri'
require 'nokogiri'

require 'beaker-rspec'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'
require 'beaker/ca_cert_helper'
#require 'beaker/testmode_switcher'
#require 'beaker/testmode_switcher/dsl'
#require 'beaker-puppet'
Dir["./spec/support/**/*.rb"].sort.each { |f| require f }

run_puppet_install_helper
install_ca_certs

windows_agents.each do |agent|
  install_module_dependencies_on(agent)
  install_module_on(agent)
  install_chocolatey
end

