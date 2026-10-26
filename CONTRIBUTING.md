Contributing to Grape-Rabl
==========================

Grape-Rabl is work of [many of contributors](https://github.com/ruby-grape/grape-rabl/graphs/contributors). You're encouraged to submit [pull requests](https://github.com/ruby-grape/grape-rabl/pulls), [propose features and discuss issues](https://github.com/ruby-grape/grape-rabl/issues). When in doubt, ask a question in the [Grape Google Group](http://groups.google.com/group/ruby-grape).

#### Fork the Project

Fork the [project on Github](https://github.com/ruby-grape/grape-rabl) and check out your copy.

```
git clone https://github.com/contributor/grape-rabl.git
cd grape-rabl
git remote add upstream https://github.com/ruby-grape/grape-rabl.git
```

#### Create a Topic Branch

Make sure your fork is up-to-date and create a topic branch for your feature or bug fix.

```
git checkout master
git pull upstream master
git checkout -b my-feature-branch
```

#### Bundle Install and Test

Ensure that you can build the project and run tests.

```
bundle install
bundle exec rake
```

CI runs on GitHub Actions with Grape 1.x and 2.x on Ruby 2.7, Grape 1.x through 4.x on Ruby 3.3, and Grape 4.x on Ruby 3.4, Ruby 4.0, and ruby-head (allowed to fail). Ruby 2.7 jobs use Ubuntu 22.04; newer Rubies use the latest Ubuntu runner.

Select a Grape major version locally using `GRAPE_VERSION`. Resolve the bundle again when switching versions:

```sh
GRAPE_VERSION=4 bundle update
GRAPE_VERSION=4 bundle exec rake
```

Use `GRAPE_VERSION=1`, `2`, or `3` for the other supported majors. The Grape 1.x bundle selects Rack 2.x because Grape 1.x is not compatible with Rack 3.x. Without `GRAPE_VERSION`, Bundler selects the latest Grape compatible with your Ruby.

#### Write Tests

Try to write a test that reproduces the problem you're trying to fix or describes a feature that you want to build. Add to [spec/grape-rabl](spec/grape-rabl).

We definitely appreciate pull requests that highlight or reproduce a problem, even without a fix.

#### Write Code

Implement your feature or bug fix.

Ruby style is enforced with [Rubocop](https://github.com/bbatsov/rubocop), run `bundle exec rubocop` and fix any style issues highlighted.

Make sure that `bundle exec rake` completes without errors.

#### Write Documentation

Document any external behavior in the [README](README.md).

#### Update Changelog

Add a line to [CHANGELOG](CHANGELOG.md) under *Next Release*. Make it look like every other line, including your name and link to your Github account.

#### Commit Changes

Make sure git knows your name and email address:

```
git config --global user.name "Your Name"
git config --global user.email "contributor@example.com"
```

Writing good commit logs is important. A commit log should describe what changed and why.

```
git add ...
git commit
```

#### Push

```
git push origin my-feature-branch
```

#### Make a Pull Request

Go to https://github.com/contributor/grape-rabl and select your feature branch. Click the 'Pull Request' button and fill out the form. Pull requests are usually reviewed within a few days.

#### Rebase

If you've been working on a change for a while, rebase with upstream/master.

```
git fetch upstream
git rebase upstream/master
git push origin my-feature-branch -f
```

#### Update CHANGELOG Again

Update the [CHANGELOG](CHANGELOG.md) with the pull request number. A typical entry looks as follows.

```
* [#123](https://github.com/ruby-grape/grape-rabl/pull/123): Reticulated splines - [@contributor](https://github.com/contributor).
```

Amend your previous commit and force push the changes.

```
git commit --amend
git push origin my-feature-branch -f
```

#### Check on Your Pull Request

Go back to your pull request after a few minutes and check its GitHub Actions results. Everything should look green, otherwise fix issues and amend your commit as described above.

#### Be Patient

It's likely that your change will not be merged and that the nitpicky maintainers will ask you to do more, or fix seemingly benign problems. Hang on there!

#### Thank You

Please do know that we really appreciate and value your time and work. We love you, really.
