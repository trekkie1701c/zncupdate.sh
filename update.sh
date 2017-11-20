#!/bin/bash

# Update the base system
echo "Updating the base system"
sudo apt update
#sudo apt upgrade -y #Uncomment if you want to just upgrade
sudo apt dist-upgrade -y #Comment if you don't want dist-upgrade
sudo apt autoremove -y
sudo apt clean
# Cleaning up anything left over from the last install
echo "Removing anything that might be left over from the last installation.  It's okay if there's an error here."
rm -rf znc-*
# Fetching the latest version of ZNC
# There's two ways of doing this. We can get the latest stable
# version from a tarball with wget
# Or we can compile the latest build using a git pull/clone
# However this may have bugs, as it's not a release version
# By default this script will use wget for the stable version
# But you can uncomment the git section to get the latest build
###Begin wget specific code###
echo "Fetching the latest version of ZNC via wget."
wget https://znc.in/releases/znc-latest.tar.gz
# This tar file will extract to znc-version.  We need to know what version is
# so we're copying a list of files to znc.ver
echo "Prepping to build."
tar tf znc-latest.tar.gz > znc.ver
# However, we only really need the first listing, which is the znc-version directory.
# So we'll truncate the file here to just the first line
sed -i '2,$ d' znc.ver
# Now we'll read the file to set the working directory to znc-version
dir=($(cat znc.ver))
# And extract the tar file
tar xvf znc-latest.tar.gz
###Begin Git Specific Code###
## Set the working directory
#dir=znc
## And run a clone command to get the latest code
#echo "Fetching the latest version of ZNC via git."
#echo "No 'gitting' jokes, please."
#git clone git://github.com/znc/znc.git --recursive
##There's no ./configure script, so we'll need to make one
#echo "Prepping to build"
#cd ~/"$dir"
#./bootstrap.sh
#cd ~
###End Git Specific Code###
# I use the "Simple Disconnect" plugin for a server that dislikes idling.
# Let's get that now.
# If you have other optiknal modules,this 8s a good place to add code to get them.
echo "Fetching optional modules."
wget https://gist.githubusercontent.com/maxpowa/57e5d6fb3afb944671f5/raw/8158ec1e4325c5d04078ff77143f7ca5bdd8ed67/simple_disconnect.cpp
# And move it to the modules directory so it's built with the rest of the
# program.
cp simple_disconnect.cpp ~/"$dir"modules/simple_disconnect.cpp
# Next, we need to change to the working directory.
echo "Begining Build"
cd ~/"$dir"
# Let's make sure the environment is clean
make clean
# And configure ZNC.  If you want other options, change this command.
./configure --enable-tcl
# And build it.
make
# Next, we need to stop the ZNC service if it's running as one.
# But, we do want to notify the users.  You'll want to set irssi to connect
# via an account which has broadcast rights
# The new lines are intentional, as they're required to send the message
# If you use screen for other things, you'll need to do some more config here.
# Start irssi in the background with screen
echo "Attempting to start irssi to notify the bouncer that things are happening..."
screen -d -m irssi
# Wait a few seconds just in case it takes a moment to connect
# Comment this out or change the sleep command to change this
echo "Waiting a few seconds to make sure irssi connects properly..."
sleep 10
#Start a countdown.  Set timer to however many minutes you want to give them.
timer=5
echo "Attempting to run timer.  If this errors out, ZNC is about to restart with no notice.  Oops."
while [ $timer -gt 1 ]
	do
	#Telling irssi to broadcast.  Do not indent the stray quote
	#Or remove it.  We need the newline to cause the message to be sent
	screen -X stuff "/query *status broadcast The Server is shutting down for a brief maintenance in $timer minutes!
"
	echo "ZNC shutdown in $timer minutes!"
	# Sleep for a minute.
	sleep 60
	# Take 1 off the counter
	let timer=timer-1
done
# One minute to shutdown! I could probably handle this more elegantly, but hey, it works.
screen -X stuff "/query *status broadcast The server is shutting down for a brief maintenance in 1 minute!
"
echo "ZNC shutdown in 1 minute!"
sleep 60
# And 0 minute mark
screen -X stuff "/query *status broadcast The server is shutting down for a brief maintenance NOW!
"
# And now let's stop the service
echo "Timer complete.  Stopping ZNC."
sudo service znc stop
# And then install the new version
echo "Installing ZNC..."
sudo make install
# Then, we'll restart the service and output the
# status information on the screen.
echo "Restarting ZNC..."
sudo service znc start
sudo service znc status
# Let's exit irssi, because we don't need it anymore
echo "Closing irssi..."
screen -X stuff "/exit
"
# And finally, do a bit of cleanup.
# We'll remove the old backups and rename the new files
# we've acquired to be backed up, in case they're needed later.
# Simply back these up further
# if you wish to keep them.
# If you used git, there will be file not found errors.
echo "Cleaning up..."
cd ~
rm -f zncold.tar.gz
mv znc-latest.tar.gz zncold.tar.gz
rm -f simple_disconnect.old
mv simple_disconnect.cpp simple_disconnect.old
# If you used wget,there is a znc.ver file
# We don't really need znc.ver at all because it just lists "znc-version/"
# so we'll remove it
# This will produce a file not found error if you used git
rm -f znc.ver
# We also don't need to keep sudo rights open after this, so let's remove the
# timestamp file
sudo -K
echo "Update complete."
