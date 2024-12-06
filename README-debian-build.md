# debian-build

this is a working template for a devcontainer and gitea repository that makes it
relatively easy to build debian-native packages.

for this to work you need to setup your local environment and gitea action variables/secrets
as per below.

# debian-build devcontainer

this devcontainer is for for building debian packages

## Tasks

Clean and Snapshot tasks are defined - these simply call make `maintainer-clean` and
`make snapshot` respectively.

To make a release, add and push a tag starting with v and followed by a debian-compatible
version number, e.g. v1.1.  This triggers teh create-release workflow in gitea

## Environment

Your local environment is assumed to have...
+ a working ssh agent
+ a working gpg agent
+ your DEBNAME and DEBEMAIL should match one of your GPG keys
+ environment variables:
    + `DEBNAME`: your name for signing changelogs
    + `DEBEMAIL`: your email for signing changelogs

# create-release workflow

Triggered by tags matching v*

On tagging, this workflow builds the pacakge and creates a release:
+ generate a changelog entry for the most recent changes only
+ build the release package
+ upload the .deb to the gitea debian repository
+ upload the package files to the release

## GPG Key

The GPG Key is used for signing the .changes file, and is the source of the user's name and email.

+ `secrets.GPG_PRIVATE_KEY` - a copy of your GPG private key, used for signing the .changes file
    - see https://github.com/marketplace/actions/import-gpg
    - MacOS: `gpg --armor --export-secret-key email@example.com | pbcopy`, and paste into the value of GPG_PRIVATE_KEY.  Replace the email address with your own.
+ `secrets.GPG_PASSPHRASE` - the passphrase of the GPG Key

## Package Access Token

A token is needed to upload packages to the debian repository.  (The standard gitea token doesn't allow this.)

+ `secrets.PKG_TOKEN` - a token with permissions to write packages
