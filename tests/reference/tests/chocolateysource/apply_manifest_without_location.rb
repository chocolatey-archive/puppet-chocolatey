require 'chocolatey_helper'
test_name 'MODULES-3037 - Add Source: Apply manifest without location'
confine(:to, :platform => 'windows')

backup_config

# arrange
chocolatey_src = <<-PP
  chocolateysource {'chocolatey':
    ensure   => present,
  }
PP

# teardown
teardown do
  reset_config
end

# act
step 'Apply Manifest'
apply_manifest(chocolatey_src, :catch_failures => true) do
  step 'Verify Result'
  assert_match(/Notice: \/Stage\[main\]\/Main\/Chocolateysource\[chocolatey\]\/location: location changed 'https:\/\/chocolatey.org\/api\/v2\/' to 'chocolatey'/, stdout, "stdout did not match expected")
end
