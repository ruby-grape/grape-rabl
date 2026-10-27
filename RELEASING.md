# Releasing Grape-Rabl

Release bug fixes frequently, features less frequently, and breaking API changes deliberately. Publishing requires repository push access, RubyGems ownership, and RubyGems multi-factor authentication.

## Prepare the release

Use a clean checkout whose `origin` points to the canonical `ruby-grape/grape-rabl` repository, not a fork:

```sh
git remote get-url origin
git switch master
git pull --ff-only origin master
git status --short
```

Update `Grape::Rabl::VERSION` in [lib/grape-rabl/version.rb](lib/grape-rabl/version.rb). Increment the patch version for fixes and the minor version for new features or breaking changes while the gem is below 1.0.

Replace `(Next)` in [CHANGELOG.md](CHANGELOG.md) with the version and release date, remove `Your contribution here.`, and keep entries contiguous with a single blank line between release sections:

```markdown
#### 0.6.0 (2026-10-27)

* Release entry.
```

Resolve dependencies if necessary and run the existing lint and spec tasks:

```sh
bundle install
bundle exec rake
```

Commit and push the release preparation:

```sh
git add CHANGELOG.md RELEASING.md lib/grape-rabl/version.rb
git commit -m "Prepare grape-rabl 0.6.0"
git push origin master
```

Wait for the [GitHub Actions test workflow](https://github.com/ruby-grape/grape-rabl/actions/workflows/test.yml) to pass for that exact commit. The test matrix covers the supported Ruby/Grape combinations, including an experimental ruby-head job. If using a release-preparation PR, also require its Danger checks to pass; Danger does not run on direct pushes to `master`. Review the minimum Ruby requirement and other compatibility changes before publishing.

## Publish

Confirm that the version is not already published and that the worktree is clean. From the canonical checkout, Bundler's release task builds the gem, creates and pushes the version tag, and publishes to RubyGems:

```sh
bundle exec rake release
```

Supply a fresh RubyGems one-time password when requested. Never put credentials or one-time passwords in repository files. If publishing fails after the tag was pushed, diagnose the failure and resume with `gem push pkg/grape-rabl-0.6.0.gem`; do not move an existing release tag.

Verify that the RubyGems version, gem checksum, and remote tag match the artifact and release commit:

```sh
gem specification pkg/grape-rabl-0.6.0.gem version
shasum -a 256 pkg/grape-rabl-0.6.0.gem
curl --fail https://rubygems.org/api/v2/rubygems/grape-rabl/versions/0.6.0.json
git ls-remote origin 'refs/tags/v0.6.0*'
```

Create a non-draft GitHub release from the existing tag using the matching changelog section as its release notes:

```sh
gh release create v0.6.0 --repo ruby-grape/grape-rabl \
  --verify-tag --title "grape-rabl 0.6.0" --notes-file /path/to/release-notes.txt
```

## Prepare the next development version

After confirming publication, bump the version to the next patch development iteration and add an empty changelog section:

```markdown
#### (Next)

* Your contribution here.
```

For example, after releasing 0.6.0, set the version to `0.6.1`, commit the version and changelog changes, and push `master` normally. Never force-push `master` or overwrite a published gem or release tag.
