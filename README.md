# .bbodek
A dotfile directory for storing sensitive keys and credentials with an all-in-one bash script to initialize BBODEK local backend development environment using infisical.

## Prerequisites
- [Infisical](https://infisical.com/) for retrieving keys and credentials
- [Tailscale](https://tailscale.com/) for SSH connection

## Installation
```bash
git clone https://github.com/thebbodek/.bbodek.git ~/.bbodek

# Setup Infisical CLI
brew install infisical/get-cli/infisical
infisical login

# Initialize
chmod +x ~/.bbodek/initialize.sh
~/.bbodek/initialize.sh
```

## Guide
### Update AWS Credentials
1. Update environment variable in infisical `/org` directory.
2. Define environment variable in `~/.bbodek/aws/credentials.[env].template`.
3. Run `~/.bbodek/initialize.sh` to sync changes.

### Update SSH Config
1. Update `~/.bbodek/ssh/config`.

### Add Private Key
1. Update environment variable in infisical `/_keys` directory.
2. Define environment variable in `~/.bbodek/keys/[name].pem.template`.
3. Run `~/.bbodek/initialize.sh` to sync changes.
