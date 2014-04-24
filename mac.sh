# ➳ Enter lib/header.sh
#
#  _           _        _ _  __           _
# (_)_ __  ___| |_ __ _| | |/ _| ___  ___| |_
# | | '_ \/ __| __/ _` | | | |_ / _ \/ __| __|
# | | | | \__ \ || (_| | | |  _|  __/\__ \ |_
# |_|_| |_|___/\__\__,_|_|_|_|  \___||___/\__|
#
# Installfest Script for development on a Mac
#
# Author: Phillip Lamplugh, GA Instructor (2014)
# Contributions: PJ Hughes, GA Instructor (2014)
#

# Resources
# https://github.com/divio/osx-bootstrap
# https://github.com/paulirish/dotfiles
# https://github.com/mathiasbynens/dotfiles/

# References
# http://www.sudo.ws/
# http://www.gnu.org/software/bash/manual/bashref.html
# http://www.shellcheck.net
# http://explainshell.com/
# ✌ Exeunt lib/header.sh ✌ #

# ➳ Enter lib/dramatis_personae.sh
MINIMUM_OS="10.7.0"
BELOVED_RUBY_VERSION="2.1.0"
# ✌ Exeunt lib/dramatis_personae.sh ✌ #

# ➳ Enter lib/helper_functions.sh
#-------------------------------------------------------------------------------
# Colors
#-------------------------------------------------------------------------------

# Foreground
BLACK=$(tput setaf 0)
BLUE=$(tput setaf 4)
CYAN=$(tput setaf 6)
GREEN=$(tput setaf 2)
MAGENTA=$(tput setaf 5)
ORANGE=$(tput setaf 172)
PURPLE=$(tput setaf 141)
RED=$(tput setaf 1)
WHITE=$(tput setaf 7)
YELLOW=$(tput setaf 226)

# Background
BG_BLACK=$(tput setab 0)
BG_BLUE=$(tput setab 4)
BG_CYAN=$(tput setab 6)
BG_GREEN=$(tput setab 2)
BG_MAGENTA=$(tput setab 5)
BG_ORANGE=$(tput setab 172)
BG_RED=$(tput setab 1)
BG_WHITE=$(tput setab 7)
BG_YELLOW=$(tput setab 226)

# Formatting
UNDERLINE=$(tput smul)
NOUNDERLINE=$(tput rmul)
BOLD=$(tput bold)
RESET=$(tput sgr0)

#-------------------------------------------------------------------------------
# Functions
#-------------------------------------------------------------------------------

# ABRB
function quoth_the_bard () {
  local message=$1
  local attribution=$2
  echo ""
  echo "$YELLOW$message$RESET"
  echo "$PURPLE$attribution$RESET"
}

# upcase error message and exit script
function fie () {
  local message=$(echo $1 | tr 'a-z' 'A-Z')
  echo ""
  echo "$RED$message$RESET"
  exit
}

function pause_awhile () {
   read -p "$* Press Enter to continue"
}

function install_dmg () {
  echo 'Hark, a dmg!'
  file_name="$1"
  MOUNTPOINT="/Volumes/MountPoint"
  IFS="
  "
  hdiutil attach -mountpoint $MOUNTPOINT "$file_name.dmg"
  app=$(find $MOUNTPOINT 2>/dev/null -maxdepth 2 -iname \*.app)
  if [ ! -z "$app" ]; then
    cp -a "$app" /Applications/
  # for app in `find $MOUNTPOINT -type d -maxdepth 2 -name \*.app `; do
  # done
  fi
  echo 'Hark! A pkg!'
  pkg=$(find $MOUNTPOINT 2>/dev/null -maxdepth 2 -iname \*.pkg)
  if [ ! -z "$pkg" ]; then
    # PL: Need to handle harddrive names that aren't Macintosh HD
    sudo installer -package $pkg -target /
  fi
  hdiutil detach $MOUNTPOINT
}

function install_zip () {
  file_name="$1"
  echo 'Hark! A zip!'
  mkdir "$file_name"
  unzip "$file_name.zip" -d "$file_name"
  mv $file_name/*.app /Applications
}

# Checks for the existence of a file
function know_you_not_of () {
  file_name="$1"
  file_count=$(find /Applications -name "$file_name.app" | wc -l)
  if [[ $file_count -gt 0 ]]; then
    echo "$file_name is already here.";
    return 1
  else
    return 0
  fi
}

# Downloads and installs apps from zips, dmgs, and pkgs.
function lend_me_your () {
  file_name="$1"
  url="$2"
  ext=${url: -4}
  if know_you_not_of "$file_name" ; then
    curl -L -o "$file_name$ext" $url
    # enter stage left...
    case "$ext" in
      ".dmg")  install_dmg "$file_name";;
      ".zip")  install_zip "$file_name";;
      *) echo "Not Processed";;
    esac
  fi
  # Out spot
  rm -rf "$file_name$ext"
  rm -rf "$file_name"
}
# ✌ Exeunt lib/helper_functions.sh ✌ #

# ➳ Enter lib/keep_alive.sh
# Capture the user's password
sudo echo "Thanks."

# Update existing `sudo` time stamp until script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# fin
# ✌ Exeunt lib/keep_alive.sh ✌ #

# ➳ Enter lib/mac/commandline_tools.sh
# Determine OS version

osx_version=$(sw_vers -productVersion)
# Force the user to upgrade if they're below 10.7
echo "You're running OSX $osx_version"
if [[ "$osx_version" < "$MINIMUM_OS" ]]; then
  fie "Please upgrade to the latest OS then rerun this script."
fi

# Check that command line tools are installed
case $osx_version in
  *10.9*) cmdline_version="CLTools_Executables" ;; # Mavericks
  *10.8*) cmdline_version="DeveloperToolsCLI"   ;; # Mountain Lion
  *10.7*) cmdline_version="DeveloperToolsCLI"   ;; # Lion
  *) echo "Please upgrade your OS"; exit 1;;
esac

# Check for Command Line Tools based on OS versions
if [ ! -z $(pkgutil --pkgs=com.apple.pkg.$cmdline_version) ]; then
  echo "Command Line Tools are installed";
elif [[ $osx_version < "10.9" ]]; then
  echo "Command Line Tools are not installed"
  echo "Register for a Developer Account"
  echo "Download the Command Lion Tools from"
  echo "https://developer.apple.com/downloads/index.action"
  echo "Then rerun this script"
  exit 1
else
  echo "Command Line Tools are not installed"
  echo "run '$ sudo xcodebuild -license' then"
  echo "'$ xcode-select --install'"
  echo "Then rerun this script."
  exit 1
fi

# fin
# ✌ Exeunt lib/mac/commandline_tools.sh ✌ #

# ➳ Enter lib/mac/remove_macports.sh
# Because we're going to use rbenv and homebrew we need to remove RVM and MacPorts
# This script checks for and removes previous installs of macports and RVM

# Uninstall Macports
# http://guide.macports.org/chunked/installing.macports.uninstalling.html
if hash port 2>/dev/null || [[ $(find /opt/local -iname macports 2>/dev/null) ]]; then
  echo "Removing MacPorts"
    macports=$(find /opt/local -iname macports)
    for f in $macports; do
      rm -rf $f
    done
  # carthago_delenda_est
  sudo port -fp uninstall installed
  sudo rm -rf \
    /opt/local \
    /Applications/DarwinPorts \
    /Applications/MacPorts \
    /Library/LaunchDaemons/org.macports.* \
    /Library/Receipts/DarwinPorts*.pkg \
    /Library/Receipts/MacPorts*.pkg \
    /Library/StartupItems/DarwinPortsStartup \
    /Library/Tcl/darwinports1.0 \
    /Library/Tcl/macports1.0 \
    ~/.macports
    sudo find / | grep macports | sudo xargs rm
else
  echo "Macports is not installed. Moving on..."
fi

# fin
# ✌ Exeunt lib/mac/remove_macports.sh ✌ #

# ➳ Enter lib/remove_rvm.sh
# Because we're going to use rbenv and homebrew we need to remove RVM and MacPorts
# This script checks for and removes previous installs of macports and RVM

# Uninstall RVM
# http://stackoverflow.com/questions/3950260/howto-uninstall-rvm
if hash rvm 2>/dev/null || [ -d ~/.rvm ]; then
  rvm implode
  rm -rf ~/.rvm
  echo "RVM has been removed."
else
  echo "RVM is not installed. Moving on..."
fi

# fin
# ✌ Exeunt lib/remove_rvm.sh ✌ #

# ➳ Enter lib/mac/hygene.sh
# Check for recommended software updates
sudo softwareupdate -i -r --ignore iTunes

# Ensure user has full control over their folder
sudo chown -R ${USER} ~

# Repair disk permission
diskutil repairPermissions /

# fin
# ✌ Exeunt lib/mac/hygene.sh ✌ #

# ➳ Enter lib/configure_ssh_keys.sh
# SSH keys establish a secure connection between your computer and GitHub
# This script follows these instructions
# `https://help.github.com/articles/generating-ssh-keys`

# SSH Keygen
ssh-keygen -t rsa -C $github_email
ssh-add id_rsa

# Copy SSH key to the clipboard
pbcopy < ~/.ssh/id_rsa.pub

echo "We just copied your SSH key to the clipboard."
echo "Now we're going to visit GitHub to add the SSH key"

echo "Do the following in your browser: "
echo '- Click "SSH Keys" in the left sidebar'
echo '- Click "Add SSH key"'
echo '- Paste your key into the "Key" field'
echo '- Click "Add key"'
echo '- Confirm the action by entering your GitHub password'

pause_awhile "We'll be here until you get back from Github. Ready?"

open https://github.com/settings/ssh

pause_awhile "SSH keys added?"
# ✌ Exeunt lib/configure_ssh_keys.sh ✌ #

# ➳ Enter lib/get_user_info.sh
echo "If you haven't already done so,"
echo "please register for an account on github.com"

read -p "Enter your full name: "  user_name
read -p "Github Username: "       github_name
read -p "Github Email: "          github_email

# fin
# ✌ Exeunt lib/get_user_info.sh ✌ #

# ➳ Enter lib/repo_setup.sh
SRC_DIR=~/.wdi-installfest
SCRIPTS=$SRC_DIR/scripts
SETTINGS=$SRC_DIR/settings
INSTALL_REPO=https://github.com/ga-instructors/installfest_script.git

# download the repo for the absolute paths
if [[ ! -d $SRC_DIR ]]; then
  echo 'Downloading Installfest repo...'
  # autoupdate bootstrap file
  git clone $INSTALL_REPO $SRC_DIR
  # hide folder
  chflags hidden $SRC_DIR
else
  # update repo
  echo 'Updating repo...'
  cd $SRC_DIR
  git pull origin master
fi

# fin
# ✌ Exeunt lib/repo_setup.sh ✌ #

# ➳ Enter lib/mac/homebrew.sh
# Installs Homebrew, our package manager
# http://brew.sh/

$(which -s brew)
if [[ $? != 0 ]]; then
  echo 'Installing Homebrew...'
  ruby -e "$(curl -fsSL https://raw.github.com/mxcl/homebrew/go/install)"
fi

# Make sure we're using the latest Homebrew
brew update

# fin
# ✌ Exeunt lib/mac/homebrew.sh ✌ #

# ➳ Enter lib/mac/compilers.sh
# Upgrade any already-installed formulae
brew upgrade

# These formulae duplicate software provided by OS X
# though may provide more recent or bugfix versions.
brew tap homebrew/dupes

# Autoconf is an extensible package of M4 macros that produce shell scripts to automatically configure software source code packages.
brew install autoconf

# Automake is a tool for automatically generating Makefile.in
brew install automake

# generic library support script
brew install libtool

# a YAML 1.1 parser and emitter
brew install libyaml

# neon is an HTTP and WebDAV client library
brew install neon

# A toolkit implementing SSL v2/v3 and TLS protocols with full-strength cryptography world-wide.
brew install openssl

# pkg-config is a helper tool used when compiling applications and libraries.
brew install pkg-config

# a self-contained, serverless, zero-configuration, transactional SQL database engine.
brew install sqlite

# a script that uses ssh to log into a remote machine
brew install ssh-copy-id

# XML C parser and toolkit
brew install libxml2

# a language for transforming XML documents into other XML documents.
brew install libxslt

# a conversion library between Unicode and traditional encoding
brew install libiconv

# generates an index file of names found in source files of various programming languages.
brew install ctags

# Tap a new formula repository from GitHub, or list existing taps.
brew tap homebrew/versions

# Ensures all tapped formula are symlinked into Library/Formula
# and prunes dead formula from Library/Formula.
brew tap --repair

# Remove outdated versions from the cellar
brew cleanup
# ✌ Exeunt lib/mac/compilers.sh ✌ #

# ➳ Enter lib/mac/git.sh
# Version Control
brew install git

# additional git commands
brew install hub

# fin
# ✌ Exeunt lib/mac/git.sh ✌ #

# ➳ Enter lib/configure_git.sh
# Add user's github info to gitconfig
git config --global user.name  $github_name
git config --global user.email $github_email

# color
git config --global color.ui always

# set editor
git config --global core.editor subl -w

# default branch to push to
git config --global push.default current
# ✌ Exeunt lib/configure_git.sh ✌ #

# ➳ Enter lib/mac/rbenv.sh
# Our Ruby version manager
brew install rbenv

# Automatically runs rbenv rehash every time you install or uninstall a gem.
brew install rbenv-gem-rehash

# Provides an `rbenv install` command
brew install ruby-build

# enable shims and autocompletion
eval "$(rbenv init -)"

# Automatically install gems every time you install a new version of Ruby
brew install rbenv-default-gems

# Add to path
export PATH="$HOME/.rbenv/bin:$PATH"
# ✌ Exeunt lib/mac/rbenv.sh ✌ #

# ➳ Enter lib/ruby-env.sh
# Our Ruby Environment

ruby_check=$(rbenv versions | grep $BELOVED_RUBY_VERSION)

if [[ "$ruby_check" == *$BELOVED_RUBY_VERSION* ]]; then
  echo "$BELOVED_RUBY_VERSION is installed"
else
  rbenv install "$BELOVED_RUBY_VERSION"
fi

# Set global Ruby
rbenv global $BELOVED_RUBY_VERSION

# Reload
rbenv rehash

gem update --system

gem install bundler --no-document --pre

# fin #
# ✌ Exeunt lib/ruby-env.sh ✌ #

# ➳ Enter lib/default-gems.sh
# Our gems to install

# Maintains a consistent environment for ruby applications.
gem install bundler

# Acceptance test framework for web applications
gem install capybara

# handle events on file system modifications
gem install guard

# JavaScript testing
gem install jasmine

# ruby interface for Postgres
gem install pg

# alternative to the standard IRB shell
gem install pry

# full stack, Web application framework
gem install rails

# testing tool for Ruby
gem install rspec

# a DSL for quickly creating web applications in Ruby
gem install sinatra

# common Sinatra extensions
gem install sinatra-contrib

# fin #
# ✌ Exeunt lib/default-gems.sh ✌ #

# ➳ Enter lib/mac/packages.sh
# Useful packages
# ASCII ART!!!!
brew install figlet

# visualization tool for ERDs
brew install graphviz

# image resizing
brew install imagemagick

# PhantomJS is a headless WebKit scriptable with a JavaScript API.
brew install phantomjs

# WebKit implementation of qt for Capybara testing
brew install qt

# qt for mavericks
brew install qt4

# Advanced in-memory key-value store that persists on disk
brew install redis

# fin
# ✌ Exeunt lib/mac/packages.sh ✌ #

# ➳ Enter lib/mac/apps.sh
# a CLI workflow for the administration of Mac applications
# distributed as binaries
brew tap phinze/homebrew-cask
brew install brew-cask

# Instant search documentation offlien
brew cask install dash

# The Browser
brew cask install google-chrome

# A Browser
brew cask install firefox

# The Chat Client
brew cask install hipchat

# The Window Manager
brew cask install spectacle

# The Text Editor, Sublime Text 2
brew cask install sublime-text

# The X Window Server
brew cask install xquartz

# Markdown Editor
brew cask install mou

# fin
# ✌ Exeunt lib/mac/apps.sh ✌ #

# ➳ Enter lib/mac/heroku.sh
#  _                    _
# | |__   ___ _ __ ___ | | ___   _
# | '_ \ / _ \ '__/ _ \| |/ / | | |
# | | | |  __/ | | (_) |   <| |_| |
# |_| |_|\___|_|  \___/|_|\_\\__,_|
# https://devcenter.heroku.com/articles/keys

echo "Heroku is a cloud platform as a service (PaaS) supporting several"
echo "programming languages."

# Heroku command-line tooling for working with the Heroku platform
brew install heroku-toolbelt

echo "If you don’t already use SSH, you’ll need to create a public/private key"
echo "pair to deploy code to Heroku. This keypair is used for the strong"
echo "cryptography and that uniquely identifies you as a developer when pushing"
echo "code changes."

ssh-keygen -t rsa

echo "The first time you run the heroku command, you’ll be prompted for your "
echo "credentials. Your public key will then be automatically uploaded to"
echo "Heroku. This will allow you to deploy code to all of your apps."

heroku keys:add
# ✌ Exeunt lib/mac/heroku.sh ✌ #

# ➳ Enter lib/mac/postgres.sh
# Set up Postgres

# open source object-relational database management system
brew install postgres

# Create a database
initdb /usr/local/var/postgres -E utf8
createdb ${USER}

# Ensure that Postgres launches whenever we login

# # http://robots.thoughtbot.com/starting-and-stopping-background-services-with-homebrew
brew services start postgres
# mkdir -p ~/Library/LaunchAgents
# cp /usr/local/Cellar/postgresql/9.*/homebrew.mxcl.postgresql.plist ~/Library/LaunchAgents/
# # Start Postgres now
# launchctl load ~/Library/LaunchAgents/homebrew.mxcl.postgresql.plist

# ✌ Exeunt lib/mac/postgres.sh ✌ #

# ➳ Enter lib/mac/node.sh
# Event-driven I/O server-side JavaScript environment based on V8
brew install node
# Adds history for node repl
brew install readline

# fin
# ✌ Exeunt lib/mac/node.sh ✌ #

# ➳ Enter lib/chrome_extensions.sh
# https://developer.chrome.com/extensions/external_extensions.html

# Useful Extensions

# Open chrome extensions in the browser
chrome_ext () {
  app=$1
  webstore=https://chrome.google.com/webstore/detail/
  open "$webstore$app"
}

echo "Now we're going to open some Chrome extensions to install from the Chrome Webstore"
echo "Just click 'Free' to install them."
echo "If you've alread installed them you'll see 'Added to Chrome'"
echo "Ready?"
read -p "Just hit enter!"

# Validate and view JSON documents
chrome_ext jsonview/chklaanhfefbnpoihckbnefhakgolnmc

# Integration with LiveReload App and guard-livereload
chrome_ext livereload/jnihajbhpnppcggbcgedagnkighmdlei

# analyzes the performance of web pages and provides suggestions to make them faster
chrome_ext pagespeed-insights-by-goo/gplegfbjlmmehdoakndmohflojccocli

# REST Client to test in Browser
chrome_ext postman-rest-client/fdmmgilgnpjigdojojpjoooidkmcomcm

# helps you identify and fix performance problems in your web application
chrome_ext speed-tracer-by-google/ognampngfcbddbfemdapefohjiobgbdl

# fin #
# ✌ Exeunt lib/chrome_extensions.sh ✌ #

# ➳ Enter lib/mac/dotfiles.sh
# Create a folder for backed up files
mkdir -p "${HOME}/.dotfiles_backup"

# Dotfiles we'll be using
dotfiles="gitconfig gitignore_global bash_profile bashrc gemrc pryrc rspec irbrc"

for file in $dotfiles; do
  if [ -a "${HOME}/${file}" ]; then
    # move file
    mv "${HOME}/${file}" "${HOME}/.dotfiles_backup/${file}"
    # symlink file
    ln -s "$SETTINGS/dotfiles/${file}" "${HOME}/${file}"
  fi
done

# fin
# ✌ Exeunt lib/mac/dotfiles.sh ✌ #
