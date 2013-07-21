Contributing
============

tl;dr
-----

* Always work in a feature branch.
* Submit a pull request.
* Check the build status at
  https://travis-ci.org/chocolatey/puppet-chocolatey/pull_requests

Are you new to open-source? Read this blog post:
http://gun.io/blog/how-to-github-fork-branch-and-pull-request/

Good things to know
-------------------

Setup your environment:

    # Install dependencies.
    bundle install --path=~/.bundle || bundle update

    # Default rake task adds upstream remote.
    bundle exec rake

Run tests locally:

    bundle exec rake spec

Stay up-to-date with upstream:

    git fetch --prune upstream
    # for each local branch...
    git rebase upstream/master

If you are adding functionality or fixing a bug, please add a test!

Some things that will increase the chance that your pull request is accepted,
taken straight from the Ruby on Rails guide:

* Include tests that fail without your code, and pass with it
* Update the documentation, the surrounding one, examples elsewhere, guides,
  whatever is affected by your contribution

Syntax:

* Two spaces, no tabs.
* No trailing whitespace. Blank lines should not have any space.
  Use `git diff --check upstream/master..` to check.
* Prefer &&/|| over and/or.
* MyClass.my_method(my_arg) not my_method( my_arg ) or my_method my_arg.
* a = b and not a=b.
* Follow the conventions you see used in the source already.
