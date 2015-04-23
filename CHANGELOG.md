2015-04-23 Release 0.5.3:
- Fix to readme for rismoney/chocolatey deprecation

2015-04-23 Release 0.5.2:
- Update ReadMe
- Add support for Windows 10.
- Fixes [#56](https://github.com/chocolatey/puppet-chocolatey/pull/56) - Avoiding puppet returning 2 instead of 0 when there are no changes to be done.

2015-03-31 Release 0.5.1
- Fixes [#54](https://github.com/chocolatey/puppet-chocolatey/issues/54) - Blocking: Linux masters throw error if module is present

2015-03-30 Release 0.5.0
- Provider enhancements
- Better docs
- Works with both compiled and powershell Chocolatey clients
- Fixes #50 - work with newer compiled Chocolatey client (0.9.9+)
- Fixes #43 - check for installed packages is case sensitive
- Fixes #18 - The OS handle's position is not what FileStream expected.
- Fixes #52 - Document best way to pass options with spaces (#15 also related)
- Fixes #26 - Document Chocolatey needs to be installed by other means
