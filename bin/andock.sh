#!/bin/bash

ANDOCK_VERSION=1.2.0
ANSIBLE_VERSION="2.9.2"

REQUIREMENTS_ANDOCK_SERVER_DOCKSAL='v1.18.2'
REQUIREMENTS_ANDOCK_SERVER_SSH2DOCKSAL='1.0-rc.3'
REQUIREMENTS_SSH_KEYS='0.3'

SSH2DOCKSAL_COMMAND=""
DEFAULT_CONNECTION_NAME="default"

ANDOCK_PATH="/usr/local/bin/andock"
ANDOCK_PATH_UPDATED="/usr/local/bin/andock.updated"

ANDOCK_HOME="$HOME/.andock"
ANDOCK_INVENTORY="./.andock/connections"
ANDOCK_INVENTORY_GLOBAL="$ANDOCK_HOME/connections"

ANDOCK_CONFIG_ENV="$ANDOCK_HOME/andock.env"

URL_REPO="https://raw.githubusercontent.com/andock/andock"
BASHIDS_URL="https://raw.githubusercontent.com/benwilber/bashids/master/bashids"
URL_ANDOCK="${URL_REPO}/master/bin/andock.sh"
DEFAULT_ERROR_MESSAGE="Oops. There is probably something wrong. Check the logs."

ANDOCK_ROLES="${ANDOCK_ROLES:-${ANDOCK_HOME}/roles}"
ANDOCK_INSTALL_COLLECTION=${ANDOCK_INSTALL_COLLECTION:-true}
ANDOCK_COLLECTIONS="${ANDOCK_COLLECTIONS:-${ANDOCK_HOME}/collections}"
ANDOCK_COLLECTIONS_HOME="${ANDOCK_COLLECTIONS_HOME:-${ANDOCK_COLLECTIONS}/ansible_collections/andock/andock}"
ANDOCK_HOST_KEY_CHECKING="${ANDOCK_HOST_KEY_CHECKING:-True}"

# Load environment variables overrides, use to permanently override some variables
# Source and allexport variables in the .env file
if [[ -f "$ANDOCK_CONFIG_ENV" ]]; then
	set -a
	source "$ANDOCK_CONFIG_ENV"
	set +a
else
  mkdir -p $ANDOCK_HOME
	touch "$ANDOCK_CONFIG_ENV"
fi

if [[ "ANSIBLE_GALAXY_API_KEY" != "" ]]; then
  export export ANSIBLE_GALAXY_API_KEY=$ANSIBLE_GALAXY_API_KEY
fi

ANDOCK_CALLBACK_PLUGINS="${ANDOCK_CALLBACK_PLUGINS:-${ANDOCK_COLLECTIONS_HOME}/plugins/callback}"
ANDOCK_PLAYBOOK="${ANDOCK_COLLECTIONS_HOME}/playbooks"


export ANSIBLE_PYTHON_INTERPRETER=auto

export ANSIBLE_ROLES_PATH="${ANDOCK_ROLES}"

export ANSIBLE_CALLBACK_PLUGINS="${ANDOCK_CALLBACK_PLUGINS}"

export ANSIBLE_HOST_KEY_CHECKING="${ANDOCK_HOST_KEY_CHECKING}"

export ANSIBLE_SSH_PIPELINING=True

export ANSIBLE_STDOUT_CALLBACK="${ANDOCK_STDOUT_CALLBACK:-andock_stdout}"

export ANSIBLE_DEBUG="${ANDOCK_DEBUG:-False}"

export ANSIBLE_TRANSFORM_INVALID_GROUP_CHARS=silently

export ANSIBLE_CONDITIONAL_BARE_VARS=True

export ANSIBLE_COLLECTIONS_PATHS=${ANDOCK_COLLECTIONS}

export ANSIBLE_SYSTEM_WARNINGS=False

# @author Leonid Makarov
# Console colors
red='\033[0;91m'
red_bg='\033[101m'
green='\033[0;32m'
yellow='\033[1;33m'
NC='\033[0m'


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
    *)##################################
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

# Install ansible
# and ansible galaxy roles
install_andock()
{
    echo-green ""
    echo-green "Installing Andock version: ${ANDOCK_VERSION} ..."

    echo-green ""
    echo-green "Installing Ansible:"

    sudo apt-get update
    sudo apt-get install whois sudo build-essential libssl-dev libffi-dev python-dev figlet python3-pip python3-setuptools -y

    set -e

    # Install bashids
    sudo curl -fsSL ${BASHIDS_URL} -o /usr/local/bin/bashids &&
    sudo chmod +x /usr/local/bin/bashids
    sudo pip3 install -U setuptools
    sudo pip3 install ansible=="${ANSIBLE_VERSION}"
    # Don't install own pip inside travis.

    sudo pip3 install urllib3 pyOpenSSL ndg-httpsclient pyasn1 jmespath

    which ssh-agent || ( sudo apt-get update -y && sudo apt-get install openssh-client -y )

    install_ansible_collection $1 $2
    echo-green ""
    echo-green "Andock was installed successfully"

}

# Install ansible galaxy roles.
install_ansible_collection ()
{
    if [[ "$1" == "" ]]; then
      install_type="install"
    else
      install_type="$1"
    fi

    mkdir -p ${ANDOCK_INVENTORY_GLOBAL}

    # For local development andock is a symlink.
    if [[ -L "$0" ]]; then
        folder="$(dirname $(readlink -f $0))/../"
        echo $folder
        cd $folder
    else
        cd "$org_path/../"
    fi

    if [[ "${install_type}" == "install" ]]; then
      echo-green "Installing Collection:"
      ansible-galaxy collection install andock.andock:==${ANDOCK_VERSION} --force
    fi

    if [[ "${install_type}" == "build" ]]; then
        echo-green "Build Collection:"
        cp default.galaxy.yml galaxy.yml
        echo "version: \"${ANDOCK_VERSION}\"" >> galaxy.yml
        ansible-galaxy collection build --force
        ansible-galaxy collection install andock-andock-${ANDOCK_VERSION}.tar.gz --force
    fi

    if [[ "${install_type}" == "deploy" ]]; then
        if [[ "" == "${ANSIBLE_GALAXY_API_KEY}" ]]; then
          echo-error "Ansible galaxy api key is empty. Add your galaxy api key to .andock/andock.env"
          exit 1;
        fi
        ansible-galaxy collection publish andock-andock-${ANDOCK_VERSION}.tar.gz --api-key=${ANSIBLE_GALAXY_API_KEY}
    fi

}

# Based on docksal update script
# @author Leonid Makarov
self_update()
{
    echo-green "Updating Andock..."
    local new_andock
    new_andock=$(curl -kfsSL "$URL_ANDOCK?r=$RANDOM")
    if_failed_error "Andock download failed."

    # Check if fin update is required and whether it is a major version
    local new_version
    new_version=$(echo "$new_andock" | grep "^ANDOCK_VERSION=" | cut -f 2 -d "=")
    if [[ "$new_version" != "$ANDOCK_VERSION" ]]; then
        local current_major_version
        current_major_version=$(echo "$ANDOCK_VERSION" |install_ansible_collection cut -d "." -f 1)
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
        echo-green "Andock $new_version downloaded..."

        # overwrite old fin
        sudo mv "$ANDOCK_PATH_UPDATED" "$ANDOCK_PATH"
        andock cup
        exit
    else
        echo-rewrite "Updating Andock ... $ANDOCK_VERSION ${green}[OK]${NC}"
    fi
}

#------------------------------ HELP --------------------------------

# Show help.
show_help ()
{
    echo
    printh "Andock command reference" "${ANDOCK_VERSION}" "green"
    echo
    printh "Options: "
    printh "Andock supports all ansible-playbook options"
    echo
    printh "Samples: "
    printh "-v, --verbose         verbose mode (-vvv for more, -vvvv to enable
                        connection debugging)"
    printh "-e EXTRA_VARS, --extra-vars=EXTRA_VARS
                        set additional variables as key=value or YAML/JSON, if
                        filename prepend with @"

    echo
    printh "Connection" "" "green"
    printh "connect" "Connect andock to Andock server"
    printh "(.) ssh-add <ssh-key>" "Add private SSH key <ssh-key> variable to the agent store."

    echo
    printh "Server:" "" "green"
    printh "server install <password|default(auto)> <root user|default(root)>" "Install/update Andock server."
    printh "server ssh-add" "Add public ssh key to Andock server."
    printh "server show-pub-key" "Show Andock server public key."
    printh "server version" "Show Andock server version."

    echo
    printh "Project:" "" "green"
    printh "config generate" "Generate project configuration."
    echo
    printh "Build:" "" "green"
    printh "build" "Build deployment artifact"
    printh "build push" "Build deployment artifact and pushes to artifact repository."
    printh "build clean" "Clean build caches."
    echo
    printh "build deploy" "Build deployment artifact, pushes to artifact repository and deploy it."
    echo
    printh "Environment:" "" "green"
    printh "environment deploy (deploy)" "Initialize or update environment."
    printh "environment init" "Initialize a new environment."
    printh "environment update" "Update environment."
    printh "environment up"  "Start services."
    printh "environment test"  "Run UI tests. (Like behat, phantomjs etc.)"
    printh "environment stop" "Stop services."
    printh "environment rm [--force]" "Remove environment."
    printh "environment letsencrypt" "Update Let's Encrypt certificate."
    printh "environment status" "Shows the status of the environment."

    printh "environment url" "Print environment urls."
    printh "environment ssh [--container] <command>" "SSH into environment. Specify a different container than cli with --container <SERVICE>"
    echo
    printh "clean" "Cleans build and environment."
    echo
    printh "fin <command>" "Fin remote control."

    echo
    printh "Drush:" "" "green"
    printh "drush generate-alias <version>" "Generate drush alias (Default: 9)"

    echo
    printh "version (v, -v)" "Print Andock version. [v, -v] - prints short version"
    echo
    printh "self-update" "${yellow}Update Andock${NC}" "yellow"
}

# Display andock version
# @option --short - Display only the version number
version ()
{
	if [[ $1 == '--short' ]]; then
		echo "$ANDOCK_VERSION"
	else
		echo-green "Andock client: $ANDOCK_VERSION"
		echo ""
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

# Returns the git branch name
# of the current working directory
get_current_branch ()
{
    if [[ "${BRANCH}" != "" ]]; then
        echo ${BRANCH}
    elif [ "${TRAVIS}" = "true" ]; then
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

# Returns "pong" if andock is installed.
ping ()
{
    local connection && connection=$1
    local ansible_output && ansible_output=$(ansible -i "${ANDOCK_INVENTORY}/${connection}" all -m ping | grep pong)

    if [[ $ansible_output == *"pong"* ]]; then
        echo "pong"
    fi
}

# Returns the git branch name
# of the current working directory
execute_ansible ()
{
    local connection && connection=$1
    shift
    local arg && arg=$1
    shift

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

    if [ "${DOCROOT}" = "" ]; then
        DOCROOT="docroot"
    fi
    # echo "COMMAND: " $*
    local ansible_output && ansible_output=$(ansible -o -e "arg='${arg}' environment_home='~/andock/projects/{{project_id}}/{{branch}}' docroot='${DOCROOT}' branch='${branch_name}'" -e "@${settings_path}" ${branch_settings_config} --connection=local -i "${ANDOCK_INVENTORY}/${connection}" all "$@")
    echo ${ansible_output}
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
    ansible_output=$(execute_ansible "$connection" "$arg" -m debug -a "msg='AN__${command}__AN'")
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
    host=$(_ask "Please enter Andock server domain or ip")
  else
    local host=$1
    shift
  fi

  if [ "$connection_name" = "" ]; then
      local connection_name=$DEFAULT_CONNECTION_NAME
  fi
  mkdir -p ".andock/connections"

  echo "
[andock_docksal_server]
$host ansible_connection=ssh ansible_user=andock
" > "${ANDOCK_INVENTORY}/${connection_name}"

  echo-green "Connection configuration was created successfully."
}
build()
{
    local connection=$1 && shift

    check_settings_path
    local settings_path
    settings_path=$(get_settings_path)

    local branch_name
    branch_name=$(get_current_branch)

    ansible-playbook -i "${ANDOCK_INVENTORY}/${connection}" -e "@${settings_path}" -e "project_path=$PWD branch=$branch_name" "$@" ${ANDOCK_PLAYBOOK}/build.yml
    if [[ $? != 0 ]]; then
        echo-error "${DEFAULT_ERROR_MESSAGE}"
        exit 1;
    fi
}
# Clean build caches.
run_build_clean ()
{

    local branch_name && branch_name=$(get_current_branch)
    local connection && connection=$1 && shift
    echo-green "Clean build for <${branch_name}>..."
    build $connection --tags "cleanup,setup" -e "{'cache_build': false}" "$@"
    echo-green "Build was cleaned successfully"

}

# Clean artifact repository.
run_build_clean_artifact_branch ()
{

    local branch_name && branch_name=$(get_current_branch)
    local connection && connection=$1 && shift
    echo-green "Remove artifact branch for <${branch_name}>..."
    build $connection --tags "cleanup,setup,cleanup_repository" -e "{'cache_build': false}" "$@"
    echo-green "Branch was removed successfully"

}

# Ansible playbook wrapper for andock.build role.
run_build_push ()
{
    local branch_name && branch_name=$(get_current_branch)
    local connection && connection=$1 && shift
    echo-green "Build and push branch <${branch_name}>..."
    build ${connection} "$@"
    echo
    echo-green "Branch ${branch_name} was built and pushed successfully"
    echo
}

# Ansible playbook wrapper for andock.build role.
run_build ()
{
    local branch_name && branch_name=$(get_current_branch)
    local connection && connection=$1 && shift
    echo-green "Build branch <${branch_name}>..."
    build ${connection} --skip-tags "prepare_commit,commit,push" -e "{'skip_staging': true}" "$@"
    echo
    echo-green "Branch ${branch_name} was built successfully"
    echo

}

# Ansible playbook wrapper for role andock.fin
# @param $1 The Connection.
# @param $2 The exec path.
# @param $* The fin command.
run_fin ()
{

    fin_sub_path=""
    if [[ "$org_path" != "$root_path" ]]; then
        fin_sub_path=$(echo ${org_path#${root_path}"/"})
    fi
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
    local exec_path=$fin_sub_path
    local exec_command=$*

    echo-green "Run fin for <${branch_name}>..."
    # Run the playbook.
    ansible-playbook -i "${ANDOCK_INVENTORY}/${connection}" --tags "exec" -e "@${settings_path}" ${branch_settings_config} -e "exec_command='$exec_command' exec_path='$exec_path' project_path=$PWD branch=${branch_name}" ${ANDOCK_PLAYBOOK}/fin.yml
    if [[ $? == 0 ]]; then
        echo
        echo-green "fin exec was finished successfully."
        echo
    else
        echo
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

# Checks if the environment exists
# @param $1 Connection
get_environment_status ()
{
  connection=$1 && shift
  output=$(run_fin "$connection" "exec" "pwd")

  if [[ "$output" =~ result.stdout\:[[:space:]]/var/www ]]; then
    echo 1
    return
  fi

  if [[ "$output" =~ is[[:space:]]not[[:space:]]running ]]; then
    echo 0
    return
  fi

  echo -1
  return

}

show_environment_status_messages () {
  # Get the current branch name.
  local status && status=$1
  local branch_name
  branch_name=$(get_current_branch)
  echo ""
  if [[ $status == 1 ]]; then
    echo-green "Environment <${branch_name}> exists and is running. Run 'andock environment init' to initialize."
  fi

  if [[ $status == 0 ]]; then
    echo-red "Environment <${branch_name}> exists but is not running. Run 'andock environment up' to start the environment."
  fi

  if [[ $status == -1 ]]; then
    echo-red "Environment <${branch_name}> not exists."
  fi

  echo ""

}
run_environment_status () {
  connection=$1 && shift
  local status && status=$(get_environment_status "$connection")
  show_environment_status_messages $status
}

# SSH connection to environment
# @param $1 Connection
run_environment_ssh ()
{
    local connection && connection=$1
    shift
    local status && status=$(get_environment_status "$connection")
    if [[ $status != 1 ]]; then
      show_environment_status_messages $status
      exit 1
    fi

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

    # Source .docksal.env
    source .docksal/docksal.env

    if [ "${DOCROOT}" = "" ]; then
        DOCROOT="docroot"
    fi
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

    local force_rm="{'force_rm': false}"
    if [[ "$1" = "--force" ]]; then
        force_rm="{'force_rm': true}"
        shift
    fi

    # Validate tag name. Show help if needed.
    case $tag in
        "init,update")
            echo-green "Deploy branch: <${branch_name}>..."
        ;;
        "up,update")
            echo-green "Update branch: <${branch_name}>..."
        ;;
        "version")
            echo-green ""
        ;;
        init|up|update|test|stop|rm|exec|"up,letsencrypt")
            echo-green "Environment $tag branch: <${branch_name}>..."
        ;;
        *)
            echo-yellow "Unknown tag '$tag'. See 'andock help' for list of available commands" && \
            exit 1
        ;;
    esac

    # Run the playbook.
    ansible-playbook -i "${ANDOCK_INVENTORY}/${connection}" --tags $tag -e "@${settings_path}" ${branch_settings_config} -e "${force_rm}" -e "docroot=${DOCROOT} project_path=$PWD branch=${branch_name}" "$@" ${ANDOCK_PLAYBOOK}/fin.yml
    # Handling playbook results.
    if [[ $? == 0 ]]; then
        case $tag in
            "init,update")
                local vhost && vhost=$(run_environment_url ${connection})
                echo
                echo-green "Deployment was finished successfully."
                echo-green "Visit: ${vhost}"
                echo
            ;;
            *)
                echo
                echo-green "Environment ${tag} was finished successfully."
                echo
            ;;
        esac
    else
        echo
        echo-error "$DEFAULT_ERROR_MESSAGE"
        echo
        exit 1;
    fi
}


#---------------------------------- CONFIG ---------------------------------

# Generate fin hooks.
# @param $1 The hook name.
config_generate_fin_init_hook()
{
    echo "- name: Init andock environment
  command: \"echo 'Hello Andock'\"
  args:
    chdir: \"{{ docroot_path }}\"
" > ".andock/hooks/init_tasks.yml"
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
# mounts:
#   files:
#     path: 'docroot/files'

## Let's encrypt.
## Uncomment to enable let's encrypt certificate generation.
# letsencrypt_enable: true

## ansible build hooks.
## The hooks that will be triggered when the environment is built/initialized/updated.
hook_build_tasks: \"{{project_path}}/.andock/hooks/build_tasks.yml\"
hook_build_test_tasks: \"{{project_path}}/.andock/hooks/build_test_tasks.yml\"
hook_init_tasks: \"{{project_path}}/.andock/hooks/init_tasks.yml\"
hook_update_tasks: \"{{project_path}}/.andock/hooks/update_tasks.yml\"
hook_test_tasks: \"{{project_path}}/.andock/hooks/test_tasks.yml\"

" > .andock/andock.yml

    config_generate_composer_hook "build"

    config_generate_empty_hook "build_test"

    config_generate_fin_init_hook

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

run_drush_generate_8 ()
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

run_drush_generate_9 ()
{
    local drush_file && drush_file=$(get_ansible_info "$1" "drush/sites/{{project_name}}.site.yml")

    local branch_name && branch_name=$(get_current_branch)

    local alias && alias=$(get_ansible_info "$1" "{{branch}}:
__root: \'/var/www/{{docroot|default('docroot')}}\'
__uri:  \'http://{{virtual_hosts.default.virtual_host}}\'
__user: \'{{branch}}-{{project_id|default(project_name)|lower}}\'
__host: \'{{inventory_hostname}}\'
__ssh:
____options: \'-p 2222\'")

    # Generate drush folder if not exists
    mkdir -p drush/sites
    echo $alias | sed 's/\\n/\n/g; s/__/  /g' >> $drush_file
    echo-green  "Drush alias for branch \"${branch_name}\" was generated successfully."
    echo-green  "See ${drush_file}"
}

#----------------------------------- SERVER -----------------------------------


# Show Andock server public key.
run_server_show_key ()
{
    set -e
    local connection=$1
    shift

}

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
        shift
    fi


    if [ "$1" = "" ]; then
        local user="andock"
    else
        local user=$1
        shift
    fi

    ansible-playbook -i "${ANDOCK_INVENTORY}/${connection}" -e "ansible_ssh_user='$user' ssh_key='$key'" "${ANDOCK_PLAYBOOK}/server_ssh_add.yml"
    echo-green "SSH key was added."
}
# Run ansible role andock.server.
run_server ()
{
    local connection=$1
    shift
    local tag=$1
    shift
    local ping && ping=$(ping "$connection")
    if [ "$tag" = "install" ]; then
        if [[ "$ping" == "pong" ]]; then
            tag="update"
        fi
    fi
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
        echo-green "Installing Docksal on host"
        echo-green "This will take some minutes..."
        echo
        # Install minimal python dependencies on host.
        ansible andock_docksal_server -e "docksal_version=${REQUIREMENTS_ANDOCK_SERVER_DOCKSAL} ssh2docksal_version=${REQUIREMENTS_ANDOCK_SERVER_SSH2DOCKSAL} ansible_ssh_user=$root_user" -i "${ANDOCK_INVENTORY}/${connection}"  -m raw -a "test -e /usr/bin/python3 || (apt -y update && apt install -y python3-minimal) || (yum -y update && yum install -y python)"
        ansible-playbook -e "docksal_version=${REQUIREMENTS_ANDOCK_SERVER_DOCKSAL} ssh2docksal_command='${SSH2DOCKSAL_COMMAND}' ssh2docksal_version=${REQUIREMENTS_ANDOCK_SERVER_SSH2DOCKSAL} ansible_ssh_user=$root_user" -i "${ANDOCK_INVENTORY}/${connection}" -e "pw='$andock_pw_enc'" "$@" "${ANDOCK_PLAYBOOK}/server_install.yml"
        echo
        echo-green "Andock password is: ${andock_pw}"
        echo
        echo-green "Andock server was installed successfully."
    fi

    if [ "${tag}" = "update" ]; then
        echo-green "Updating Docksal on host"
        echo-green "This will take some minutes..."
        echo
        ansible-playbook -e "${andock_pw_option}" -e "docksal_version=${REQUIREMENTS_ANDOCK_SERVER_DOCKSAL} ssh2docksal_command='${SSH2DOCKSAL_COMMAND}' ssh2docksal_version=${REQUIREMENTS_ANDOCK_SERVER_SSH2DOCKSAL} ansible_ssh_user=${root_user}" -i "${ANDOCK_INVENTORY}/${connection}" -e "pw='$andock_pw_enc'" "$@" "${ANDOCK_PLAYBOOK}/server_install.yml"
        echo
        echo-green "Andock server was updated successfully."
    fi

    if [ "${tag}" = "show_key" ]; then
        echo-green "Show Andock public key"
        echo
        ansible-playbook -e "${andock_pw_option}" -e "docksal_version=${REQUIREMENTS_ANDOCK_SERVER_DOCKSAL} ssh2docksal_version=${REQUIREMENTS_ANDOCK_SERVER_SSH2DOCKSAL} ansible_ssh_user=${root_user}" --tags "show_key" -i "${ANDOCK_INVENTORY}/${connection}" "$@" "${ANDOCK_PLAYBOOK}/server_install.yml"
        echo
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

int_branch="$1"
add="${int_branch:0:1}"

if [ "$add" = ":" ]; then
    # Connection alias found.
    BRANCH="${int_branch:1}"
    shift
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
    echo
    figlet "Andock"
    echo "Connection: $connection"
    echo
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
        install_ansible_collection "$@"
    ;;
    cup)
        install_ansible_collection "$@"
    ;;
    ping)
        ping "$connection"
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
        case "$1" in
            clean)
              shift
	            run_build_clean "$connection" "$@"
            ;;
             push)
              shift
	            run_build_push "$connection" "$@"
            ;;
             deploy)
              shift
	            run_build_push "$connection" "$@"
	            run_environment "$connection" "init,update" "$@"
            ;;
            *)
                run_build "$connection" "$@"
            ;;
        esac
        ;;
    deploy)
	    run_environment "$connection" "init,update" "$@"
    ;;
    clean)
      set -e
      run_environment "$connection" "rm" "$@"
	    run_build_clean_artifact_branch "$connection" "$@"
	    echo $(execute_ansible "$connection" "" -m file -a 'path=\"{{ environment_home }}\" state=absent')
    ;;
    environment)
        case "$1" in
            deploy)
                shift
	              run_environment "$connection" "init,update" "$@"
            ;;
            init)
                shift
	              run_environment "$connection" "init" "$@"
            ;;
            update)
                shift
	              run_environment "$connection" "up,update" "$@"
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
            letsencrypt)
                shift
                run_environment "$connection" "up,letsencrypt" "$@"
            ;;
            status)
                shift
                run_environment_status "$connection" "$@"
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
        status=$(get_environment_status "$connection")
        if [[ $status != 1 ]]; then
            show_environment_status_messages $status
            exit 1
        fi
	      run_fin "$connection" "$*"
    ;;
    drush)
        case "$1" in
            generate-alias)
                shift

                if [[ $1 == "" ]] || [[ "$1" == "9" ]]; then
                    run_drush_generate_9 "$connection"
                    exit 0
                fi
                if [[ "$1" == "8" ]]; then
                    run_drush_generate_8 "$connection"
                    exit 0
                fi
                echo-yellow "Invalid drush version '$1'. See 'andock help' for list of available commands" && \
                exit 1
            ;;
            *)
                echo-yellow "Unknown command '$command $1'. See 'andock help' for list of available commands" && \
                exit 1
            ;;
        esac
        ;;
    server)
        case "$1" in
            sizes)
                shift
                run_server_info "$connection"
            ;;
            install)
                shift
                run_server "$connection" "install" "$@"
            ;;
            ssh-add)
                shift
                run_server_ssh_add "$connection" "$1" "$2"
             ;;
            show-pub-key)
                shift
                run_server  "$connection" "show_key"
             ;;
            version)
                shift
                run_environment  "$connection" "version"
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
