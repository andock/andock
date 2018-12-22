#!/bin/bash

ANSIBLE_VERSION="2.6.2"
ANDOCK_VERSION=0.1.0

REQUIREMENTS_ANDOCK_BUILD='0.4.1'
REQUIREMENTS_ANDOCK_ENVIRONMENT='0.5.2'
REQUIREMENTS_ANDOCK_SERVER='0.2.2'
REQUIREMENTS_ANDOCK_SERVER_DOCKSAL='v1.11.1'
REQUIREMENTS_ANDOCK_SERVER_SSH2DOCKSAL='1.0-rc.2'
REQUIREMENTS_SSH_KEYS='0.3'

DEFAULT_CONNECTION_NAME="default"

ANDOCK_PATH="/usr/local/bin/andock"
ANDOCK_PATH_UPDATED="/usr/local/bin/andock.updated"

ANDOCK_HOME="$HOME/.andock"
ANDOCK_INVENTORY="./.andock/connections"
ANDOCK_INVENTORY_GLOBAL="$ANDOCK_HOME/connections"
ANDOCK_PLAYBOOK="$ANDOCK_HOME/playbooks"

URL_REPO="https://raw.githubusercontent.com/andock/andock"
BASHIDS_URL="https://raw.githubusercontent.com/benwilber/bashids/master/bashids"
URL_ANDOCK="${URL_REPO}/master/bin/andock.sh"
DEFAULT_ERROR_MESSAGE="Oops. There is probably something wrong. Check the logs."

export ANSIBLE_ROLES_PATH="${ANDOCK_HOME}/roles"

export ANSIBLE_HOST_KEY_CHECKING=False

export ANSIBLE_SSH_PIPELINING=True

export ANSIBLE_STDOUT_CALLBACK=yaml

#export ANSIBLE_DEBUG=1

config_git_target_repository_path=""
config_virtual_hosts=""
config_project_name=""
config_git_repository_path=""

# @author Leonid Makarov
# Console colors
red='\033[0;91m'
red_bg='\033[101m'
green='\033[0;32m'
yellow='\033[1;33m'
NC='\033[0m'

#------------------------------ Help functions --------------------------------
# parse yml file:
# See https://gist.github.com/pkuczynski/8665367
_parse_yaml() {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*'
   local fs
   fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F"$fs" '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

# Yes/no confirmation dialog with an optional message
# @param $1 confirmation message
# @author Leonid Makarov
_confirm ()
{
	while true; do
		read -p "$1 [y/n]: " answer
		case "$answer" in
			[Yy]|[Yy][Ee][Ss] )
				break
				;;
			[Nn]|[Nn][Oo] )
				exit 1
				;;
			* )
				echo 'Please answer yes or no.'
		esac
	done
}

# Yes/no confirmation dialog with an optional message
# @param $1 confirmation message
_confirmAndReturn ()
{
	while true; do
		read -p "$1 [y/n]: " answer
		case "$answer" in
			[Yy]|[Yy][Ee][Ss] )
				echo 1
				break
				;;
			[Nn]|[Nn][Oo] )
				echo 0
				break
				;;
			* )
				echo 'Please answer yes or no.'
		esac
	done
}

# Nicely prints command help
# @param $1 command name
# @param $2 description
# @param $3 [optional] command color
# @author Oleksii Chekulaiev
printh ()
{
    local COMMAND_COLUMN_WIDTH=25;
    case "$3" in
        yellow)
        printf "  ${yellow}%-${COMMAND_COLUMN_WIDTH}s${NC}" "$1"
        echo -e "  $2"
        ;;
    green)
        printf "  ${green}%-${COMMAND_COLUMN_WIDTH}s${NC}" "$1"
        echo -e "  $2"
    ;;
    *)
        printf "  %-${COMMAND_COLUMN_WIDTH}s" "$1"
        echo -e "  $2"
    ;;
    esac

}

# @author Leonid Makarov
echo-red () { echo -e "${red}$1${NC}"; }
# @author Leonid Makarov
echo-green () { echo -e "${green}$1${NC}"; }
# @author Leonid Makarov
echo-yellow () { echo -e "${yellow}$1${NC}"; }
# @author Leonid Makarov
echo-error () {
	echo -e "${red_bg} ERROR: ${NC} ${red}$1${NC}";
	shift
	# Echo other parameters indented. Can be used for error description or suggestions.
	while [[ "$1" != "" ]]; do
		echo -e "         $1";
		shift
	done
}

# @author Leonid Makarov
# rewrite previous line
echo-rewrite ()
{
	echo -en "\033[1A"
	echo -e "\033[0K\r""$1"
}

# @author Leonid Makarov
echo-rewrite-ok ()
{
    echo-rewrite "$1 ${green}[OK]${NC}"
}


# Like if_failed but with more strict error
# @author Leonid Makarov
if_failed_error ()
{
    if [ ! $? -eq 0 ]; then
        echo-error "$@"
        exit 1
    fi
}

# Ask for input
# @param $1 Question
_ask ()
{
	# Skip checks if not running interactively (not a tty or not on Windows)
	read -p "$1: " answer
	echo $answer
}

# Ask for password
# @param $1 Question
_ask_pw ()
{
	# Skip checks if not running interactively (not a tty or not on Windows)
	read -s -p "$1 : " answer
	echo $answer
}

#------------------------------ SETUP --------------------------------

# Generate playbook files
generate_playbooks()
{
    mkdir -p ${ANDOCK_PLAYBOOK}
    echo "---
- hosts: andock-docksal-server
  roles:
    - { role: andock.build }
" > "${ANDOCK_PLAYBOOK}/build.yml"

    echo "---
- hosts: andock-docksal-server
  gather_facts: true
  roles:
    - { role: andock.environment }
" > "${ANDOCK_PLAYBOOK}/fin.yml"

    echo "---
- hosts: andock-docksal-server
  gather_facts: false
  tasks:
    - include_role:
        name: andock.fin
        vars_from: default.yml
    - debug: 'X'

" > "${ANDOCK_PLAYBOOK}/fin_run.yml"


    echo "---
- hosts: andock-docksal-server
  roles:
    - role: andock-ci.ansible_role_ssh_keys
      ssh_keys_clean: False
      ssh_keys_user:
        andock:
          - \"{{ ssh_key }}\"
" > "${ANDOCK_PLAYBOOK}/server_ssh_add.yml"

    echo "---
- hosts: andock-docksal-server
  roles:
    - { role: andock.server }
" > "${ANDOCK_PLAYBOOK}/server_install.yml"

}

# Install ansible
# and ansible galaxy roles
install_andock()
{
    echo-green ""
    echo-green "Installing andock version: ${ANDOCK_VERSION} ..."

    echo-green ""
    echo-green "Installing ansible:"

    sudo apt-get update
    sudo apt-get install whois sudo build-essential libssl-dev libffi-dev python-dev -y

    set -e

    # Install bashids
    sudo curl -fsSL ${BASHIDS_URL} -o /usr/local/bin/bashids &&
    sudo chmod +x /usr/local/bin/bashids

    # Don't install own pip inside travis.
    if [ "${TRAVIS}" = "true" ]; then
        sudo pip install ansible=="${ANSIBLE_VERSION}"
    else
        wget https://bootstrap.pypa.io/get-pip.py
        sudo python get-pip.py
        sudo pip install ansible=="${ANSIBLE_VERSION}"
        rm get-pip.py
    fi
    sudo pip install urllib3 pyOpenSSL ndg-httpsclient pyasn1 jmespath

    which ssh-agent || ( sudo apt-get update -y && sudo apt-get install openssh-client -y )

    install_configuration
    echo-green ""
    echo-green "andock was installed successfully"
}

# Install ansible galaxy roles.
install_configuration ()
{
    mkdir -p $ANDOCK_INVENTORY_GLOBAL
    generate_playbooks
    echo-green "Installing roles:"
    ansible-galaxy install andock.server,v${REQUIREMENTS_ANDOCK_SERVER} --force
    ansible-galaxy install andock.build,v${REQUIREMENTS_ANDOCK_BUILD} --force
    ansible-galaxy install andock.environment,v${REQUIREMENTS_ANDOCK_ENVIRONMENT} --force
    ansible-galaxy install andock-ci.ansible_role_ssh_keys,v${REQUIREMENTS_SSH_KEYS} --force


}

# Based on docksal update script
# @author Leonid Makarov
self_update()
{
    echo-green "Updating andock..."
    local new_andock
    new_andock=$(curl -kfsSL "$URL_ANDOCK?r=$RANDOM")
    if_failed_error "andock download failed."

    # Check if fin update is required and whether it is a major version
    local new_version
    new_version=$(echo "$new_andock" | grep "^ANDOCK_VERSION=" | cut -f 2 -d "=")
    if [[ "$new_version" != "$ANDOCK_VERSION" ]]; then
        local current_major_version
        current_major_version=$(echo "$ANDOCK_VERSION" | cut -d "." -f 1)
        local new_major_version
        new_major_version=$(echo "$new_version" | cut -d "." -f 1)
        if [[ "$current_major_version" != "$new_major_version" ]]; then
            echo -e "${red_bg} WARNING ${NC} ${red}Non-backwards compatible version update${NC}"
            echo -e "Updating from ${yellow}$ANDOCK_VERSION${NC} to ${yellow}$new_version${NC} is not backward compatible."
            _confirm "Continue with the update?"
        fi

        # saving to file
        echo "$new_andock" | sudo tee "$ANDOCK_PATH_UPDATED" > /dev/null
        if_failed_error "Could not write $ANDOCK_PATH_UPDATED"
        sudo chmod +x "$ANDOCK_PATH_UPDATED"
        echo-green "andock $new_version downloaded..."

        # overwrite old fin
        sudo mv "$ANDOCK_PATH_UPDATED" "$ANDOCK_PATH"
        andock cup
        exit
    else
        echo-rewrite "Updating andock ... $ANDOCK_VERSION ${green}[OK]${NC}"
    fi
}

#------------------------------ HELP --------------------------------

# Show help.
show_help ()
{
    echo
    printh "andock command reference" "${ANDOCK_VERSION}" "green"
    echo
    printh "connect" "Connect andock to andock server"
    printh "(.) ssh-add <ssh-key>" "Add private SSH key <ssh-key> variable to the agent store."

    echo
    printh "Server:" "" "green"
    printh "server install" "Install andock server."
    printh "server update" "Update andock server."
    printh "server ssh-add" "Add public ssh key to andock server."

    echo
    printh "Project:" "" "green"
    printh "config generate" "Generate andock project configuration."
    echo
    printh "Build:" "" "green"
    printh "build" "Build the current project."
    echo
    printh "Environment:" "" "green"
    printh "environment deploy (deploy)" "Deploy environment."
    printh "environment up"  "Start services."
    printh "environment test"  "Run UI tests. (Like behat, phantomjs etc.)"
    printh "environment stop" "Stop services."
    printh "environment rm" "Remove environment."
    printh "environment url" "Print environment urls."
    printh "environment ssh [--container] <command>" "SSH into environment. Specify a differnt container than cli with --container <SERVICE>"
    echo
    printh "fin <command>" "Fin remote control."

    echo
    printh "Drush:" "" "green"
    printh "drush generate-alias" "Generate drush alias."

    echo
    printh "version (v, -v)" "Print andock version. [v, -v] - prints short version"
    printh "alias" "Print andock alias."
    echo
    printh "self-update" "${yellow}Update andock${NC}" "yellow"
}

# Display andock version
# @option --short - Display only the version number
version ()
{
	if [[ $1 == '--short' ]]; then
		echo "$ANDOCK_VERSION"
	else
		echo-green "andock version: $ANDOCK_VERSION"
		echo ""
		echo-green "Roles:"
		echo "andock.build: $REQUIREMENTS_ANDOCK_BUILD"
		echo "andock.environment: $REQUIREMENTS_ANDOCK_ENVIRONMENT"
		echo "andock.server: $REQUIREMENTS_ANDOCK_SERVER"
	fi

}

#----------------------- ENVIRONMENT HELPER FUNCTIONS ------------------------

# Returns the git origin repository url
get_git_origin_url ()
{
    echo "$(git config --get remote.origin.url)"
}

# Returns the default project name
get_default_project_name ()
{
    if [ "${ANDOCK_PROJECT_NAME}" = "" ]; then
        echo "$(basename ${PWD})"
    else
        echo "${ANDOCK_PROJECT_NAME}"
    fi
}

# Returns the path project root folder.
find_root_path () {
    path=$(pwd)
    while [[ "$path" != "" && ! -e "$path/.andock" ]]; do
        path=${path%/*}
    done
    echo "$path"
}

# Check for connection inventory file in .andock/connections/$1
check_connect()
{
  if [ ! -f "${ANDOCK_INVENTORY}/$1" ]; then
    echo-red "No alias \"${1}\" exists. Please run andock connect."
    exit 1
  fi
}

# Checks if andock.yml exists.
check_settings_path ()
{
    local path="$PWD/.andock/andock.yml"
    if [ ! -f $path ]; then
        echo-error "Settings not found. Run andock config generate"
        exit 1
    fi
}

# Returns the path to andock.yml
get_settings_path ()
{
    local path="$PWD/.andock/andock.yml"
    echo $path
}

# Returns the path to andock.yml
get_branch_settings_path ()
{
    local branch
    branch=$(get_current_branch)
    local path="$PWD/.andock/andock.${branch}.yml"
    if [ -f $path ]; then
        echo $path
    fi
}

# Parse the .andock.yaml and
# make all variables accessable.
get_settings()
{
    local settings_path
    settings_path=$(get_settings_path)
    eval "$(_parse_yaml $settings_path 'config_')"
}


# Returns the git branch name
# of the current working directory
get_current_branch ()
{
    if [ "${TRAVIS}" = "true" ]; then
        echo $TRAVIS_BRANCH
    elif [ "${GITLAB_CI}" = "true" ]; then
        echo $CI_COMMIT_REF_NAME
    else
        branch_name="$(git symbolic-ref HEAD 2>/dev/null)" ||
        branch_name="(unnamed branch)"     # detached HEAD
        branch_name=${branch_name##refs/heads/}
        echo $branch_name
    fi
}


# Returns the git branch name
# of the current working directory
get_ansible_info ()
{
    local connection && connection=$1
    shift
    local command && command=$1
    shift
    local arg && arg=$1
    local settings_path && settings_path="$(get_settings_path)"
    # Load branch specific {branch}.andock.yml file if exist.
    local branch_settings_path
    branch_settings_path="$(get_branch_settings_path)"
    local branch_settings_config=""
    if [ "${branch_settings_path}" != "" ]; then
        local branch_settings_config="-e @${branch_settings_path}"
    fi

    # Get the current branch.
    local branch_name
    branch_name=$(get_current_branch)

    # Source .docksal.env for docroot
    source .docksal/docksal.env

    local ansible_output && ansible_output=$(ansible -o -e "arg='${arg}' docroot='${DOCROOT}' branch='${branch_name}'" -e "@${settings_path}" ${branch_settings_config} -i "${ANDOCK_INVENTORY}/${connection}" all -m debug -a "msg='AN__${command}__AN'")

    local command && command=$(echo ${ansible_output} | grep -o -P '(?<=AN__).*(?=__AN)')
    echo $command
}
#----------------------- ANSIBLE PLAYBOOK WRAPPERS ------------------------

# Generate ansible inventory files in .andock/connections.
# @param $1 The Connection name.
# @param $2 The andock host name.
# @param $3 The exec path.
run_connect ()
{
  if [ "$1" = "" ]; then
    local connection_name
    connection_name=$(_ask "Please enter connection name [$DEFAULT_CONNECTION_NAME]")
  else
    local connection_name=$1
    shift
  fi

  if [ "$1" = "" ]; then
    local host=
    host=$(_ask "Please enter andock server domain or ip")
  else
    local host=$1
    shift
  fi

  if [ "$connection_name" = "" ]; then
      local connection_name=$DEFAULT_CONNECTION_NAME
  fi
  mkdir -p ".andock/connections"

  echo "
[andock-docksal-server]
$host ansible_connection=ssh ansible_user=andock
" > "${ANDOCK_INVENTORY}/${connection_name}"

  echo-green "Connection configuration was created successfully."
}

# Ansible playbook wrapper for andock.build role.
run_build ()
{
    local connection=$1 && shift

    check_settings_path
    local settings_path
    settings_path=$(get_settings_path)

    local branch_name
    branch_name=$(get_current_branch)
    echo-green "Building branch <${branch_name}>..."

    ansible-playbook --become --become-user=andock -i "${ANDOCK_INVENTORY}/${connection}" -e "@${settings_path}" -e "project_path=$PWD branch=$branch_name" "$@" ${ANDOCK_PLAYBOOK}/build.yml
    if [[ $? == 0 ]]; then
        echo-green "Branch ${branch_name} was builded successfully"
    else
        echo-error ${DEFAULT_ERROR_MESSAGE}
        exit 1;
    fi
}

# Ansible playbook wrapper for role andock.fin
# @param $1 The Connection.
# @param $2 The fin command.
# @param $3 The exec path.
run_fin ()
{

    # Check if connection exists
    check_settings_path

    # Load configuration.
    local settings_path
    settings_path=$(get_settings_path)

    # Get the current branch name.
    local branch_name
    branch_name=$(get_current_branch)

    # Set parameters.
    local connection=$1 && shift
    local exec_command=$1 && shift
    local exec_path=$1 && shift

    # Run the playbook.
    ansible-playbook --become --become-user=andock -i "${ANDOCK_INVENTORY}/${connection}" --tags "exec" -e "@${settings_path}" ${branch_settings_config} -e "exec_command='$exec_command' exec_path='$exec_path' project_path=$PWD branch=${branch_name}" ${ANDOCK_PLAYBOOK}/fin.yml
    if [[ $? == 0 ]]; then
        echo-green "fin exec was finished successfully."
    else
        echo-error $DEFAULT_ERROR_MESSAGE
        exit 1;
    fi
}

# Shows environment url
# @param $1 Connection
run_environment_url ()
{
    local url && url=$(get_ansible_info "$connection" "{{(letsencrypt_enable|default(false) == true) | ternary('https','http')}}://{{virtual_hosts.default.virtual_host}}")
    echo $url
}

# SSH connection to environment
# @param $1 Connection
run_environment_ssh ()
{
    local connection && connection=$1
    shift
    local prefix && prefix=""
    if [[ "$1" = "--container" ]]; then
        shift
        prefix="---$1"
        shift
    fi
    local command && command=$(get_ansible_info "$connection" "{{branch}}-{{project_id|lower}}{{arg}}@{{inventory_hostname}}" "$prefix")
    local fullcommand && fullcommand="ssh -p 2222 ${command} ${*}"
    echo-green "Connect: $fullcommand"
    eval $fullcommand
}

# Ansible playbook wrapper for role andock.fin
# @param $1 Connection
# @param $2 Tag
run_environment ()
{
    # Check if connection exists
    check_settings_path

    # Load settings.
    local settings_path && settings_path="$(get_settings_path)"
    get_settings

    # Source .docksal.env
    source .docksal/docksal.env

    # Load branch specific {branch}.andock.yml file if exist.
    local branch_settings_path
    branch_settings_path="$(get_branch_settings_path)"
    local branch_settings_config=""
    if [ "${branch_settings_path}" != "" ]; then
        local branch_settings_config="-e @${branch_settings_path}"
    fi

    # Get the current branch.
    local branch_name
    branch_name=$(get_current_branch)

    # Set parameters.
    local connection=$1 && shift
    local tag=$1 && shift

    # Validate tag name. Show help if needed.
    case $tag in
        init|up|update|test|stop|rm|exec|"init,update")
            echo-green "Start environment ${tag}..."
        ;;
        *)
            echo-yellow "Unknown tag '$tag'. See 'andock help' for list of available commands" && \
            exit 1
        ;;
    esac

    # Run the playbook.
    ansible-playbook --become --become-user=andock -i "${ANDOCK_INVENTORY}/${connection}" --tags $tag -e "@${settings_path}" ${branch_settings_config} -e "docroot=${DOCROOT} project_path=$PWD branch=${branch_name}" "$@" ${ANDOCK_PLAYBOOK}/fin.yml
    # Handling playbook results.
    if [[ $? == 0 ]]; then
        case $tag in
            "init,update")
                local vhost && vhost=$(run_environment_url ${connection})
                echo-green "Environment deploy was finished successfully."
                echo
                echo-green "Visit: ${vhost}"
                echo
            ;;
            *)
                echo-green "Environment ${tag} was finished successfully."
            ;;
        esac
    else
        echo-error $DEFAULT_ERROR_MESSAGE
        exit 1;
    fi
}


#---------------------------------- CONFIG ---------------------------------

# Generate fin hooks.
# @param $1 The hook name.
config_generate_fin_hook()
{
    echo "- name: Init andock environment
  command: \"fin ${1}-andock\"
  args:
    chdir: \"{{ docroot_path }}\"
" > ".andock/hooks/$1_tasks.yml"
}

# Generate composer hook.
config_generate_composer_hook()
{
    echo "- name: Composer install
  command: \"fin rc -T composer install\"
  args:
    chdir: \"{{ build_path }}\"
" > ".andock/hooks/$1_tasks.yml"
}

# Generate empty hook file.
# @param $1 The hook name.
config_generate_empty_hook()
{
    echo "---" > ".andock/hooks/$1_tasks.yml"
}

# Generate configuration.
config_generate ()
{
    if [[ -f ".andock/andock.yml" ]]; then
        echo-yellow ".andock/andock.yml already exists"
        _confirm "Do you want to proceed and overwrite it?"
    fi

    local project_name && project_name=$(get_default_project_name)
    local git_repository_path && git_repository_path=$(get_git_origin_url)

    if [ "$git_repository_path" = "" ]; then
        echo-red "No git repository found."
        exit
    fi

    local virtual_host_pattern && virtual_host_pattern=$(_ask "Please enter your virtual host pattern. [{{ branch }}.${project_name}.com]")

    if [ "$virtual_host_pattern" = "" ]; then
        virtual_host_pattern="{{ branch }}.${project_name}.com"
    fi
    mkdir -p ".andock"
    mkdir -p ".andock/hooks"
    # Generate unique project id.

    local project_id && project_id=$(bashids -e -s ${project_name} $(date +%s))

    echo "# andock.yml (version: ${ANDOCK_VERSION})

## The display name and the id of the project.
project_name: \"${project_name}\"
project_id: \"${project_id,,}\"

## The git checkout repository.
git_repository_path: ${git_repository_path}

## The virtual host configuration pattern.
virtual_hosts:
  default:
    virtual_host: \"${virtual_host_pattern}\"
    container: web

## Mounts describe writeable persistent volumes in the docker container.
## Mounts are linked via volumes: into the docker container.
# mounts:
#   files:
#     path: 'docroot/files'

## Let's encrypt.
## Uncomment to enable let's encrypt certificate generation.
# letsencrypt_enable: true

## ansible build hooks.
## The hooks that will be triggered when the environment is builded/initialized/updated.
hook_build_tasks: \"{{project_path}}/.andock/hooks/build_tasks.yml\"
hook_init_tasks: \"{{project_path}}/.andock/hooks/init_tasks.yml\"
hook_update_tasks: \"{{project_path}}/.andock/hooks/update_tasks.yml\"
hook_test_tasks: \"{{project_path}}/.andock/hooks/test_tasks.yml\"

" > .andock/andock.yml

    config_generate_composer_hook "build"

    config_generate_fin_hook "init"

    config_generate_empty_hook "update"

    config_generate_empty_hook "test"

    if [[ $? == 0 ]]; then
        echo-green "Configuration was generated. Configure your hooks and start with ${yellow}andock build${NC}"
    else
        echo-error ${DEFAULT_ERROR_MESSAGE}
    fi
}

# Add ssh key.
ssh_add ()
{
    eval "$(ssh-agent -s)"
    echo "$*" | tr -d '\r' | ssh-add - > /dev/null
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    echo-green "SSH key was added to keystore."
}

#----------------------------------- DRUSH  -----------------------------------
run_alias ()
{
    set -e
    check_settings_path
    get_settings
    local branch_name
    branch_name=$(get_current_branch)
    local env
    env="${config_project_name}.${branch_name}"
    echo "${env}"
}

run_drush_generate ()
{
    local drush_file && drush_file=$(get_ansible_info "$1" "drush/{{project_name}}.aliases.drushrc.php")

    # Read current branch.
    local branch_name && branch_name=$(get_current_branch)

    local alias && alias=$(get_ansible_info "$1" "\$aliases['{{branch}}'] = array (
  'root' => '/var/www/{{docroot|default('docroot')}}',
  'uri' => 'http://{{virtual_hosts.default.virtual_host}}',
  'remote-user' => '{{branch}}-{{project_id|default(project_name)|lower}}',
  'remote-host' => '{{inventory_hostname}}',
  'ssh-options' => \'-p 2222\'
);")

    # Generate drush folder if not exists
    mkdir -p drush

    # Check if a drush file already exists.
    if [ ! -f ${drush_file} ]; then
        echo "<?php
" > ${drush_file}
    fi

    echo $alias | sed 's/\\n/\n/g' >> $drush_file
    echo-green  "Drush alias for branch \"${branch_name}\" was generated successfully."
    echo-green  "See ${drush_file}"
}


#----------------------------------- SERVER -----------------------------------

# Add ssh key to andock user.
run_server_ssh_add ()
{
    set -e
    local connection=$1
    shift

    if [ "$1" = "" ]; then
        local key=$(cat ~/.ssh/id_rsa.pub)
    else
        local key=$1
    fi
    shift

    if [ "$1" = "" ]; then
        local root_user="root"
    else
        local root_user=$1
        shift
    fi

    ansible-playbook --become --become-user=andock -e "ansible_ssh_user=$root_user" -i "${ANDOCK_INVENTORY}/${connection}" -e "ssh_key='$key'" "${ANDOCK_PLAYBOOK}/server_ssh_add.yml"
    echo-green "SSH key was added."
}

# Install andock.
run_server_install ()
{
    local connection=$1
    shift
    local tag=$1
    shift

    set -e
    local andock_pw_option
    local andock_pw

    if [ "$1" = "" ]; then
        if [ "$tag" = "install" ]; then
            andock_pw=$(openssl rand -base64 32)
            local andock_pw_enc && andock_pw_enc=$(mkpasswd --method=sha-512 ${andock_pw})
            andock_pw_option="ansible_sudo_pass=\"${andock_pw}\""
        else
            andock_pw_option=""
        fi
    else
        andock_pw=${1}
        local andock_pw_enc && andock_pw_enc=$(mkpasswd --method=sha-512 ${andock_pw})
        andock_pw_option="ansible_sudo_pass=\"${andock_pw}\""
        shift
    fi

    if [ "$1" = "" ]; then
        local root_user="root"
    else
        local root_user=$1
        shift
    fi

    if [ "${tag}" = "install" ]; then
        ansible andock-docksal-server -e "docksal_version=${REQUIREMENTS_ANDOCK_SERVER_DOCKSAL} ssh2docksal_version=${REQUIREMENTS_ANDOCK_SERVER_SSH2DOCKSAL} ansible_ssh_user=$root_user" -i "${ANDOCK_INVENTORY}/${connection}"  -m raw -a "test -e /usr/bin/python || (apt -y update && apt install -y python-minimal)"
        ansible-playbook -e "docksal_version=${REQUIREMENTS_ANDOCK_SERVER_DOCKSAL} ssh2docksal_version=${REQUIREMENTS_ANDOCK_SERVER_SSH2DOCKSAL} ansible_ssh_user=$root_user" --tags $tag -i "${ANDOCK_INVENTORY}/${connection}" -e "pw='$andock_pw_enc'" "$@" "${ANDOCK_PLAYBOOK}/server_install.yml"
        echo-green "andock password is: ${andock_pw}"
        echo-green "andock server was installed successfully."
    else
        ansible-playbook -e "${andock_pw_option}" -e "docksal_version=${REQUIREMENTS_ANDOCK_SERVER_DOCKSAL} ssh2docksal_version=${REQUIREMENTS_ANDOCK_SERVER_SSH2DOCKSAL} ansible_ssh_user=${root_user}" --tags "update" -i "${ANDOCK_INVENTORY}/${connection}" -e "pw='$andock_pw_enc'" "$@" "${ANDOCK_PLAYBOOK}/server_install.yml"
        echo-green "andock server was updated successfully."
    fi
}

#----------------------------------- MAIN -------------------------------------


# Check for connection alias.
int_connection="$1"
add="${int_connection:0:1}"

if [ "$add" = "@" ]; then
    # Connection alias found.
    connection="${int_connection:1}"
    shift
else
    # No alias found. Use the "default"
    connection=${DEFAULT_CONNECTION_NAME}
fi

org_path=${PWD}
# ansible playbooks needs to be called from project_root.
# So cd to root path
root_path=$(find_root_path)
cd "$root_path"

# Than we check if the command needs an connection.
# And if yes we check if the connection exists.
case "$1" in
    server|environment|build|deploy)
    check_connect $connection
    echo-green "Use connection: $connection"
    ;;
esac

# Store the command.
command=$1
shift
# Finally. Run the command.
case "$command" in
    _install-andock)
        install_andock "$@"
    ;;
    _update-andock)
        install_configuration "$@"
    ;;
    cup)
        install_configuration "$@"
    ;;
    self-update)
        self_update "$@"
    ;;
    ssh-add)
        ssh_add "$@"
    ;;
    generate-playbooks)
        generate_playbooks
    ;;
    config)
        case "$1" in
            generate)
                shift
                cd $org_path
                config_generate
            ;;
            *)
                echo-yellow "Unknown command '$command $1'. See 'andock help' for list of available commands" && \
                exit 1
            ;;
        esac
        ;;
    connect)
	    run_connect "$@"
    ;;
    build)
	    run_build "$connection" "$@"
    ;;
    deploy)
	    run_environment "$connection" "init,update" "$@"
    ;;
    environment)
        case "$1" in
            deploy)
                shift
	            run_environment "$connection" "init,update" "$@"
            ;;
            rm)
                shift
                run_environment "$connection" "rm" "$@"
            ;;
            up)
                shift
                run_environment "$connection" "up" "$@"
            ;;
            stop)
                shift
                run_environment "$connection" "stop" "$@"
            ;;
            test)
                shift
                run_environment "$connection" "test" "$@"
            ;;
            url)
                shift
                run_environment_url "$connection"
            ;;
            ssh)
                shift
                run_environment_ssh "$connection" "$@"
            ;;

            *)
                echo-yellow "Unknown command '$command $1'. See 'andock help' for list of available commands" && \
                exit 1
            ;;
        esac
        ;;
    fin)
        fin_sub_path=""
        if [[ "$org_path" != "$root_path" ]]; then
            fin_sub_path=$(echo ${org_path#${root_path}"/"})
        fi
	    run_fin "$connection" "$1" "$fin_sub_path"
    ;;
    alias)
	    run_alias
    ;;
    drush)
        case "$1" in
            generate-alias)
                shift
                run_drush_generate "$connection"
            ;;
            *)
                echo-yellow "Unknown command '$command $1'. See 'andock help' for list of available commands" && \
                exit 1
            ;;
        esac
        ;;
    server)
        case "$1" in
            install)
                shift
                run_server_install "$connection" "install" "$@"
            ;;
            update)
                shift
                run_server_install "$connection" "update" "$@"
            ;;
            ssh-add)
                shift
                run_server_ssh_add "$connection" "$1" "$2"
             ;;
            *)
                echo-yellow "Unknown command '$command $1'. See 'andock help' for list of available commands" && \
                exit 1
            ;;
        esac
        ;;

    help|"")
        show_help
    ;;
    -v | v)
        version --short
    ;;
    version)
	    version
    ;;
	*)
        echo-yellow "Unknown command '$command'. See 'andock help' for list of available commands" && \
        exit 1
    esac
