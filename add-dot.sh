#!/bin/bash

_start_dir=$PWD ; cd ${HOME}

_config_name=$1
if [[ ${_config_name} == '' ]]; then echo "BORK; please provide a repo name"; exit 128; fi
_config_repo="gitosis@gitosis.temporalflux.org:dot/${_config_name}.git" # Replace with the right remote repo

_mr_configuration_dir=".config/mr"
_mr_available_dir="${_mr_configuration_dir}/available.d"
_mr_repo_file="vcsh.${_config_name}"
_mr_repo_config="${_mr_available_dir}/${_mr_repo_file}"
_mr_configured_dir="${_mr_configuration_dir}/config.d"

# Create the remote repository named: dot/${_config_name}
vcsh init ${_config_name}

#  Add files
echo "Enter the dot files; new line to end"
read -p '>>> ' -e _dot_file
until [[ -z "$_dot_file" ]]; do
   vcsh ${_config_name} add ${_dot_file}
   read -p '>>> ' -e _dot_file
done

# Generate the gitignore file for the configuration repository
touch ~/.gitignore.d/${_config_name}
vcsh ${_config_name} add ~/.gitignore.d/${_config_name}
vcsh write-gitignore ${_config_name}

# Commit vcsh
vcsh ${_config_name} commit -a -m "Initial commit of vcsh ${_config_name}"
vcsh ${_config_name} remote add origin ${_config_repo}
vcsh ${_config_name} push -u origin master

exit

# Confirm mr is up-to-date
vcsh mr pull

# Add to available.d
cat >${_mr_repo_config}<<_EOF_
[\${HOME}/.config/vcsh/repo.d/${_config_name}.git]
checkout = vcsh clone ${_config_repo} ${_config_name}
_EOF_
vcsh mr add -f ${_mr_repo_config}

# Add to config.d
cd ${_mr_configured_dir} ; ln -s ../available.d/${_mr_repo_file}
cd ${HOME} ; vcsh mr add -f ${_mr_configured_dir}/${_mr_repo_file}

# Commit (and push) changes
vcsh mr commit -m "Added vcsh ${_config_name} and link"
vcsh mr push

cd ${_start_dir}
