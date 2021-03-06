# Snapsheet Core Homebrew Tap
This is a Homebrew tap for useful formulae used by engineers at Snapsheet.

## Installation
These packages require a GitHub token to be set up in your environment with the name `HOMEBREW_GITHUB_API_TOKEN`.

For the following, replace `<formula>` with the name of the package you are trying to install.

You can add this to your shell profile, or prefix it to the brew commands.
```
HOMEBREW_GITHUB_API_TOKEN=xxxxx brew ...
```

Install a specific formula from this repository:
```
brew install snapsheet/core/<formula>
```

Install the repository and then formula by name:
```
brew tap snapsheet/core
brew install <formula>
```

## Testing

This project uses [docker compose](https://docs.docker.com/compose/) to create a development environment you can use for testing purposes.

Build the development environments:
```
docker-compose build
```

This creates two services: one with RVM and installed ruby versions, and one without RVM.

Both images have a user `dev.user` that mimics the profile formulae will be installed under. To open a shell as this user, run the following:
```
docker-compose run --rm test_with_rvm bash
```

After this, you should be able to run the following commands.

### Validation
To validate that the package will work on your system, install the repository and run the following:
```
brew test <formula>
```

### Locally/Development
To test locally, install the formula from source. Clone this repository and `cd` to it from a CLI terminal.

Run The following to install a formula locally:
```
brew install --debug --build-from-source Formula/<formula>.rb
```

This will reflect any changes you make to the formula in `Formula/<formula>.rb`.

To run the test case for the formula, you must have first installed locally from source. Then run the following:
```
brew test Formula/<formula>.rb
```
