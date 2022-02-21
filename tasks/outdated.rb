#!/opt/puppetlabs/puppet/bin/ruby
# frozen_string_literal: true

require 'open3'
require 'puppet'

require_relative '../../ruby_task_helper/files/task_helper.rb'

# Retun a list of packages with pending updates
class ChocolateyOutdatedTask < TaskHelper
  def task(**_kwargs)
    output, status = Open3.capture2('choco', 'outdated', '--no-color', '--limit-output')

    raise TaskHelper::Error.new('choco did not exited normally', 'chocolatey/outdated-error', output) unless status.exited?
    raise TaskHelper::Error.new("choco exited with error code #{status.exitstatus}", 'chocolatey/outdated-error', output) unless [0, 2].include?(status.exitstatus)

    result = []
    output.split("\n").each do |line|
      parts = line.split('|')

      next unless parts.count == 4

      result << {
        package: parts[0],
        version: parts[1],
        available_version: parts[2],
        pinned: parts[3] == 'true'
      }
    end

    { status: result }
  end
end

if __FILE__ == $PROGRAM_NAME
  ChocolateyOutdatedTask.run
end
