#!/bin/bash

_working_dir=$PWD
_working_project_name=${PWD##*/}
_working_project_url=$(git config --get remote.origin.url)
_mr_configuration_dir="${HOME}/.config/mr"
_mr_available_dir="${_mr_configuration_dir}/available.d"
_mr_project_config="${_mr_available_dir}/${_working_project_name}"
_mr_configured_dir="${_mr_configuration_dir}/config.d"

if [ ! -d ${_working_dir}/.git ]; then
   echo "Not a git repo; exiting"
   exit
fi

mr -c ${_mr_project_config} register
sed -i -e "s#${HOME}#\${HOME}#" ${_mr_project_config}

cat >>${_mr_project_config}<<_EOF_
update = git remote prune origin && git pull
push = :
commit = :
_EOF_

cd ${_mr_configured_dir}
ln -vs ../available.d/${_working_project_name}
cd ${_working_dir}

vcsh mr status --short --branch -unormal

cat >/dev/stdout<<_EOF_
Remember to add the new config to mr's repo

vcsh mr add ${_mr_project_config}
vcsh mr commit -a -m "Adding ${_working_project_name}"
vcsh mr push
_EOF_
