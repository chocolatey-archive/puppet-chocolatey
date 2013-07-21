# vim: set ts=2 sw=2 ai et:
require 'spec_helper'

describe '.travis.yml' do
  it 'exists' do
    File.exist?(subject).should be_true
  end

  it 'is a valid travis-ci configuration' do
    %x!travis-lint!
    $?.success?.should be_true
  end
end
