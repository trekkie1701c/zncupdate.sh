# zncupdate.sh
A quick update script for the ZNC irc bouncer

This script is meant to be run in the user's home directory.

By default, this script fetches the znc-latest.tar.gz via wget, then runs through installation.  This provides the latest stable release.
However, you may also uncomment the git lines to use git, as well as comment over the wget lines to disable it (although, if they're both uncommented only git will be used).  Using git requires that you have the autotools-dev and automake packages installed, in order to run the ./bootstra.sh script.
This script also enables tcl scripting support in ZNC; you can edit the requisite line in order to change this behavior.  Your system will obviously need to have the appropriate packages installed, which this script does not do.

As an optional feature, a properly configured irssi client will be called via screen in order to send a broadcast to the bouncer
to warn users that you'll be shutting the bouncer down soon.  You will have to install and configure irssi yourself; I recommend assigning it to a ZNC admin account which can only log in via localhost for security.
