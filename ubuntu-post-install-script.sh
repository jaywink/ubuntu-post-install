#!/bin/bash
# -*- Mode: sh; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Authors:
#   Sam Hewitt <hewittsamuel@gmail.com>
#	Jason Robinson <jaywink@basshero.org>
#
# Description:
#   A post-installation bash script for Ubuntu (13.04)
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
echo '#-------------------------------------------#'
echo '#     Ubuntu 13.04 Post-Install Script      #'
echo '#-------------------------------------------#'

#----- FUNCTIONS -----#

# SYSTEM UPGRADE
function sysupgrade {
# Update Repository Information
echo 'Requires root privileges:'
echo 'Updating repository information...'
sudo apt-get update -qq
# Dist-Upgrade
echo 'Performing system upgrade...'
sudo apt-get dist-upgrade -y
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
    if [ `cat /etc/apt/sources.list | grep raring-proposed -c` -eq 0 ]; then
        echo 'Adding proposed repository'
        SOURCELINE=( `cat /etc/apt/sources.list | grep archive.ubuntu.com -m 1` )
        sudo add-apt-repository -y "deb ${SOURCELINE[1]} $(lsb_release -sc)-proposed restricted main universe multiverse"
    fi
    sysupgrade
else
    clear && main
fi
}

# INSTALL APPLICATIONS
function appinstall {
# Install Favourite Applications
echo 'Requires root privileges:'
echo 'Adding PPA for: my-weather-indicator'
sudo add-apt-repository -y ppa:atareao/atareao
echo 'Adding PPA for: qBittorrent'
sudo add-apt-repository -y ppa:saiarcot895/myppa
echo 'Adding PPA for: y-ppa-manager'
sudo add-apt-repository -y ppa:webupd8team/y-ppa-manager
echo 'Adding webupd8 PPA'
sudo add-apt-repository -y ppa:nilarimogard/webupd8
echo 'Adding PPA for: GIMP'
sudo add-apt-repository -y ppa:otto-kesselgulasch/gimp
echo 'Adding PPA for: Ubuntu Tweak'
sudo add-apt-repository -y ppa:tualatrix/ppa
echo 'Adding PPA for: Diodon'
sudo add-apt-repository -y ppa:diodon-team/stable 
echo 'Adding PPA for: Variety'
sudo add-apt-repository -y ppa:peterlevi/ppa
sudo apt-get update -qq
echo 'Installing selected favourite applications...'
sudo apt-get install -y --no-install-recommends gimp gimp-plugin-registry dropbox xchat terminator digikam keepassx chromium-browser friends calibre unity-mail qbittorrent shutter my-weather-indicator diodon indicator-multiload hamster-applet hamster-indicator y-ppa-manager compizconfig-settings-manager thunderbird vlc wireshark ubuntu-tweak variety
echo 'Done.'
main
}

# INSTALL SYSTEM TOOLS
function toolinstall {
echo 'Requires root privileges:'
echo 'Adding PPA for: tlp'
sudo add-apt-repository -y ppa:linrunner/tlp
sudo apt-get update -qq
echo 'Installing system tools...'
sudo apt-get install -y --no-install-recommends ppa-purge tlp htop
echo 'Done.'
main
}

# INSTALL GAMES
function gamesinstall {
echo 'Requires root privileges:'
echo 'Installing games...'
sudo apt-get install -y --no-install-recommends gcompris supertuxkart tuxpaint tuxpaint-config
echo 'Done.'
main
}

# INSTALL MULTIMEDIA CODECS
function codecinstall {
# Install Ubuntu Restricted Extras Applications
echo 'Installing Ubuntu Restricted Extras...'
echo 'Requires root privileges:'
sudo apt-get install -y ubuntu-restricted-extras
echo 'Done.'
main
}

# INSTALL DEVELOPMENT TOOLS
function devinstall {
INPUT=0
echo ''
echo 'What would you like to do? (Enter the number of your choice)'
echo ''
while [ true ]
do
echo '1. Install development tools?'
echo '2. Install Ubuntu SDK?'
echo '3. Install Ubuntu Phablet Tools?'
echo '4. Install IRC bot tools?'
echo '5. Return'
echo ''
read INPUT
# Install Development Tools
if [ $INPUT -eq 1 ]; then
    echo 'Requires root privileges:'
    echo 'Adding PPA for: geany'
    sudo add-apt-repository -y ppa:geany-dev/ppa
    echo 'Adding PPA for: Node.js'
    sudo add-apt-repository -y ppa:chris-lea/node.js
    sudo apt-get update -qq
    echo 'Installing development tools...'
    sudo apt-get install -y bzr devscripts git glade icontool python3-distutils-extra qtcreator ruby build-essential meld geany geany-plugins mysql-workbench nodejs ipython ipython-doc
    echo 'Done.'
    devinstall
# Install Ubuntu SDK
elif [ $INPUT -eq 2 ]; then
    echo 'Adding QT5 Edgers PPA to software sources...'
    echo 'Requires root privileges:'
    sudo add-apt-repository -y ppa:canonical-qt5-edgers/qt5-proper
    echo 'Adding Ubuntu SDK Team PPA to software sources...'
    echo 'Requires root privileges:'
    sudo add-apt-repository -y ppa:ubuntu-sdk-team/ppa
    echo 'Updating repository information...'
    sudo apt-get update -qq
    echo 'Installing Ubuntu SDK...'
    sudo apt-get install -y ubuntu-sdk
    echo 'Done.'
    devinstall
# Install Ubuntu Phablet Tools
elif [ $INPUT -eq 3 ]; then
    echo 'Adding Phablet Team PPA to software sources...'
    echo 'Requires root privileges:'
    sudo add-apt-repository -y ppa:phablet-team/tools
    echo 'Updating repository information...'
    sudo apt-get update -qq
    echo 'Installing Ubuntu SDK...'
    sudo apt-get install -y phablet-tools
    echo 'Done.'
    devinstall
# Install IRC Bot Tools
elif [ $INPUT -eq 4 ]; then
    echo 'Installing IRC bot tools...'
    echo 'Requires root privileges:'
    sudo apt-get install -y python-soappy supybot
    echo 'Done.'
    devinstall
# Return
elif [ $INPUT -eq 5 ]; then
    clear && main
else
# Invalid Choice
    echo 'Invalid, choose again.'
    devinstall
fi
done
}

# THIRD PARTY APPLICATIONS
function thirdparty {
INPUT=0
echo ''
echo 'What would you like to do? (Enter the number of your choice)'
echo ''
while [ true ]
do
echo '1. Install Google Chrome (Unstable)?'
echo '2. Install Google Talk Plugin?'
echo '3. Install Steam?'
echo '4. Install Unity Tweak Tool?'
echo '5. Install DVD playback tools?'
echo '6. Install EasyShutdown?'
echo '7. Install GetDeb games?'
echo '8. Install Great Little Radio Player?'
echo '9. Install Sublime Text?'
echo '0. Return'
echo ''
read INPUT
# Google Chrome
if [ $INPUT -eq 1 ]; then
    echo 'Downloading Google Chrome (Unstable)...'
    # Make tmp directory
    if [ ! -d $HOME/tmp ]; then
        mkdir -p $HOME/tmp
    else
        continue
    fi
    cd $HOME/tmp
    # Download Debian file that matches system architecture
    if [ $(uname -i) = 'i386' ]; then
        wget https://dl.google.com/linux/direct/google-chrome-stable_current_i386.deb
    elif [ $(uname -i) = 'x86_64' ]; then
        wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    fi
    # Install the package
    echo 'Installing Google Chrome...'
    sudo dpkg -i google*.deb
    sudo apt-get install -fy
    # Cleanup and finish
    rm *.deb
    cd
    echo 'Done.'
    thirdparty
# Google Talk Plugin
elif [ $INPUT -eq 2 ]; then
    echo 'Downloading Google Talk Plugin...'
    # Make tmp directory
    if [ ! -d $HOME/tmp ]; then
        mkdir -p $HOME/tmp
    else
        continue
    fi
    cd $HOME/tmp
    # Download Debian file that matches system architecture
    if [ $(uname -i) = 'i386' ]; then
        wget https://dl.google.com/linux/direct/google-talkplugin_current_i386.deb
    elif [ $(uname -i) = 'x86_64' ]; then
        wget https://dl.google.com/linux/direct/google-talkplugin_current_amd64.deb
    fi
    # Install the package
    echo 'Installing Google Talk Plugin...'
    sudo dpkg -i google*.deb
    sudo apt-get install -fy
    # Cleanup and finish
    rm *.deb
    cd
    echo 'Done.'
    thirdparty
# Steam
elif [ $INPUT -eq 3 ]; then
    echo 'Downloading Steam...'
    # Make tmp directory
    if [ ! -d $HOME/tmp ]; then
        mkdir -p $HOME/tmp
    else
        continue
    fi
    cd $HOME/tmp
    # Download Debian file that matches system architecture
    if [ $(uname -i) = 'i386' ]; then
        wget http://repo.steampowered.com/steam/archive/precise/steam_latest.deb
    elif [ $(uname -i) = 'x86_64' ]; then
        wget http://repo.steampowered.com/steam/archive/precise/steam_latest.deb
    fi
    # Install the package
    echo 'Installing Steam...'
    sudo dpkg -i steam*.deb
    sudo apt-get install -fy
    # Cleanup and finish
    rm *.deb
    cd
    echo 'Done.'
    thirdparty
# Unity Tweak Tool
elif [ $INPUT -eq 4 ]; then
    # Add repository
    echo 'Adding Unity Tweak Tool repository to sources...'
    echo 'Requires root privileges:'
    sudo add-apt-repository -y ppa:freyja-dev/unity-tweak-tool-daily
    # Update Repository Information
    echo 'Updating repository information...'
    sudo apt-get update -qq
    # Install the package
    echo 'Installing Unity Tweak Tool...'
    sudo apt-get install -y unity-tweak-tool
    echo 'Done.'
    thirdparty
# Medibuntu
elif [ $INPUT -eq 5 ]; then
    echo 'Adding Medibuntu repository to sources...'
    echo 'Requires root privileges:'
    sudo -E wget --output-document=/etc/apt/sources.list.d/medibuntu.list http://www.medibuntu.org/sources.list.d/$(lsb_release -cs).list && sudo apt-get update -qq && sudo apt-get --yes --quiet --allow-unauthenticated install medibuntu-keyring && sudo apt-get update -qq
    echo 'Done.'
    echo 'Installing libdvdcss2...'
    sudo apt-get install -y libdvdcss2
    echo 'Done.'
    thirdparty
# EasyShutdown
elif [ $INPUT -eq 6 ]; then
    echo 'Installing EasyShutdown...'
    echo 'Requires root privileges:'
    wget https://launchpad.net/easyshutdown/trunk/0.6/+download/easyshutdown_0.6_all.deb -O /tmp/easyshutdown_0.6_all.deb
    sudo dpkg -i /tmp/easyshutdown_0.6_all.deb
    rm -f /tmp/easyshutdown_0.6_all.deb
    sudo apt-get -f install
    echo 'Done.'
    thirdparty
# GetDeb and some games
elif [ $INPUT -eq 7 ]; then
    echo 'Installing GetDeb and some games...'
    echo 'Adding repository...'
    echo 'Requires root privileges:'
    wget http://archive.getdeb.net/install_deb/playdeb_0.3-1~getdeb1_all.deb -O /tmp/playdeb_0.3-1~getdeb1_all.deb
    sudo dpkg --no-debsig -i /tmp/playdeb_0.3-1~getdeb1_all.deb
    rm -f /tmp/playdeb_0.3-1~getdeb1_all.deb
    sudo apt-get update -qq
    echo 'Install FreeCiv...'
    sudo apt-get install -y freeciv-client-gtk
    echo 'Done.'
    thirdparty
# Great Little Radio Player
elif [ $INPUT -eq 8 ]; then
    echo 'Installing Great Little Radio Player...'
    echo 'Requires root privileges:'
    wget http://ubuntuone.com/07PaN5spFvXSMt3bhqY6us -O /tmp/greatlittleradioplayer_1.4.2_amd64.deb
    sudo dpkg -i /tmp/greatlittleradioplayer_1.4.2_amd64.deb
    rm -f /tmp/greatlittleradioplayer_1.4.2_amd64.deb
    echo 'Done.'
    thirdparty
# Sublime Text
elif [ $INPUT -eq 9 ]; then
    echo 'Installing Sublime Text...'
    echo 'Requires root privileges:'
    wget http://c758482.r82.cf2.rackcdn.com/sublime-text_build-3047_amd64.deb -O /tmp/sublime-text_build-3047_amd64.deb
    sudo dpkg -i /tmp/sublime-text_build-3047_amd64.deb
    rm -f /tmp/sublime-text_build-3047_amd64.deb
    cp "configs/Default (Linux).sublime-keymap" "$HOME/.config/sublime-text-3/Packages/User/"
    cp "configs/Preferences.sublime-settings" "$HOME/.config/sublime-text-3/Packages/User/"
    # install package manager from git
    cd $HOME/.config/sublime-text-3/Packages
    git clone https://github.com/wbond/sublime_package_control.git "Package Control"
    cd "Package Control"
    git checkout python3
    # install indentxml plugin
    cd $HOME/.config/sublime-text-3/Packages
    git clone https://github.com/alek-sys/sublimetext_indentxml.git indentxml
    echo 'Done.'
    thirdparty
# Return
elif [ $INPUT -eq 0 ]; then
    clear && main
else
# Invalid Choice
    echo 'Invalid, choose again.'
    thirdparty
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
echo '1. Set preferred application-specific settings?'
echo '2. Show all startup applications?'
echo '3. Return'
echo ''
read INPUT
# GSettings
if [ $INPUT -eq 1 ]; then
    # Nautilus Preferences
    echo 'Setting Nautilus preferences...'
    gsettings set org.gnome.nautilus.preferences sort-directories-first true
    # Gedit Preferences
    echo 'Setting Gedit preferences...'
    gsettings set org.gnome.gedit.preferences.editor display-line-numbers true
    gsettings set org.gnome.gedit.preferences.editor create-backup-copy false
    gsettings set org.gnome.gedit.preferences.editor auto-save true
    gsettings set org.gnome.gedit.preferences.editor insert-spaces true
    gsettings set org.gnome.gedit.preferences.editor tabs-size 4
    # Rhythmbox Preferences
    echo 'Setting Rhythmbox preferences...'
    gsettings set org.gnome.rhythmbox.rhythmdb monitor-library true
    gsettings set org.gnome.rhythmbox.sources browser-views 'artists-albums'
    gsettings set org.gnome.rhythmbox.sources visible-columns '['post-time', 'artist', 'duration', 'genre', 'album']'
    config
# Startup Applications
elif [ $INPUT -eq 2 ]; then
    echo 'Changing display of startup applications.'
    echo 'Requires root privileges:'    
    cd /etc/xdg/autostart/ && sudo sed --in-place 's/NoDisplay=true/NoDisplay=false/g' *.desktop
    cd
    echo 'Make some installed apps startup automatically.'
    echo 'Dropbox...'
    [ -e /usr/share/applications/dropbox.desktop ] && [ -e ~/.config/autostart/dropbox.desktop ] || ln -s /usr/share/applications/dropbox.desktop ~/.config/autostart/dropbox.desktop
    echo 'Empathy...'
    [ -e /usr/share/applications/empathy.desktop ] && [ -e ~/.config/autostart/empathy.desktop ] || ln -s /usr/share/applications/empathy.desktop ~/.config/autostart/empathy.desktop
    echo 'Hamster Indicator...'
    [ -e /usr/share/applications/hamster-indicator.desktop ] && [ -e ~/.config/autostart/hamster-indicator.desktop ] || ln -s /usr/share/applications/hamster-indicator.desktop ~/.config/autostart/hamster-indicator.desktop
    echo 'Indicator Multiload...'
    [ -e /usr/share/applications/indicator-multiload.desktop ] && [ -e ~/.config/autostart/indicator-multiload.desktop ] || ln -s /usr/share/applications/indicator-multiload.desktop ~/.config/autostart/indicator-multiload.desktop
    echo 'My Weather Indicator...'
    [ -e /opt/extras.ubuntu.com/my-weather-indicator/share/my-weather-indicator/my-weather-indicator-autostart.desktop ] && [ -e ~/.config/autostart/my-weather-indicator-autostart.desktop ] || ln -s /opt/extras.ubuntu.com/my-weather-indicator/share/my-weather-indicator/my-weather-indicator-autostart.desktop ~/.config/autostart/my-weather-indicator-autostart.desktop
    echo 'qBittorrent...'
    [ -e /usr/share/applications/qBittorrent.desktop ] && [ -e ~/.config/autostart/qbittorrent.desktop ] || ln -s /usr/share/applications/qBittorrent.desktop ~/.config/autostart/qbittorrent.desktop
    echo 'Shutter...'
    [ -e /usr/share/applications/shutter.desktop ] && [ -e ~/.config/autostart/shutter.desktop ] || ln -s /usr/share/applications/shutter.desktop ~/.config/autostart/shutter.desktop
    echo 'Unity Mail...'
    [ -e /usr/share/unity-mail/unity-mail-autostart.desktop ] && [ -e ~/.config/autostart/unity-mail-autostart.desktop ] || ln -s /usr/share/unity-mail/unity-mail-autostart.desktop ~/.config/autostart/unity-mail-autostart.desktop
    echo 'Done.'
    config
# Return
elif [ $INPUT -eq 3 ]; then
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
    echo 'Requires root privileges:'
    sudo apt-get purge 
    echo 'Done.'
    cleanup
# Remove Old Kernel
elif [ $INPUT -eq 2 ]; then
    echo 'Removing old Kernel(s)...'
    echo 'Requires root privileges:'
    sudo dpkg -l 'linux-*' | sed '/^ii/!d;/'"$(uname -r | sed "s/\(.*\)-\([^0-9]\+\)/\1/")"'/d;s/^[^ ]* [^ ]* \([^ ]*\).*/\1/;/[0-9]/!d' | grep -v linux-libc-dev | xargs sudo apt-get -y purge
    echo 'Done.'
    cleanup
# Remove Orphaned Packages
elif [ $INPUT -eq 3 ]; then
    echo 'Removing orphaned packages...'
    echo 'Requires root privileges:'
    sudo apt-get autoremove -y
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
echo '0. Add proposed repository?'
echo '1. Perform system update & upgrade?'
echo '2. Install favourite applications?'
echo '3. Install favourite system tools?'
echo '4. Install some games?'
echo '5. Install development tools?'
echo '6. Install Ubuntu Restricted Extras?'
echo '7. Install third-party applications?'
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
    end
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
