# Releasing Grape-Rabl

There're no particular rules about when to release grape-rabl. Release bug fixes frequently, features not so frequently and breaking API changes rarely.

### Release

Run tests, check that all tests succeed locally.

```
bundle install
rake
```

Check that the last build succeeded in [Travis CI](https://travis-ci.org/ruby-grape/grape-rabl) for all supported platforms.

Increment the version, modify [lib/grape-rabl/version.rb](lib/grape-rabl/version.rb).

*  Increment the third number if the release has bug fixes and/or very minor features, only (eg. change `0.7.1` to `0.7.2`).
*  Increment the second number if the release contains major features or breaking API changes (eg. change `0.7.1` to `0.8.0`).

Change "Next Release" in [CHANGELOG.md](CHANGELOG.md) to the new version.

```
### 0.7.2 (February 6, 2014)
```

Remove the line with "Your contribution here.", since there will be no more contributions to this release.

Commit your changes.

```
git add CHANGELOG.md lib/grape-rabl/version.rb
git commit -m "Preparing for release, 0.7.2."
git push origin master
```

Release.

```
$ rake release

grape-rabl 0.7.2 built to pkg/grape-rabl-0.7.2.gem.
Tagged v0.7.2.
Pushed git commits and tags.
Pushed grape-rabl 0.7.2 to rubygems.org.
```

### Prepare for the Next Version

Add the next release to [CHANGELOG.md](CHANGELOG.md).

```
#### Next

* Your contribution here.
```

Commit your changes.

```
git add CHANGELOG.md
git commit -m "Preparing for next development iteration, 0.7.3."
git push origin master
```
