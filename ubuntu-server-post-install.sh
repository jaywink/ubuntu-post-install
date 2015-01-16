#!/bin/bash
# -*- Mode: sh; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Authors:
#   Sam Hewitt <hewittsamuel@gmail.com>
#	Jason Robinson <jaywink@basshero.org>
#
# Description:
#   A post-installation bash script for Ubuntu (13.xx) Server
#
# Legal Stuff:
#
# This script is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; version 3.
#
# This script is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, see <https://www.gnu.org/licenses/gpl-3.0.txt>

set -e

echo ''
echo '#--------------------------------------------------#'
echo '#     Ubuntu 13.xx Server Post-Install Script      #'
echo '#--------------------------------------------------#'

#----- FUNCTIONS -----#

# SYSTEM UPGRADE
function sysupgrade {
# Update Repository Information
echo 'Requires root privileges:'
echo 'Updating repository information...'
sudo apt-get update -qq
# Dist-Upgrade
echo 'Performing system upgrade...'
sudo apt-get dist-upgrade
echo 'Done.'
main
}

# PROPOSED
function addproposed {
# Add Proposed repository
echo 'Requires root privileges:'
echo 'Adding proposed repository - are you sure (y to accept)? Things could break...'
read REPLY
if [ '$REPLY' == 'y' ]; then
    RELEASE=`lsb_release -sc`
    if [ `cat /etc/apt/sources.list | grep $RELEASE-proposed -c` -eq 0 ]; then
        echo 'Adding proposed repository'
        SOURCELINE=( `cat /etc/apt/sources.list | grep archive.ubuntu.com -m 1` )
        sudo add-apt-repository -y "deb ${SOURCELINE[1]} $RELEASE-proposed restricted main universe multiverse"
    fi
    sysupgrade
else
    clear && main
fi
}

# INSTALL APPLICATIONS
function appinstall {
# Install Favourite Applications
echo 'Done.'
main
}

# INSTALL SYSTEM TOOLS
function toolinstall {
echo 'Requires root privileges:'
echo 'Installing system tools...'
sudo apt-get install htop curl vim
echo 'Done.'
main
}

# INSTALL DEVELOPMENT TOOLS
function devinstall {
INPUT=0
if [[ ! -d $HOME/workspace ]]; then
    mkdir $HOME/workspace
fi
echo ''
echo 'What would you like to do? (Enter the number of your choice)'
echo ''
while [ true ]
do
echo '1. Install development tools?'
echo '0. Return'
echo ''
read INPUT
# Install Development Tools
if [ $INPUT -eq 1 ]; then
    sudo apt-get install software-properties-common
    sudo dpkg-reconfigure unattended-upgrades
    echo 'Adding PPA for: Node.js'
    sudo add-apt-repository -y ppa:chris-lea/node.js
    sudo apt-get update -qq
    echo 'Installing development tools...'
    # mongodb-server,lxc for juju
    sudo apt-get install git ruby build-essential nodejs python-setuptools python-dev
    # required to compile python-mysql using pip
    sudo apt-get install -y libssl-dev libcrypto++-dev
    echo 'Install some Node modules...'
    sudo npm install -g bower
    echo 'Installing some extra Python stuff...'
    sudo easy_install pip
    echo 'Installing virtualenvwrapper..'
    sudo pip install -U virtualenv virtualenvwrapper
    if [[ ! -d $HOME/.virtualenvs ]]; then
        mkdir $HOME/.virtualenvs
    fi
    echo 'Installing PSS..'
    sudo pip install -U pss
    echo 'Install pep8..'
    sudo pip install -U pep8
    echo 'Install pyflakes..'
    sudo pip install -U pyflakes
    echo 'Installing Pythonz...'
    curl -kL https://raw.github.com/saghul/pythonz/master/pythonz-install | bash
    # Git
    # echo 'Symlink git config...'
    # git config
    # rm -f $HOME/.gitconfig
    # ln -s "$HOME/Ubuntu One/config/git/gitconfig" $HOME/.gitconfig
    echo 'Done.'
    devinstall
# Return
elif [ $INPUT -eq 0 ]; then
    clear && main
else
# Invalid Choice
    echo 'Invalid, choose again.'
    devinstall
fi
done
}

# CONFIG
function config {
INPUT=0
echo ''
echo 'What would you like to do? (Enter the number of your choice)'
echo ''
while [ true ]
do
echo '1. Set some generic application and environment settings?'
echo '3. Set some bash aliases and settings?'
echo '0. Return'
echo ''
read INPUT
# App and env settings
if [ $INPUT -eq 1 ]; then
    # SSH
    # if [[ ! -d $HOME/.ssh ]]; then
    #     mkdir $HOME/.ssh
    # fi
    # rm -f $HOME/.ssh/config $HOME/.ssh/id_rsa $HOME/.ssh/id_rsa.pub
    # ln -s "$HOME/Ubuntu One/config/ssh/config" $HOME/.ssh/config
    # ln -s "$HOME/Ubuntu One/config/ssh/id_rsa" $HOME/.ssh/id_rsa
    # ln -s "$HOME/Ubuntu One/config/ssh/id_rsa.pub" $HOME/.ssh/id_rsa.pub
    # Language and locale
    sudo sed --in-place "s|LANG=\"en_US.UTF-8\"|LANG=\"en_US.UTF-8\"|" /etc/default/locale
    sudo sed --in-place "s|LC_TIME=\"fi_FI.UTF-8\"|LC_TIME=\"en_GB.UTF-8\"|" /etc/default/locale
    config
# Bash aliases and settings
elif [ $INPUT -eq 3 ]; then
    # echo 'Setting some bash aliases and settings..'
    # if [[ `cat $HOME/.bashrc | grep additionalrc | wc -l` -eq 0 ]]; then
    #     echo 'source "$HOME/Ubuntu One/config/bash/additionalrc"' >> $HOME/.bashrc
    # fi
    echo 'Done.'
    config
# Return
elif [ $INPUT -eq 0 ]; then
    clear && main
else
# Invalid Choice
    echo 'Invalid, choose again.'
    config
fi
done
}

# CLEANUP SYSTEM
function cleanup {
INPUT=0
echo ''
echo 'What would you like to do? (Enter the number of your choice)'
echo ''
while [ true ]
do
echo ''
echo '1. Remove unused pre-installed packages?'
echo '2. Remove old kernel(s)?'
echo '3. Remove orphaned packages?'
echo '4. Remove leftover configuration files?'
echo '5. Clean package cache?'
echo '6. Return?'
echo ''
read INPUT
# Remove Unused Pre-installed Packages
if [ $INPUT -eq 1 ]; then
    echo 'Removing selected pre-installed applications...'
    echo 'Done.'
    cleanup
# Remove Old Kernel
elif [ $INPUT -eq 2 ]; then
    echo 'Removing old Kernel(s)...'
    sudo dpkg -l 'linux-*' | sed '/^ii/!d;/'"$(uname -r | sed "s/\(.*\)-\([^0-9]\+\)/\1/")"'/d;s/^[^ ]* [^ ]* \([^ ]*\).*/\1/;/[0-9]/!d' | grep -v linux-libc-dev | xargs sudo apt-get purge
    echo 'Done.'
    cleanup
# Remove Orphaned Packages
elif [ $INPUT -eq 3 ]; then
    echo 'Removing orphaned packages...'
    echo 'Requires root privileges:'
    sudo apt-get autoremove
    echo 'Done.'
    cleanup
# Remove residual config files?
elif [ $INPUT -eq 4 ]; then
    echo 'Removing leftover configuration files...'
    echo 'Requires root privileges:'
    sudo dpkg --purge $(COLUMNS=200 dpkg -l | grep '^rc' | tr -s ' ' | cut -d ' ' -f 2)
    echo 'Done.'
# Clean Package Cache
elif [ $INPUT -eq 5 ]; then
    echo 'Cleaning package cache...'
    echo 'Requires root privileges:'
    sudo apt-get clean
    echo 'Done.'
    cleanup
# Return
elif [ $INPUT -eq 6 ]; then
    clear && main
else
# Invalid Choice
    echo 'Invalid, choose again.'
    cleanup
fi
done
}

#----- MAIN FUNCTION -----#
function main {
INPUT=0
echo ''
echo 'What would you like to do? (Enter the number of your choice)'
echo ''
while [ true ]
do
echo '0. Add proposed repository?'
echo '1. Perform system update & upgrade?'
echo '2. Install favourite applications?'
echo '3. Install favourite system tools?'
echo '5. Install development tools?'
echo '8. Configure system?'
echo '9. Cleanup the system?'
echo '10. Quit?'
echo ''
read INPUT
# System Upgrade
if [ $INPUT -eq 0 ]; then
    clear && addproposed
# System Upgrade
elif [ $INPUT -eq 1 ]; then
    clear && sysupgrade
# Install Favourite Applications
elif [ $INPUT -eq 2 ]; then
    clear && appinstall
# Install Favourite Tools
elif [ $INPUT -eq 3 ]; then
    clear && toolinstall
# Install Games
elif [ $INPUT -eq 4 ]; then
    clear && gamesinstall
# Install Dev Tools
elif [ $INPUT -eq 5 ]; then
    clear && devinstall
# Install Ubuntu Restricted Extras
elif [ $INPUT -eq 6 ]; then
    clear && codecinstall
# Install Third-Party Applications
elif [ $INPUT -eq 7 ]; then
    clear && thirdparty
# Configure System
elif [ $INPUT -eq 8 ]; then
    clear && config
# Cleanup System
elif [ $INPUT -eq 9 ]; then
    clear && cleanup
# End
elif [ $INPUT -eq 10 ]; then
    exit
else
# Invalid Choice
    echo 'Invalid, choose again.'
    main
fi
done
}

#----- RUN MAIN FUNCTION -----#
main

#END
