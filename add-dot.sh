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

_user_resp='n'
read -p "Any dot files needing encryption? " -e _user_resp
if [[ ${_user_resp} =~ ^[Yy]* ]]; then
   echo "All your encrypted dots are belong to no one; this is an unimplemented function"
   echo "FIXME : touch ${HOME}/.gitattributes.d/${_config_name}"
   # Add encrypted files
   echo "Enter the dot files you wish to be encrypted; new line to end"
   read -p '>>> ' -e _dot_file
   until [[ -z "$_dot_file" ]]; do
      echo "FIXME : Need to add the magic : ${_dot_file}"
#      vcsh ${_config_name} add ${_dot_file}
      read -p '>>> ' -e _dot_file
   done
   echo "FIXME : vcsh ${_config_name} add ${HOME}/.gitattributes.d/${_config_name}"
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

cd ${_start_dir}
