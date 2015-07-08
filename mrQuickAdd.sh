#!/bin/bash

if [[ $# -eq 2 ]]; then
   _git_repo_uri=$2
   IFS='./' read -ra _git_repo_uri_parts <<< "${_git_repo_uri}"
   _git_repo_dir=${_git_repo_uri_parts[2]}
   if [ -d $PWD/${_git_repo_dir}/.git ]; then
      echo "Repository directory ${_git_repo_dir} already exists, assuming correct."
   elif [ -d $PWD/${_git_repo_dir} ]; then
      echo "Directory named ${_git_repo_dir} already exists, BORK."
      exit 1
   else
      git clone ${_git_repo_uri} ${_git_repo_dir}
   fi
   cd ${_git_repo_dir}
fi

_working_dir=$PWD
_working_project_name=${PWD##*/}
_working_project_config_name=${_working_project_name}
_working_project_url=$(git config --get remote.origin.url)
_mr_configuration_dir="${HOME}/.config/mr"
_mr_available_dir="${_mr_configuration_dir}/available.d"
if [[ $# -gt 0 ]]; then
   _mr_project_config_prefix=$1; shift
   _working_project_config_name="${_mr_project_config_prefix}-${_working_project_config_name}"
fi
_mr_project_config="${_mr_available_dir}/${_working_project_config_name}"
_mr_configured_dir="${_mr_configuration_dir}/config.d"

if [ ! -d ${_working_dir}/.git ]; then
   echo "Not a git repo; exiting"
   exit
fi

if [ -e ${_mr_project_config} ]; then
   echo "Project configuration (${_mr_project_config}) pre-exists; aborting"
   exit 1
fi

mr -c ${_mr_project_config} register
sed -i '' -e "s#${HOME}#\${HOME}#" ${_mr_project_config}

if [ $(command -v gem) ]; then
   if [ $(gem list -i git-up) ]; then
      _git_update_command='git up'
   else
      _git_update_command='git remote prune origin && git fetch --all && git fetch --tags && git pull'
   fi
fi

cat >>${_mr_project_config}<<_EOF_
update = ${_git_update_command}
push = :
commit = :
_EOF_

cd ${_mr_configured_dir}
ln -vs ../available.d/${_working_project_config_name}
cd ${_working_dir}

vcsh mr status --short --branch -unormal

cat >/dev/stdout<<_EOF_

Final manual commands:

rm -v ~/${_mr_configured_dir}/${_working_project_config_name}

vcsh mr add ${_mr_project_config}
vcsh mr commit -m "Adding ${_working_project_name}"
vcsh mr push

_EOF_

if [ $(command -v stree) ]; then
   cat >/dev/stdout<<_EOF_
stree ${_working_dir}

_EOF_
fi
