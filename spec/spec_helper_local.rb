# require 'pry' if Bundler.rubygems.find_name('pry').any?
# require 'puppetlabs_spec_helper/module_spec_helper'
# require 'rake'
# require 'fileutils'

RSpec.configure do |_c|
  # set the environment variable before files are loaded, otherwise it is too late
  ENV['ChocolateyInstall'] = 'c:\blah'

  begin
    # rubocop:disable RSpec/AnyInstance
    Win32::Registry.any_instance.stubs(:[]).with('Bind')
    Win32::Registry.any_instance.stubs(:[]).with('Domain')
    Win32::Registry.any_instance.stubs(:[]).with('ChocolateyInstall').raises(Win32::Registry::Error.new(2), 'file not found yo')
    # rubocop:enable RSpec/AnyInstance
  rescue # rubocop:disable Lint/HandleExceptions:
    # ignore errors thrown while setting up mocks
  end
end

# We need this because the RAL uses 'should' as a method.  This
# allows us the same behaviour but with a different method name.
class Object
  alias must should
  alias must_not should_not
end
