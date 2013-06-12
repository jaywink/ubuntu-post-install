#!/bin/bash
# -*- Mode: sh; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Authors:
#	Jason Robinson <jaywink@basshero.org>
#
# Description:
#   A post-installation bash script for Ubuntu Touch
#   Shamelessly copied idea and base script from
#   https://github.com/snwh/ubuntu-post-install
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

echo ''
echo '#-----------------------------------------------#'
echo '#     Ubuntu Touch Post-Daily-Flash Script      #'
echo '#-----------------------------------------------#'

# NETWORK CONFIG
function networkconf {
    echo 'Requires root privileges:'
    echo 'Installing network configuration and SSH...'
    phablet-network-setup -i
    adb forward tcp:8888 tcp:22
    echo 'When connecting via SSH, password is "phablet"'
    if [ `cat ~/.bashrc |  grep -c "alias sshphablet"` -eq 0 ]; then
        echo 'Putting sshphablet alias in to .bashrc..'
        echo 'alias sshphablet="adb forward tcp:8888 tcp:22 && ssh phablet@localhost -p 8888"' >> ~/.bashrc
        echo 'You can now connect with sshphablet alias. Make sure to run "source ~/.bashrc" after finishing this script.'
    fi
    ## SSH KEY SECTION DISABLED FOR NOW
    #~ if [ -e ~/.ssh/id_rsa.pub ]; then
        #~ echo 'Copying SSH public key to device..'
        #~ scp -P 8888 ~/.ssh/id_rsa.pub phablet@localhost:
        #~ ssh phablet@localhost -p 8888 '[ -e .ssh ] || mkdir .ssh && cat id_rsa.pub >> .ssh/authorized_keys && rm -f id_rsa.pub'
        #~ echo 'Passwordless login to device should now be possible.' 
    #~ fi
    echo 'Done.'
    main
}

# SYSTEM UPGRADE
function sysupgrade {
    adb forward tcp:8888 tcp:22
    # Update Repository Information
    echo 'Updating repository information...'
    echo 'Requires root privileges:'
    ssh phablet@localhost -tp 8888 'sudo apt-get update -qq'
    # Dist-Upgrade
    echo 'Performing system upgrade...'
    ssh phablet@localhost -tp 8888 'sudo apt-get dist-upgrade -y'
    echo 'Done.'
    main
}

# INSTALL CORE APPLICATIONS
function coreappinstall {
    adb forward tcp:8888 tcp:22
    # Install Core Applications
    echo 'Requires root privileges:'
    echo 'Adding PPA for core apps'
    ssh phablet@localhost -tp 8888 'sudo add-apt-repository -y ppa:ubuntu-touch-coreapps-drivers/daily'
    ssh phablet@localhost -tp 8888 'sudo apt-get update -qq'
    echo 'Installing core apps...'
    ssh phablet@localhost -tp 8888 'sudo apt-get install -y --no-install-recommends touch-coreapps'
    echo 'Done.'
    main
}

# INSTALL Collection APPLICATIONS
function collectionappinstall {
    adb forward tcp:8888 tcp:22
    # Install Collection Applications
    echo 'Requires root privileges:'
    echo 'Adding PPA for Collection apps'
    ssh phablet@localhost -tp 8888 'sudo add-apt-repository -y ppa:ubuntu-touch-coreapps-drivers/collection'
    ssh phablet@localhost -tp 8888 'sudo apt-get update -qq'
    echo 'Installing collection apps...'
    ssh phablet@localhost -tp 8888 'sudo apt-get install -y --no-install-recommends touch-collection'
    echo 'Done.'
    main
}

# CONFIG
function config {
    adb forward tcp:8888 tcp:22
    INPUT=0
    echo ''
    echo 'What would you like to do? (Enter the number of your choice)'
    echo ''
    while [ true ]
    do
    echo '1. Set timezone on device?'
    echo '10. Return'
    echo ''
    read INPUT
    # Timezone
    if [ $INPUT -eq 1 ]; then
        echo 'Type a valid timezone (for example Europe/Helsinki):'
        read timezone
        ssh phablet@localhost -tp 8888 "echo \"$timezone\" | sudo tee /etc/timezone"
        ssh phablet@localhost -tp 8888 "sudo dpkg-reconfigure --frontend noninteractive tzdata"
        echo 'Done.'
        config
    # Return
    elif [ $INPUT -eq 10 ]; then
        clear && main
    else
    # Invalid Choice
        echo 'Invalid, choose again.'
        config
    fi
    done
}


# END
function end {
    echo ''
    read -p 'Are you sure you want to quit? (Y)es/(n)o '
    if [ '$REPLY' == 'n' ]; then
        clear && main
    else
        exit
    fi
}


#----- MAIN FUNCTION -----#
function main {
    INPUT=0
    echo ''
    echo 'What would you like to do? (Enter the number of your choice)'
    echo ''
    while [ true ]
    do
    echo '1. Configure network and SSH?'
    echo '2. Perform system update & upgrade?'
    echo '3. Install core applications?'
    echo '4. Install collection applications?'
    echo '8. Configure system?'
    echo '10. Quit?'
    echo ''
    read INPUT
    # System Upgrade
    if [ $INPUT -eq 1 ]; then
        clear && networkconf
    # System Upgrade
    elif [ $INPUT -eq 2 ]; then
        clear && sysupgrade
    # Install Core Applications
    elif [ $INPUT -eq 3 ]; then
        clear && coreappinstall
    # Install Collection Applications
    elif [ $INPUT -eq 4 ]; then
        clear && collectionappinstall
    # Configure System
    elif [ $INPUT -eq 8 ]; then
        clear && config
    # End
    elif [ $INPUT -eq 10 ]; then
        end
    else
    # Invalid Choice
        echo 'Invalid, choose again.'
        main
    fi
    done
}

# Are we able to connect?
if [ `adb devices | grep -wc device` -eq 1 ]; then
    echo 'Device connected. Please install SSH packages if not done'
else
    echo 'No device found - please connect a device first and check "adb devices" output to make sure one is connected'
    exit
fi

#----- RUN MAIN FUNCTION -----#
main

#END
