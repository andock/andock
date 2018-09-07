#!/bin/bash

# This script is running as root by default.
# Switching to the docker user can be done via "gosu docker <command>".

HOME_DIR='/home/docker'

DEBUG=${DEBUG:-1}
# Turn debugging ON when andock is started in the service mode
[[ "$1" == "supervisord" ]] && DEBUG=1

echo-debug ()
{
	[[ "$DEBUG" != 0 ]] && echo "$(date +"%F %H:%M:%S") | $@"
}

uid_gid_reset ()
{
	if [[ "$HOST_UID" != "$(id -u docker)" ]] || [[ "$HOST_GID" != "$(id -g docker)" ]]; then
		echo-debug "Updating docker user uid/gid to $HOST_UID/$HOST_GID to match the host user uid/gid..."
		usermod -u "$HOST_UID" -o docker
		groupmod -g "$HOST_GID" -o "$(id -gn docker)"
	fi
}

# Helper function to render configs from go templates using gomplate
render_tmpl ()
{
	local file="${1}"
	local tmpl="${1}.tmpl"

	if [[ -f "${tmpl}" ]]; then
		echo-debug "Rendering template: ${tmpl}..."
		gomplate --file "${tmpl}" --out "${file}"
	else
		echo-debug "Error: Template file not found: ${tmpl}"
		return 1
	fi
}

add_ssh_key ()
{
	echo-debug "Adding a private SSH key from SECRET_SSH_PRIVATE_KEY..."
	render_tmpl "$HOME_DIR/.ssh/id_rsa"
	chmod 0600 "$HOME_DIR/.ssh/id_rsa"
}

# Git settings
git_settings ()
{
	# These must be run as the docker user
	echo-debug "Configuring git..."
	gosu docker git config --global user.email "${GIT_USER_EMAIL}"
	gosu docker git config --global user.name "${GIT_USER_NAME}"
}

# Inject a private SSH key if provided
[[ "$SECRET_SSH_PRIVATE_KEY" != "" ]] && add_ssh_key

# Docker user uid/gid mapping to the host user uid/gid
[[ "$HOST_UID" != "" ]] && [[ "$HOST_GID" != "" ]] && uid_gid_reset

# Make sure permissions are correct (after uid/gid change and COPY operations in Dockerfile)
# To not bloat the image size, permissions on the home folder are reset at runtime.
echo-debug "Resetting permissions on $HOME_DIR and /var/www..."
chown "${HOST_UID:-1000}:${HOST_GID:-1000}" -R "$HOME_DIR"
# Docker resets the project root folder permissions to 0:0 when cli is recreated (e.g. an env variable updated).
# We apply a fix/workaround for this at startup (non-recursive).
chown "${HOST_UID:-1000}:${HOST_GID:-1000}" /var/www


# Apply git settings
[[ "$GIT_USER_EMAIL" != "" ]] && [[ "$GIT_USER_NAME" != "" ]] && git_settings

# If crontab file is found within project add contents to user crontab file.
if [[ -f ${PROJECT_ROOT}/.docksal/services/andock/crontab ]]; then
	echo-debug "Loading crontab..."
	cat ${PROJECT_ROOT}/.docksal/services/andock/crontab | crontab -u docker -
fi

# Execute passed CMD arguments
echo-debug "Passing execution to: $*"
# Service mode (run as root)
if [[ "$1" == "supervisord" ]]; then
	exec gosu root supervisord -c /etc/supervisor/supervisord.conf
# Command mode (run as docker user)
else
	exec gosu docker "$@"
fi
