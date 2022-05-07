#!/bin/bash

_start_dir=$PWD ; cd ${HOME}

export VCSH_GITATTRIBUTES=none

_is_git_crypt='n'

if [[ $# -ne 1 ]]; then
   echo "BORK; please provide a repo name"
   exit 128
elif [[ $# -eq 1 ]]; then
   _config_repo_prefix='dot'
   _config_name=$1
elif [[ $# -eq 2 ]]; then
   _config_repo_prefix=$1
   _config_name=$2
else
   echo "BORK; too many args"
   exit 1
fi

_config_repo="gitosis@gitosis.temporalflux.org:${_config_repo_prefix}/${_config_name}.git" # Replace with the right remote repo

_mr_configuration_dir=".config/mr"
_mr_available_dir="${_mr_configuration_dir}/available.d"
_mr_repo_file="vcsh.${_config_name}"
_mr_repo_config="${_mr_available_dir}/${_mr_repo_file}"
_mr_configured_dir="${_mr_configuration_dir}/config.d"

echo -e "Using ${HOME} as base for all actions within script\n"

vcsh ${_config_name} log -n 1 --oneline > /dev/null 2>&1
xc=${PIPESTATUS[0]}
if [ ${xc} -ne 0 ]; then
   # Create the remote repository named: dot/${_config_name}
   vcsh init ${_config_name}
   _commit_msg="Initial commit of vcsh ${_config_name}"
else
   _commit_msg="Assisted commit of vcsh ${_config_name}"
fi

# Add files
echo "Enter the dot files; new line to end"
read -p '>>> ' -e _dot_file
until [[ -z "$_dot_file" ]]; do
   vcsh ${_config_name} add ${_dot_file}
   read -p '>>> ' -e _dot_file
done

# FIXME - The files are added to the repo before the gitattributes are in affect
# `vcsh [repo] crypt status -f` fixes this... Or order of add.

_user_resp='n'
read -p "Any dot files needing encryption? " -e _user_resp
if [[ ${_user_resp} == [Yy]* ]]; then
   echo "All your encrypted dots are belong to us; this is an experimental function"
   touch ${HOME}/.gitattributes.d/${_config_name}
   vcsh upgrade ${_config_name}
   vcsh ${_config_name} crypt init
   # Add encrypted files
   echo "Enter the dot files you wish to be encrypted; new line to end"
   read -p '>>> ' -e _dot_file
   until [[ -z "$_dot_file" ]]; do
      echo "${_dot_file} filter=git-crypt diff=git-crypt" >> ${HOME}/.gitattributes.d/${_config_name}
      vcsh ${_config_name} add ${_dot_file}
      read -p '>>> ' -e _dot_file
   done
   vcsh ${_config_name} add ${HOME}/.gitattributes.d/${_config_name}
   _is_git_crypt='y'
   echo ''; echo "Output key; new line to end"
   read -p '>>> ' -e _key_path
fi

# Generate the gitignore file for the configuration repository
touch ${HOME}/.gitignore.d/${_config_name}
vcsh ${_config_name} add ${HOME}/.gitignore.d/${_config_name}
vcsh write-gitignore ${_config_name}

# FIXME - Add check for branch.master.rebase
cat >/dev/stdout<<_EOF_

# Commit vcsh
vcsh ${_config_name} config branch.master.rebase true
vcsh ${_config_name} commit -a -m "${_commit_msg}"
vcsh ${_config_name} remote add origin ${_config_repo}
vcsh ${_config_name} push -u origin master
_EOF_

if [[ $_is_git_crypt == y ]]; then
   cat >/dev/stdout<<_EOF_
vcsh ${_config_name} crypt export-key ${_key_path}
vcsh ${_config_name} crypt status
_EOF_
fi

cd ${_start_dir}
