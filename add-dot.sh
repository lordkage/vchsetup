#!/bin/bash

_start_dir=`pwd` ; cd ${HOME}

_config_name=$1
_config_repo="gitosis@gitosis.temporalflux.org:dot/${_config_name}.git" # Replace with the right remote repo

# Create the remote repository named: dot/${_config_name}
vcsh ${_config_name} init

#  Add files
echo "Enter the dot files; new line to end"
until [[ -z "$_dot_file" ]]; do
   read -p '>>>' _dot_file
   if [[ ! -z "$_dot_file" ]]; then
      vcsh ${_config_name} add ${_dot_file}
   fi
done

# Confirm mr is up-to-date
vcsh mr pull

# Add to available.d
cat >~/.config/mr/available.d/vcsh.${_config_name}<<_EOF_

[\${HOME}/.config/vcsh/repo.d/${_config_name}.git]
checkout = vcsh clone ${_config_repo} ${_config_name}
_EOF_
vcsh mr add -f ~/.config/mr/available.d/vcsh.${_config_name}

# Add to config.d
_cur_dir=`pwd`; cd ~/.config/mr/config.d; ln -s ../available.d/vcsh.${_config_name} ; cd ${_cur_dir}
vcsh mr add -f ~/.config/mr/config.d/vcsh.${_config_name}

# Generate the gitignore file for the configuration repository
touch ~/.gitignore.d/${_config_name}
vcsh ${_config_name} add -f ~/.gitignore.d/${_config_name}
vcsh write-gitignore ${_config_name}

# Commit vcsh
vcsh ${_config_name} commit -a -m "Initial commit of vcsh ${_config_name}"
vcsh ${_config_name} push

# Commit (and push) changes
vcsh mr commit -m "Added vcsh ${_config_name} and link"
vcsh mr push

cd ${_start_dir}
