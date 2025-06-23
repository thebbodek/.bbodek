# .bbodek
A dotfile directory for storing sensitive keys, credentials, and shared files with an all-in-one Makefile to initialize BBODEK local development environment using infisical.

## Prerequisites
- [Infisical Account](https://infisical.com/) for retrieving keys and credentials
- [Tailscale Account](https://tailscale.com/) for SSH connection
- [Homebrew](https://brew.sh/) for installing infisical CLI
- [gettext](https://formulae.brew.sh/formula/gettext) for using `envsubst` command
  - `brew install gettext`, `brew link --force gettext`

## Installation
```bash
git clone https://github.com/thebbodek/.bbodek.git ~/.bbodek

# Setup Infisical CLI (aws/keys/ssh required)
brew install infisical/get-cli/infisical
infisical login
cd ~/.bbodek && infisical init # Select 'No' for questions

# Run
make

# or run separately
make ssh
make aws
make keys
make editor
```

## Guide
### Update AWS Credentials
1. Update environment variable in infisical `/org` directory.
2. Define environment variable in `~/.bbodek/aws/credentials.[env].template`.
3. Run `make aws` to sync changes.

### Update SSH Config
1. Update `~/.bbodek/ssh/config`.
2. Run `make ssh` to apply changes.

### Add Private Key
1. Update environment variable in infisical `/_keys` directory.
2. Define environment variable in `~/.bbodek/keys/[name].pem.template`.
3. Run `make keys` to sync changes.
