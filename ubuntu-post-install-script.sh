#!/bin/bash
# -*- Mode: sh; coding: utf-8; indent-tabs-mode: nil; tab-width: 4 -*-
#
# Authors:
#   Sam Hewitt <hewittsamuel@gmail.com>
#	Jason Robinson <jaywink@basshero.org>
#
# Description:
#   A post-installation bash script for Ubuntu (13.xx)
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
echo '#-------------------------------------------------#'
echo '#     Ubuntu 13.xx-14.04 Post-Install Script      #'
echo '#-------------------------------------------------#'

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
if [ $REPLY == 'y' ]; then
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
echo 'Requires root privileges:'
echo 'Adding PPA for: my-weather-indicator'
sudo add-apt-repository -y ppa:atareao/atareao
echo 'Adding PPA for: y-ppa-manager'
sudo add-apt-repository -y ppa:webupd8team/y-ppa-manager
echo 'Adding webupd8 PPA'
sudo add-apt-repository -y ppa:nilarimogard/webupd8
echo 'Adding PPA for: GIMP'
sudo add-apt-repository -y ppa:otto-kesselgulasch/gimp
echo 'Adding PPA for: Ubuntu Tweak'
sudo add-apt-repository -y ppa:ubuntu-tweak-testing/ppa
echo 'Adding PPA for: Diodon'
sudo add-apt-repository -y ppa:diodon-team/daily
echo 'Adding PPA for: Variety'
sudo add-apt-repository -y ppa:peterlevi/ppa
echo 'Adding PPA for SimpleScreenRecorder'
sudo add-apt-repository -y ppa:maarten-baert/simplescreenrecorder
echo 'Adding PPA for Handbrake'
sudo add-apt-repository -y ppa:stebbins/handbrake-snapshots
echo 'Adding PPA for Pinta'
sudo add-apt-repository -y ppa:pinta-maintainers/pinta-stable
echo 'Adding Kubuntu backports PPA'
sudo add-apt-repository -y ppa:kubuntu-ppa/backports
echo 'Adding Clementine stable PPA'
sudo add-apt-repository -y ppa:me-davidsansome/clementine
# Caffeine
sudo add-apt-repository -y ppa:jaywink/caffeine
echo 'Adding ownCloud repo'
sudo sh -c "echo 'deb http://download.opensuse.org/repositories/isv:/ownCloud:/desktop/xUbuntu_14.10/ /' >> /etc/apt/sources.list.d/owncloud-client.list"
wget http://download.opensuse.org/repositories/isv:ownCloud:desktop/xUbuntu_14.10/Release.key -O /tmp/owncloud.key
sudo apt-key add - < /tmp/owncloud.key
sudo apt-get update -qq
echo 'Installing selected favourite applications...'
sudo apt-get install gimp gimp-plugin-registry gimp-data-extras xchat terminator digikam digikam-doc keepassx chromium-browser calibre qbittorrent shutter diodon indicator-multiload y-ppa-manager compizconfig-settings-manager compiz-plugins-extra thunderbird xul-ext-lightning vlc ubuntu-tweak variety pidgin pidgin-plugin-pack pidgin-libnotify minitube clementine simplescreenrecorder owncloud-client handbrake-gtk handbrake-cli asunder pinta krita caffeine unity-tweak-tool
# Pidgin configuration
echo "Setting Pidgin settings..."
#quieten signon notifs
sed --in-place "s|<pref name='signon' type='bool' value='1'/>|<pref name='signon' type='bool' value='0'/>|" ~/.purple/prefs.xml
#quieten some sounds
sed --in-place "s|<pref name='login' type='bool' value='1'/>|<pref name='login' type='bool' value='0'/>|" ~/.purple/prefs.xml
sed --in-place "s|<pref name='logout' type='bool' value='1'/>|<pref name='logout' type='bool' value='0'/>|" ~/.purple/prefs.xml
sed --in-place "s|<pref name='send_im' type='bool' value='1'/>|<pref name='send_im' type='bool' value='0'/>|" ~/.purple/prefs.xml
echo 'Make some installed apps startup automatically.'
if [[ ! -d $HOME/.config/autostart ]]; then
    mkdir -p $HOME/.config/autostart
fi
echo 'Pidgin...'
[ -e /usr/share/applications/pidgin.desktop ] && [ -e ~/.config/autostart/pidgin.desktop ] || ln -s /usr/share/applications/pidgin.desktop ~/.config/autostart/pidgin.desktop
echo 'Indicator Multiload...'
[ -e /usr/share/applications/indicator-multiload.desktop ] && [ -e ~/.config/autostart/indicator-multiload.desktop ] || ln -s /usr/share/applications/indicator-multiload.desktop ~/.config/autostart/indicator-multiload.desktop
echo 'qBittorrent...'
[ -e /usr/share/applications/qBittorrent.desktop ] && [ -e ~/.config/autostart/qbittorrent.desktop ] || ln -s /usr/share/applications/qBittorrent.desktop ~/.config/autostart/qbittorrent.desktop
echo 'Shutter...'
[ -e /usr/share/applications/shutter.desktop ] && [ -e ~/.config/autostart/shutter.desktop ] || ln -s /usr/share/applications/shutter.desktop ~/.config/autostart/shutter.desktop
sed --in-place "s|Exec=shutter %F|Exec=shutter --min_at_startup %F|" ~/.config/autostart/shutter.desktop
# terminator config
echo 'Symlink Terminator config..'
if [[ ! -d $HOME/.config/terminator ]]; then
    mkdir -p $HOME/.config/terminator
fi
rm -f $HOME/.config/terminator/config
ln -s "$HOME/ownCloud/config/terminator/config" $HOME/.config/terminator/config
# clementine config
echo 'Symlink Clementine config and db..'
if [[ ! -d $HOME/.config/Clementine ]]; then
    mkdir -p $HOME/.config/Clementine
fi
rm -f $HOME/.config/Clementine/Clementine.conf
ln -s "$HOME/ownCloud/config/clementine/Clementine.conf" $HOME/.config/Clementine/Clementine.conf
# variety config
echo 'Symlink Variety configs and favourites..'
if [[ ! -d $HOME/.config/variety ]]; then
    mkdir -p $HOME/.config/variety
fi
rm -f $HOME/.config/variety/banned.txt $HOME/.config/variety/variety.conf
rm -rf $HOME/.config/variety/Favorites
ln -s "$HOME/ownCloud/config/variety/banned.txt" $HOME/.config/variety/banned.txt
ln -s "$HOME/ownCloud/config/variety/variety.conf" $HOME/.config/variety/variety.conf
ln -s "$HOME/ownCloud/config/variety/Favorites" $HOME/.config/variety/Favorites
# shutter config
echo 'Symlink Shutter configs..'
if [[ ! -d $HOME/.shutter ]]; then
    mkdir -p $HOME/.shutter
fi
rm -f $HOME/.shutter/accounts.xml $HOME/.shutter/settings.xml
ln -s "$HOME/ownCloud/config/shutter/accounts.xml" $HOME/.shutter/accounts.xml
ln -s "$HOME/ownCloud/config/shutter/settings.xml" $HOME/.shutter/settings.xml
# xchat2 config
echo 'Symlink XChat2 config..'
if [[ ! -d $HOME/.xchat2 ]]; then
    mkdir -p $HOME/.xchat2
fi
rm -f $HOME/.xchat2/servlist_.conf $HOME/.xchat2/xchat.conf
ln -s "$HOME/ownCloud/config/xchat/servlist_.conf" $HOME/.xchat2/servlist_.conf
ln -s "$HOME/ownCloud/config/xchat/xchat.conf" $HOME/.xchat2/xchat.conf
# digikam config
echo 'Symlink digiKam config..'
if [[ ! -d $HOME/.kde/share/config ]]; then
    mkdir -p $HOME/.kde/share/config
fi
if [[ ! -d $HOME/.kde/apps/digikam ]]; then
    mkdir -p $HOME/.kde/apps/digikam
fi
rm -f $HOME/.kde/share/config/digikamrc $HOME/.kde/apps/digikam/digikamui.rc
ln -s "$HOME/ownCloud/config/digikam/digikamrc" $HOME/.kde/share/config/digikamrc
ln -s "$HOME/ownCloud/config/digikam/digikamui.rc" $HOME/.kde/apps/digikam/digikamui.rc
# qbittorrent config
echo 'Symlink qBittorrent config..'
if [[ ! -d $HOME/.config/qBittorrent ]]; then
    mkdir -p $HOME/.config/qBittorrent
fi
rm -f $HOME/.config/qBittorrent/qBittorrent.conf
ln -s "$HOME/ownCloud/config/qbittorrent/qBittorrent.conf" $HOME/.config/qBittorrent/qBittorrent.conf
# vim config
echo 'Symlink vim config..'
rm -f $HOME/.vimrc
ln -s "$HOME/ownCloud/config/vim/vimrc" $HOME/.vimrc
echo 'Done.'
main
}

# INSTALL SYSTEM TOOLS
function toolinstall {
echo 'Adding PPA for solaar..'
sudo apt-add-repository -y ppa:daniel.pavel/solaar
sudo apt-get update -qq
echo 'Installing system tools...'
sudo apt-get install htop curl virtualbox software-properties-common wifi-radar vim clusterssh solaar nfs-common gnome-web-photo feh logstalgia soundconverter autossh
echo 'Done.'
main
}

# INSTALL GAMES
function gamesinstall {
echo 'Requires root privileges:'
echo 'Installing games...'
sudo apt-get install gcompris gcompris-sound-fi supertuxkart tuxpaint tuxpaint-config freeciv-client-gtk steam
# terminator config
echo 'Symlink TuxPaint config..'
rm -f $HOME/.tuxpaintrc
ln -s "$HOME/ownCloud/config/tuxpaint/.tuxpaintrc" $HOME/.tuxpaintrc
echo 'Done.'
main
}

# INSTALL MULTIMEDIA CODECS
function codecinstall {
# Install Ubuntu Restricted Extras Applications
echo 'Installing Ubuntu Restricted Extras...'
echo 'Requires root privileges:'
sudo apt-get install ubuntu-restricted-extras
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
echo '2. Install Mozilla Addon SDK?'
echo '3. Install Ubuntu Phablet Tools?'
echo '0. Return'
echo ''
read INPUT
# Install Development Tools
if [ $INPUT -eq 1 ]; then
    echo 'Requires root privileges:'
    echo 'Adding PPA for: Node.js'
    sudo add-apt-repository -y ppa:chris-lea/node.js
    echo 'Adding PPA for: Juju'
    sudo add-apt-repository -y ppa:juju/stable
    echo 'Adding repository for MariaDB'
    sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
    sudo add-apt-repository "deb http://mirror.netinch.com/pub/mariadb/repo/10.0/ubuntu `lsb_release -sc` main"
    echo 'Adding PPA for: Atom'
    sudo add-apt-repository -y ppa:webupd8team/atom
    sudo apt-get update -qq
    echo 'Installing development tools...'
    # mongodb-server,lxc for juju
    sudo apt-get install bzr devscripts git python3-distutils-extra ruby build-essential meld mysql-workbench nodejs ipython ipython-doc juju-core juju-local amulet charm-tools mongodb-server lxc python-setuptools python-dev giggle golang-go debhelper dpkg-dev pbuilder mariadb-server libmariadbclient-dev atom
    # required to compile python-mysql using pip
    sudo apt-get install -y libssl-dev libcrypto++-dev
    echo 'Install some Node modules...'
    sudo npm install -g bower
    echo 'Installing some extra Python stuff...'
    sudo easy_install pip
    sudo pip install pip-tools
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
    echo 'Some dependencies first..'
    sudo apt-get install -y libz-dev libbz2-dev libreadline-dev libsqlite3-dev libncurses5-dev libgdbm-dev
    curl -kL https://raw.github.com/saghul/pythonz/master/pythonz-install | bash
    # Git
    echo 'Symlink git config...'
    # git config
    rm -f $HOME/.gitconfig
    ln -s "$HOME/ownCloud/config/git/gitconfig" $HOME/.gitconfig
    # Bazaar
    echo 'Symlink bazaar configs...'
    if [[ ! -d $HOME/.bazaar ]]; then
        mkdir -p $HOME/.bazaar
    fi
    rm -f $HOME/.bazaar/authentication.conf $HOME/.bazaar/bazaar.conf
    ln -s "$HOME/ownCloud/config/bazaar/authentication.conf" $HOME/.bazaar/authentication.conf
    ln -s "$HOME/ownCloud/config/bazaar/bazaar.conf" $HOME/.bazaar/bazaar.conf
    # make sure nothing created a possibly non-existing tmp as root :P
    MYNAME=`whoami`
    sudo chown $MYNAME: /home/$MYNAME/tmp
    # Charmhelpers
    echo 'Charmhelpers & charm_helpers_sync tool'
    cd $HOME/workspace
    bzr branch lp:charm-helpers
    sudo ln -s /home/$MYNAME/workspace/charm-helpers/tools/charm_helpers_sync/charm_helpers_sync.py /usr/local/bin/charm_helpers_sync.py 
    echo 'Done.'
    devinstall
# Mozilla Addon SDK
elif [ $INPUT -eq 2 ]; then
    echo 'Installing Mozilla Addon SDK..'
    cd $HOME/workspace
    wget https://ftp.mozilla.org/pub/mozilla.org/labs/jetpack/jetpack-sdk-latest.zip -O jetpack-sdk-latest.zip
    unzip jetpack-sdk-latest.zip
    rm -f jetpack-sdk-latest.zip
    sed --in-place "s|<em:maxVersion>20.*</em:maxVersion>|<em:maxVersion>27.*</em:maxVersion>|" addon-sdk-1.14/app-extension/install.rdf
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
    sudo apt-get install phablet-tools android-tools-adb android-tools-fastboot
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

# THIRD PARTY APPLICATIONS
function thirdparty {
INPUT=0
echo ''
echo 'What would you like to do? (Enter the number of your choice)'
echo ''
while [ true ]
do
echo '2. Install Google Talk Plugin?'
echo '5. Install DVD playback tools?'
echo '6. Install EasyShutdown?'
echo '9. Install Sublime Text?'
echo '0. Return'
echo ''
read INPUT
# Empty
if [ $INPUT -eq 1 ]; then
    echo 'Done.'
    thirdparty
# Google Talk Plugin
elif [ $INPUT -eq 2 ]; then
    echo 'Downloading Google Talk Plugin...'
    # Make tmp directory
    if [ ! -d $HOME/tmp ]; then
        mkdir -p $HOME/tmp
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
    rm -f google-talkplugin_current*
    cd
    echo 'Done.'
    thirdparty
# Empty
elif [ $INPUT -eq 3 ]; then
    echo 'Done.'
    thirdparty
# Empty
elif [ $INPUT -eq 4 ]; then
    echo 'Done.'
    thirdparty
# Medibuntu
elif [ $INPUT -eq 5 ]; then
    echo 'Installing libdvdread4...'
    sudo apt-get install -y libdvdread4
    sudo /usr/share/doc/libdvdread4/install-css.sh
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
# Empty
elif [ $INPUT -eq 7 ]; then
    echo 'Done.'
    thirdparty
# Empty
elif [ $INPUT -eq 8 ]; then
    echo 'Done.'
    thirdparty
# Sublime Text
elif [ $INPUT -eq 9 ]; then
    echo 'Installing Sublime Text...'
    echo 'Requires root privileges:'
    wget http://c758482.r82.cf2.rackcdn.com/sublime-text_build-3059_amd64.deb -O /tmp/sublime-text_build-3059_amd64.deb
    sudo dpkg -i /tmp/sublime-text_build-3059_amd64.deb
    rm -f /tmp/sublime-text_build-3059_amd64.deb
    # symlink to own U1 user directory
    if [[ ! -d $HOME/.config/sublime-text-3/Packages ]]; then
        mkdir -p $HOME/.config/sublime-text-3/Packages
    fi
    if [[ -d $HOME/.config/sublime-text-3/Packages/User ]]; then
        rm -rf $HOME/.config/sublime-text-3/Packages/User
    fi
    ln -s "$HOME/ownCloud/config/sublimetext/User" $HOME/.config/sublime-text-3/Packages/User
    # install some packages from git
    cd $HOME/.config/sublime-text-3/Packages
    git clone https://github.com/wbond/sublime_package_control.git "Package Control"
    git clone git://github.com/jisaacks/GitGutter.git
    # Set default applications for mimetypes
    echo "Setting default applications for certain mimetypes..."
    DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    cd $DIR
    python configure_default_app.py "text/html" sublime_text.desktop
    python configure_default_app.py "application/x-php" sublime_text.desktop
    python configure_default_app.py "application/javascript" sublime_text.desktop
    python configure_default_app.py "text/plain" sublime_text.desktop
    python configure_default_app.py "application/xml" sublime_text.desktop
    python configure_default_app.py "text/x-sql" sublime_text.desktop
    python configure_default_app.py "text/css" sublime_text.desktop
    python configure_default_app.py "application/xhtml+xml" sublime_text.desktop
    python configure_default_app.py "application/x-extension-xhtml" sublime_text.desktop
    python configure_default_app.py "text/x-python" sublime_text.desktop
    cd
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
echo '1. Set some generic application and environment settings?'
echo '2. Set auto start of applications?'
echo '3. Set some bash aliases and settings?'
echo '4. Link to network drives?'
echo '0. Return'
echo ''
read INPUT
# App and env settings
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
    # Set Unity launcher shortcuts
    echo "Setting Unity launcher shortcuts..."
    gsettings set com.canonical.Unity.Launcher favorites "['application://firefox.desktop', 'application://sublime_text.desktop', 'application://terminator.desktop', 'application://thunderbird.desktop', 'application://nautilus.desktop', 'application://xchat.desktop', 'application://clementine.desktop', 'application://kde4-digikam.desktop', 'application://minitube.desktop', 'application://keepassx.desktop', 'application://chromium-browser.desktop', 'application://gufw.desktop', 'application://MySQLWorkbench.desktop', 'unity://running-apps', 'unity://expo-icon', 'unity://devices']"
    # SSH
    if [[ ! -d $HOME/.ssh ]]; then
        mkdir $HOME/.ssh
    fi
    rm -f $HOME/.ssh/config $HOME/.ssh/id_rsa $HOME/.ssh/id_rsa.pub
    ln -s "$HOME/ownCloud/config/ssh/config" $HOME/.ssh/config
    ln -s "$HOME/ownCloud/config/ssh/id_rsa" $HOME/.ssh/id_rsa
    ln -s "$HOME/ownCloud/config/ssh/id_rsa.pub" $HOME/.ssh/id_rsa.pub
    # Language and locale
    sudo apt-get install kde-l10n-engb libreoffice-help-en-gb libreoffice-l10n-en-gb gimp-help-en thunderbird-locale-en-gb libreoffice-lightproof-en
    sudo sed --in-place "s|LANG=\"en_US.UTF-8\"|LANG=\"en_GB.UTF-8\"|" /etc/default/locale
    sudo sed --in-place "s|LC_TIME=\"fi_FI.UTF-8\"|LC_TIME=\"en_GB.UTF-8\"|" /etc/default/locale
    # Disable screen lock after timeout
    gsettings set org.gnome.desktop.screensaver lock-enabled false
    # Set Unity launcher icon size to 32
    gsettings set org.compiz.unityshell:/org/compiz/profiles/unity/plugins/unityshell/ icon-size 32
    # Custom touchpad settings (3 finger middle-click)
    gsettings set org.gnome.settings-daemon.peripherals.input-devices hotplug-command "$HOME/ownCloud/config/touchpad/settings.sh"
    config
# Startup Applications
elif [ $INPUT -eq 2 ]; then
    echo 'Changing display of startup applications.'
    echo 'Requires root privileges:'    
    cd /etc/xdg/autostart/ && sudo sed --in-place 's/NoDisplay=true/NoDisplay=false/g' *.desktop
    cd
    echo 'Done.'
    config
# Bash aliases and settings
elif [ $INPUT -eq 3 ]; then
    echo 'Setting some bash aliases and settings..'
    if [[ `cat $HOME/.bashrc | grep additionalrc | wc -l` -eq 0 ]]; then
        echo 'source "$HOME/ownCloud/config/bash/additionalrc"' >> $HOME/.bashrc
    fi
    echo 'Done.'
    config
# Link to network drives
elif [ $INPUT -eq 4 ]; then
    sudo apt-get install -y nfs-common
    # create /backup folder
    if [[ ! -d /backup ]]; then
        sudo mkdir /backup
        WHOAMI=`whoami`
        sudo chown $WHOAMI: /backup
    fi
    # mount backup folder
    if [[ `cat /etc/fstab | grep backup | wc -l` -eq 0 ]]; then
        echo '192.168.1.42:/c/backup  /backup       nfs rw,auto,bg,intr,soft,user 0 0' | sudo tee -a /etc/fstab
    fi
    # create /lmedia folder
    if [[ ! -d /lmedia ]]; then
        sudo mkdir /lmedia
        WHOAMI=`whoami`
        sudo chown $WHOAMI: /lmedia
    fi
    # mount lmedia folder
    if [[ `cat /etc/fstab | grep lmedia | wc -l` -eq 0 ]]; then
        echo '192.168.1.42:/c/media  /lmedia        nfs rw,auto,bg,intr,soft,user 0 0' | sudo tee -a /etc/fstab
    fi
    # create /extras folder
    if [[ ! -d /extras ]]; then
        sudo mkdir /extras
        WHOAMI=`whoami`
        sudo chown $WHOAMI: /extras
    fi
    # mount extras folder
    if [[ `cat /etc/fstab | grep bigboy | wc -l` -eq 0 ]]; then
        echo '192.168.1.42:/c/bigboy  /extras        nfs rw,auto,bg,intr,soft,user 0 0' | sudo tee -a /etc/fstab
    fi
    sudo mount -a
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
    echo 'Requires root privileges:'
    sudo apt-get purge empathy rhythmbox
    echo 'Done.'
    cleanup
# Remove Old Kernel
elif [ $INPUT -eq 2 ]; then
    echo 'Removing old Kernel(s)...'
    dpkg -l 'linux-*' | sed '/^ii/!d;/'"$(uname -r | sed "s/\(.*\)-\([^0-9]\+\)/\1/")"'/d;s/^[^ ]* [^ ]* \([^ ]*\).*/\1/;/[0-9]/!d' | grep -v linux-libc-dev
    echo 'Do you want to continue? (y to continue)'
    read OK
    if [ $OK == "y" ]; then
        sudo dpkg -l 'linux-*' | sed '/^ii/!d;/'"$(uname -r | sed "s/\(.*\)-\([^0-9]\+\)/\1/")"'/d;s/^[^ ]* [^ ]* \([^ ]*\).*/\1/;/[0-9]/!d' | grep -v linux-libc-dev | xargs sudo apt-get -y purge
        echo 'Done.'
    fi
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
