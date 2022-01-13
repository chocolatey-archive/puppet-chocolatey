#!/opt/puppetlabs/puppet/bin/ruby
# frozen_string_literal: true

require_relative '../../ruby_task_helper/files/task_helper.rb'

require 'open3'
require 'puppet'

# Return a list of installed packages
class ChocolateyStatusTask < TaskHelper
  def task(**_kwargs)
    output, status = Open3.capture2('choco', 'list', '--local-only', '--no-color', '--limit-output')

    raise TaskHelper::Error.new('choco did not exited normally', 'chocolatey/status-error', output) unless status.exited?
    raise TaskHelper::Error.new("choco exited with error code #{status.exitstatus}", 'chocolatey/status-error', output) if status != 0

    result = []

    output.split("\n").each do |line|
      parts = line.split('|')

      next unless parts.count == 2

      result << {
        package: parts[0],
        version: parts[1],
      }
    end

    { status: result }
  end
end

if __FILE__ == $PROGRAM_NAME
  ChocolateyStatusTask.run
end
