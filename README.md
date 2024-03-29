# VCH Setup

**V**ersion **C**ontroled **H**ome Setup Scripting.

These scripts help me manage multiple repositories which combine to form
a version controled home.

## Software

Giving credit to the software projects I am wrapping

 - vcsh by Richard Hartmann (RichiH); https://github.com/RichiH/vcsh
 - mr/myrepos by Joey Hess (joeyh); https://github.com/joeyh/myrepos
 - git-crypt by Andrew Ayer (AGWA); https://github.com/AGWA/git-crypt

## Assumed Software

 - git
 - brew (Mac OS)
 - internet utils (Linux)

## Quick Start

Run the thing

## Basic Usage

### Adding new dot repo

- `add-dot.sh [dot_repo_name]`
- `mrAddDot.sh [dot_repo_name]`

## Older Information

```bash
grep forsaken EXAMPLE.vcsh | awk -F'~>' '{ print $NF }' | sed -e 's/tmux/vimrc/g'

vcsh init vim
vcsh vim add ~/.vimrc ~/.vim
vcsh write-gitignore vim
vcsh vim add -f .gitignore.d/vim
vcsh write-gitignore vim
vcsh vim add .gitignore.d/vim
vcsh vim commit -m 'Initial commit of my Vim configuration'
# optionally push your files to a remote
vcsh vim remote add origin <remote>
vcsh vim push -u origin master
# from now on you can push additional commits like this
vcsh vim push
```

### Assumptions

 - vcsh installed, up-to-date: older than 2014-02-21
 - git-crypt installed
 - VCSH repo named 'foo'

#### Actions

 - Update your vcsh repo
   `vcsh upgrade foo`
 - Create the gitattributes file for this repo
   ```bash
   mkdir ~/.gitattributes.d
   touch ~/.gitattributes.d/foo
   ```
 - Add it to git your git repo
   `vcsh foo add ~/.gitattributes.d/foo`
 - Follow the readme of git-crypt until the .gitattributes part
 - Instead of .gitattributes, put the config in ~/.gitattributes.d/foo
   ```bash
   cat >~/.gitattrubutes.d/foo<<EOD
   secret filter=git-crypt diff=git-crypt
   passwds filter=git-crypt diff=git-crypt
   *magic* filter=git-crypt diff=git-crypt
   EOD
   ```
 - Continue the readme of git-crypt
   ```bash
   git-crypt init
   git-crypt add-gpg-user DFE3287A
   ```
