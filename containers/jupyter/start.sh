#!/bin/bash
# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.

set -e
echo $LAB_USER
echo $HOGEHOGEHOGE
# Exec the specified command or fall back on bash
if [ $# -eq 0 ]; then
    cmd=bash
else
    cmd=$*
fi

run-hooks () {
    # Source scripts or run executable files in a directory
    if [[ ! -d "$1" ]] ; then
	return
    fi
    echo "$0: running hooks in $1"
    for f in "$1"/*; do
	case "$f" in
	    *.sh)
		echo "$0: running $f"
		source "$f"
		;;
	    *)
		if [[ -x "$f" ]] ; then
		    echo "$0: running $f"
		    "$f"
		else
		    echo "$0: ignoring $f"
		fi
		;;
	esac
    echo "$0: done running hooks in $1"
    done
}

run-hooks /usr/local/bin/start-notebook.d

# Handle special flags if we're root
if [ $(id -u) == 0 ] ; then

    # Only attempt to change the jovyan username if it exists
    if id jovyan &> /dev/null ; then
        echo "Set username to: $LAB_USER"
        usermod -d /home/$LAB_USER -l $LAB_USER jovyan
    fi

    # Handle case where provisioned storage does not have the correct permissions by default
    # Ex: default NFS/EFS (no auto-uid/gid)
    if [[ "$CHOWN_HOME" == "1" || "$CHOWN_HOME" == 'yes' ]]; then
        echo "Changing ownership of /home/$LAB_USER to $LAB_UID:$LAB_GID"
        chown $CHOWN_HOME_OPTS $LAB_UID:$LAB_GID /home/$LAB_USER
    fi
    if [ ! -z "$CHOWN_EXTRA" ]; then
        for extra_dir in $(echo $CHOWN_EXTRA | tr ',' ' '); do
            chown $CHOWN_EXTRA_OPTS $LAB_UID:$LAB_GID $extra_dir
        done
    fi

    # handle home and working directory if the username changed
    if [[ "$LAB_USER" != "jovyan" ]]; then
        # changing username, make sure homedir exists
        # (it could be mounted, and we shouldn't create it if it already exists)
        if [[ ! -e "/home/$LAB_USER" ]]; then
            echo "Relocating home dir to /home/$LAB_USER"
            mv /home/jovyan "/home/$LAB_USER"
        fi
        # if workdir is in /home/jovyan, cd to /home/$LAB_USER
        if [[ "$PWD/" == "/home/jovyan/"* ]]; then
            newcwd="/home/$LAB_USER/${PWD:13}"
            echo "Setting CWD to $newcwd"
            cd "$newcwd"
        fi
    fi

    # Change UID of LAB_USER to LAB_UID if it does not match
    if [ "$LAB_UID" != $(id -u $LAB_USER) ] ; then
        echo "Set $LAB_USER UID to: $LAB_UID"
        usermod -u $LAB_UID $LAB_USER
    fi

    # Set LAB_USER primary gid to LAB_GID (after making the group).  Set
    # supplementary gids to LAB_GID and 100.
    if [ "$LAB_GID" != $(id -g $LAB_USER) ] ; then
        echo "Add $LAB_USER to group: $LAB_GID"
        groupadd -g $LAB_GID -o ${LAB_GROUP:-${LAB_USER}}
        usermod -g $LAB_GID -a -G $LAB_GID,100 $LAB_USER
    fi

    # Enable sudo if requested
    if [[ "$GRANT_SUDO" == "1" || "$GRANT_SUDO" == 'yes' ]]; then
        echo "Granting $LAB_USER sudo access and appending $CONDA_DIR/bin to sudo PATH"
        echo "$LAB_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/notebook
    fi

    # Add $CONDA_DIR/bin to sudo secure_path
    sed -r "s#Defaults\s+secure_path=\"([^\"]+)\"#Defaults secure_path=\"\1:$CONDA_DIR/bin\"#" /etc/sudoers | grep secure_path > /etc/sudoers.d/path

    # Exec the command as LAB_USER with the PATH and the rest of
    # the environment preserved
    run-hooks /usr/local/bin/before-notebook.d
    echo "Executing the command: $cmd"
    exec sudo -E -H -u $LAB_USER PATH=$PATH XDG_CACHE_HOME=/home/$LAB_USER/.cache PYTHONPATH=$PYTHONPATH $cmd
else
    if [[ "$LAB_UID" == "$(id -u jovyan)" && "$LAB_GID" == "$(id -g jovyan)" ]]; then
        # User is not attempting to override user/group via environment
        # variables, but they could still have overridden the uid/gid that
        # container runs as. Check that the user has an entry in the passwd
        # file and if not add an entry.
        whoami &> /dev/null || STATUS=$? && true
        if [[ "$STATUS" != "0" ]]; then
            if [[ -w /etc/passwd ]]; then
                echo "Adding passwd file entry for $(id -u)"
                cat /etc/passwd | sed -e "s/^jovyan:/nayvoj:/" > /tmp/passwd
                echo "jovyan:x:$(id -u):$(id -g):,,,:/home/jovyan:/bin/bash" >> /tmp/passwd
                cat /tmp/passwd > /etc/passwd
                rm /tmp/passwd
            else
                echo 'Container must be run with group "root" to update passwd file'
            fi
        fi

        # Warn if the user isn't going to be able to write files to $HOME.
        if [[ ! -w /home/jovyan ]]; then
            echo 'Container must be run with group "users" to update files'
        fi
    else
        # Warn if looks like user want to override uid/gid but hasn't
        # run the container as root.
        if [[ ! -z "$LAB_UID" && "$LAB_UID" != "$(id -u)" ]]; then
            echo 'Container must be run as root to set $LAB_UID'
        fi
        if [[ ! -z "$LAB_GID" && "$LAB_GID" != "$(id -g)" ]]; then
            echo 'Container must be run as root to set $LAB_GID'
        fi
    fi

    # Warn if looks like user want to run in sudo mode but hasn't run
    # the container as root.
    if [[ "$GRANT_SUDO" == "1" || "$GRANT_SUDO" == 'yes' ]]; then
        echo 'Container must be run as root to grant sudo permissions'
    fi

    # Execute the command
    run-hooks /usr/local/bin/before-notebook.d
    echo "Executing the command: $cmd"
    exec $cmd
fi
