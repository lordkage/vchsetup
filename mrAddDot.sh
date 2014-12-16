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
