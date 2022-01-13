#!/opt/puppetlabs/puppet/bin/ruby
# frozen_string_literal: true

require 'open3'
require 'puppet'

require_relative '../../ruby_task_helper/files/task_helper.rb'

# Manage installing, upgrading and uninstalling packages
class ChocolateyPinTask < TaskHelper
  def task(action: nil, package: nil, version: nil)
    command = [
      'choco',
      'pin',
      action,
      '--no-color',
      '--limit-output',
    ]

    if package
      command += [
        '--name',
        package,
      ]
    end

    if version
      command += [
        '--version',
        version,
      ]
    end

    output, status = Open3.capture2(*command)

    raise TaskHelper::Error.new('choco did not exited normally', "chocolatey/pin-#{action}-error", output) unless status.exited?
    raise TaskHelper::Error.new("choco exited with error code #{status.exitstatus}", "chocolatey/pin-#{action}-error", output) if status != 0

    if action == 'list'
      result = []

      output.split("\n").each do |line|
        parts = line.split('|')

        next unless parts.count == 2

        result << {
          package: parts[0],
          version: parts[1],
        }
      end

      return { status: result }
    end

    nil
  end
end

if __FILE__ == $PROGRAM_NAME
  ChocolateyPinTask.run
end
