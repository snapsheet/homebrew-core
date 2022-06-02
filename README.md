# Snapsheet Core Homebrew Tap
This is a Homebrew tap for useful formulae used by engineers at Snapsheet.

* [Explanation of how Homebrew works](https://www.quora.com/How-does-Homebrew-work-internally?share=1)

## Installing Formulae via Homebrew
Packages installed by these formulae require an environment variable with the GitHub token to be present with the name `HOMEBREW_GITHUB_API_TOKEN`. If you already use the Github API for your projects, this can be the same as your `GITHUB_TOKEN`. Add the following to your `.profile`/`.bashrc`/`.zshrc` file, where `xxxxx` represents your token. This will ensure that you are authenticated when installing a Snapsheet formula or updating a Snapsheet formula via Homebrew.
```
export HOMEBREW_GITHUB_API_TOKEN=xxxxx
```

Homebrew will install formulas based on the naming convention of this repository and the ruby scripts found in the `Formula/` directory. If you want to run the installer for `Formula/tinker.rb`, then you would run `brew install snapsheet/core/tinker`.

It's possible to install `snapsheet/core` as a tap, but not recommended. This will cause confusion if the names of one of these formula collides with a formula in [Homebrew's default list](https://github.com/Homebrew/homebrew-core).

## Validation
To validate that the package will work on your system, install the repository and run the following:
```
brew test <formula>
```

## Development
To install from a formula in a local ruby script, run installation with `--build-from-source` followed by the path to the ruby script.
```
brew install --build-from-source Formula/<formula>.rb
```

Adding the `--debug` flag will give you additional debug options if the installation fails.

## Testing With Linux
This project uses [docker compose](https://docs.docker.com/compose/) to create a development environment you can use for testing installations on Linux.

```
docker compose build
```

This will create a development Docker image with RVM and a few installed ruby versions. The image will run with a user `dev.user` that mimics the profile formulae will be installed under. To open a bash shell as this user, run the following:
```
docker compose run --rm cli
```

Now you will be able to run any of the previous commands to test formulae on Linux.
