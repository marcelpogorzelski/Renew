#!/bin/zsh
set -x 

function check_root()
{
# check we are NOT running as root
if [[ $(id -u) != 0 ]]; then
  echo "ERROR: This script must be run as root **EXITING**"
  exit 1
fi
}

#Only delete something if the variable has a value!
function rm_if_exists()
{
    if [ -n "${1}" ] && [ -e "${1}" ];then
        /bin/rm -rf "${1}"
    fi
}

echo "Deleting Renew.sh"
rm_if_exists "/usr/local/Renew.sh"

echo "Deleting LaunchAgent"
rm_if_exists "/Library/LaunchAgents/com.secondsonconsulting.renew.plist"

echo "Deleting logs and plists for all users"

# Read the command at the end of this while loop line by line (dscl . -list /Users UniqueID )
while read -r this_username this_uid; do
    # If the userID is greater than 500
    if (( this_uid > 500 )); then
    # Get the current users homefolder
    userHomeFolder=$(dscl . -read /users/${this_username} NFSHomeDirectory | cut -d " " -f 2)
    rm_if_exists  "$userHomeFolder/Library/Application Support/Renew/"
    rm_if_exists  "$userHomeFolder/Library/Preferences/com.secondsonconsulting.renew.user.plist"
    fi
done < <(dscl . -list /Users UniqueID)

echo "Forgetting Package"
pkgutil --forget com.secondsonconsulting.pkg.Renew  > /dev/null 2>&1

echo "Renew Uninstall Complete!"
