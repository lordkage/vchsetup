#!/bin/bash

_start_dir=$PWD ; cd ${HOME}

if [[ $# -ne 1 ]]; then
   echo "BORK; please provide a repo name"
   exit 128
elif [[ $# -eq 1 ]]; then
   _config_name=$1
else
   echo "BORK; too many args"
   exit 1
fi

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

cd ${_start_dir}
