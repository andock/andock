#!/bin/bash

ANSIBLE_VERSION="2.6.2"
ANDOCK_VERSION=0.0.3

REQUIREMENTS_ANDOCK_BUILD='0.0.8'
REQUIREMENTS_ANDOCK_FIN='0.1.2'
REQUIREMENTS_ANDOCK_SERVER='0.0.16'
REQUIREMENTS_SSH_KEYS='0.3'

DEFAULT_CONNECTION_NAME="default"

ANDOCK_PATH="/usr/local/bin/andock"
ANDOCK_PATH_UPDATED="/usr/local/bin/andock.updated"

ANDOCK_HOME="$HOME/.andock"
ANDOCK_INVENTORY="./.andock/connections"
ANDOCK_INVENTORY_GLOBAL="$ANDOCK_HOME/connections"
ANDOCK_PLAYBOOK="$ANDOCK_HOME/playbooks"
ANDOCK_PROJECT_NAME=""

URL_REPO="https://raw.githubusercontent.com/andock/andock"
URL_ANDOCK="${URL_REPO}/master/bin/andock.sh"
DEFAULT_ERROR_MESSAGE="Oops. There is probably something wrong. Check the logs."

export ANSIBLE_ROLES_PATH="${ANDOCK_HOME}/roles"

export ANSIBLE_HOST_KEY_CHECKING=False

export ANSIBLE_SSH_PIPELINING=True

#export ANSIBLE_SCP_IF_SSH=y
#export ANSIBLE_SSH_ARGS="-t -t"

#export ANSIBLE_DEBUG=1
config_git_target_repository_path=""
config_base_domains=""
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
    - { role: key-tec.build }
" > "${ANDOCK_PLAYBOOK}/build.yml"

    echo "---
- hosts: andock-docksal-server
  gather_facts: true
  roles:
    - { role: key-tec.fin }
" > "${ANDOCK_PLAYBOOK}/fin.yml"


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
    - { role: key-tec.server }
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

    # Don't install own pip inside travis.
    if [ "${TRAVIS}" = "true" ]; then
        sudo pip install ansible=="${ANSIBLE_VERSION}"
    else
        wget https://bootstrap.pypa.io/get-pip.py
        sudo python get-pip.py
        sudo pip install ansible=="${ANSIBLE_VERSION}"
        rm get-pip.py
    fi
    sudo pip install urllib3 pyOpenSSL ndg-httpsclient pyasn1

    which ssh-agent || ( sudo apt-get update -y && sudo apt-get install openssh-client -y )

    install_configuration
    echo-green ""
    echo-green "andock was installed successfully"
}

# Install ansible galaxy roles.
install_configuration ()
{
    mkdir -p $ANDOCK_INVENTORY_GLOBAL
    #export ANSIBLE_RETRY_FILES_ENABLED="False"
    generate_playbooks
    echo-green "Installing roles:"
    ansible-galaxy install key-tec.build,v${REQUIREMENTS_ANDOCK_BUILD} --force
    ansible-galaxy install key-tec.fin,v${REQUIREMENTS_ANDOCK_FIN} --force
    ansible-galaxy install andock-ci.ansible_role_ssh_keys,v${REQUIREMENTS_SSH_KEYS} --force
    ansible-galaxy install key-tec.server,v${REQUIREMENTS_ANDOCK_SERVER} --force

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
    printh "Server management:" "" "yellow"
    printh "server:install [root_user, default=root] [andock_pass, default=keygen]" "Install andock server."
    printh "server:update [root_user, default=root]" "Update andock server."
    printh "server:ssh-add [root_user, default=root]" "Add public ssh key to andock server."

    echo
    printh "Project configuration:" "" "yellow"
    printh "generate:config" "Generate andock project configuration."
    echo
    printh "Project build management:" "" "yellow"
    printh "build" "Build project and push it to artifact repository."
    printh "deploy" "Deploy project."
    printh "bp" "Build and deploy project."
    echo
    printh "Control remote docksal:" "" "yellow"
    printh "fin init"  "Clone git repository and run init tasks."
    printh "fin up"  "Start services."
    printh "fin update"  "Pull changes and run update tasks."
    printh "fin test"  "Run UI tests. (Like behat, phantomjs etc.)"
    printh "fin stop" "Stop services."
    printh "fin rm" "Remove environment."
    echo
    printh "fin-run <command> <path>" "Run any fin command."

    echo
    printh "Drush:" "" "yellow"
    printh "drush:generate-alias" "Generate drush alias."

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
		echo "andock version: $ANDOCK_VERSION"
		echo "Roles:"
		echo "andock.build: $REQUIREMENTS_ANDOCK_BUILD"
		echo "andock.fin: $REQUIREMENTS_ANDOCK_FIN"
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
        echo-error "Settings not found. Run andock generate:config"
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

#----------------------- ANSIBLE PLAYBOOK WRAPPERS ------------------------

# Generate ansible inventory files inside .andock/connections folder.
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
run_fin_run ()
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

# Ansible playbook wrapper for role andock.fin
# @param $1 Connection
# @param $2 Tag
run_fin ()
{

    # Check if connection exists
    check_settings_path

    # Load settings.
    local settings_path
    settings_path="$(get_settings_path)"
    get_settings

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
            echo-green "Start fin ${tag}..."
        ;;
        *)
            echo-yellow "Unknown tag '$tag'. See 'andock help' for list of available commands" && \
            exit 1
        ;;
    esac

    # Run the playbook.
    ansible-playbook --become --become-user=andock -i "${ANDOCK_INVENTORY}/${connection}" --tags $tag -e "@${settings_path}" ${branch_settings_config} -e "project_path=$PWD branch=${branch_name}" "$@" ${ANDOCK_PLAYBOOK}/fin.yml

    # Handling playbook results.
    if [[ $? == 0 ]]; then
        echo-green "fin ${tag} was finished successfully."
    else
        echo-error $DEFAULT_ERROR_MESSAGE
        exit 1;
    fi
}


#---------------------------------- GENERATE ---------------------------------

# Generate fin hooks.
# @param $1 The hook name.
generate_config_fin_hook()
{
    echo "- name: Init andock environment
  command: \"fin $1\"
  args:
    chdir: \"{{ docroot_path }}\"
  when: environment_exists_before == false
" > ".andock/hooks/$1_tasks.yml"
}

# Generate composer hook.
generate_config_compser_hook()
{
    echo "- name: composer install
  command: \"fin exec -T composer install\"
  args:
    chdir: \"{{ checkout_path }}\"
" > ".andock/hooks/$1_tasks.yml"
}

# Generate empty hook file.
# @param $1 The hook name.
generate_config_empty_hook()
{
    echo "---" > ".andock/hooks/$1_tasks.yml"
}

# Generate configuration.
generate_config ()
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

    echo "# andock.yml (version: ${ANDOCK_VERSION})

## The name of this project, which must be unique within a andock server.
project_name: \"${project_name}\"

## The virtual host configuration pattern.
virtual_hosts:
  default: \"${virtual_host_pattern}\"

## The git checkout repository.
git_repository_path: ${git_repository_path}

## Mounts describe writeable persistent volumnes in the docker container.
## Mounts are linked via volumnes: into the docker container.
# mounts:
#   - { name: 'files', src: 'files', path: 'docroot/files' }

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

    if [[ "$build" = 1 && $(_confirmAndReturn "Do you use composer to build your project?") == 1 ]]; then
        generate_config_compser_hook "build"
    else
        generate_config_empty_hook "build"
    fi

    generate_config_fin_hook "init"

    generate_config_empty_hook "update"

    generate_config_empty_hook "test"

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
    set -e
    # Abort if andock is configured.
    check_settings_path
    # Load settings.
    get_settings
    local branch_name
    # Read current branch.
    branch_name=$(get_current_branch)

    # Generate drush folder if not exists
    mkdir -p drush
    # The local drush file.
    local drush_file="drush/${config_project_name}.aliases.drushrc.php"

    # Check if a drush file already exists. If not generate a stub which export
    # the alias name to LC_ANDOCK_ENV.
    # Based on LC_ANDOCK_ENV andock server jumps into the correct cli container
    if [ ! -f ${drush_file} ]; then
        echo "<?php
\$_drush_context = drush_get_context();
if (isset(\$_drush_context['DRUSH_TARGET_SITE_ALIAS'])) {
  putenv ('LC_ANDOCK_ENV=' . substr(\$_drush_context['DRUSH_TARGET_SITE_ALIAS'], 1));
}" > ${drush_file}
    fi
    # source .docksal/docksal.env for DOCROOT.
    source .docksal/docksal.env
    # Generate one alias for each configured domain.
    local domains
    domains=$(echo $config_base_domains | tr " " "\n")
    # Loop through each domain to generate one alias for each subsite.
    for domain in $domains
        do
            local url="http://${branch_name}.${domain}"
            echo "
\$aliases['${branch_name}'] = array (
  'root' => '/var/www/${DOCROOT}',
  'uri' => '${url}',
  'remote-host' => '${domain}',
  'remote-user' => 'andock',
  'ssh-options' => '-o SendEnv=LC_ANDOCK_ENV'
);
" >> $drush_file
        done

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

    local ssh_key="command=\"andock-server _bridge \$SSH_ORIGINAL_COMMAND\" $key"
    shift

    if [ "$1" = "" ]; then
        local root_user="root"
    else
        local root_user=$1
        shift
    fi

    ansible-playbook --become --become-user=andock -e "ansible_ssh_user=$root_user" -i "${ANDOCK_INVENTORY}/${connection}" -e "ssh_key='$ssh_key'" "${ANDOCK_PLAYBOOK}/server_ssh_add.yml"
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

    if [ "$tag" = "install" ]; then
    echo "$@"
        ansible andock-docksal-server -e "ansible_ssh_user=$root_user" -i "${ANDOCK_INVENTORY}/${connection}"  -m raw -a "test -e /usr/bin/python || (apt -y update && apt install -y python-minimal)"
        ansible-playbook -e "ansible_ssh_user=$root_user" --tags $tag -i "${ANDOCK_INVENTORY}/${connection}" -e "pw='$andock_pw_enc'" "$@" "${ANDOCK_PLAYBOOK}/server_install.yml"
        echo-green "andock password is: ${andock_pw}"
        echo-green "andock server was installed successfully."
    else
        ansible-playbook --become --become-user=andock -e ${andock_pw_option} -e "ansible_ssh_user=andock" --tags "update" -i "${ANDOCK_INVENTORY}/${connection}" -e "pw='$andock_pw_enc'" "$@" "${ANDOCK_PLAYBOOK}/server_install.yml"
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

# Than we check if the command needs an connection.
# And if yes we check if the connection exists.
case "$1" in
    server:install|server:update|server:info|server:ssh-add|fin|build)
    check_connect $connection
    echo-green "Use connection: $connection"
    ;;
esac

org_path=${PWD}
# ansible playbooks needs to be called from project_root.
# So cd to root path
root_path=$(find_root_path)
cd "$root_path"

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
  generate:config)
    cd $org_path
    generate_config
  ;;
  connect)
	run_connect "$@"
  ;;
  build)
	run_build "$connection" "$@"
  ;;
  deploy)
    #run_build "$connection" "$@"
	run_fin "$connection" "init,update" "$@"
  ;;
  bp)
    run_build "$connection" "$@"
	run_fin "$connection" "init,update" "$@"
  ;;

  fin)
	run_fin "$connection" "$@"
  ;;
  fin-run)
    run_fin_run "$connection" "$1" "$2"
  ;;
  alias)
	run_alias
  ;;
  drush:generate-alias)
	run_drush_generate
  ;;


  server:install)
	run_server_install "$connection" "install" "$@"
  ;;
  server:update)
	run_server_install "$connection" "update" "$@"
  ;;
  server:info)
	run_server_info "$connection" "$@"
  ;;
  server:ssh-add)
	run_server_ssh_add "$connection" "$1" "$2"
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
