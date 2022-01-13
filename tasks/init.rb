#!/opt/puppetlabs/puppet/bin/ruby
# frozen_string_literal: true

require 'open3'
require 'puppet'

require_relative '../../ruby_task_helper/files/task_helper.rb'

# Manage installing, upgrading and uninstalling packages
class ChocolateyTask < TaskHelper
  def task(action: nil, package: nil, version: nil)
    command = [
      'choco',
      action,
      package,
      '--yes',
      '--no-color',
      '--no-progress',
    ]

    if version
      command += [
        '--version',
        version,
      ]
    end

    output, status = Open3.capture2(*command)

    raise TaskHelper::Error.new('choco did not exited normally', "chocolatey/#{action}-error", output) unless status.exited?
    raise TaskHelper::Error.new("choco exited with error code #{status.exitstatus}", "chocolatey/#{action}-error", output) if status != 0

    nil
  end
end

if __FILE__ == $PROGRAM_NAME
  ChocolateyTask.run
end
