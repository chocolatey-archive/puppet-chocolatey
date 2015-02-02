require 'spec_helper_acceptance'

describe 'chocolatey provider' do
  context 'when chocolatey is installed' do
    it 'should install notepadplusplus with chocolatey' do

      pp = <<-PP
        package { 'notepadplusplus':
          ensure          => installed,
          provider        => 'chocolatey',
        }
      PP

      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end
  end
end