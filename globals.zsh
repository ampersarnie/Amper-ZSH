# This OS
# - Outputs the current Operating System in lowercase.
this-os() {
    platform='unknown'
    unamestr=$(uname)
    if [[ "$unamestr" == "Darwin" ]];
        then
            platform='osx'
    elif [[ "$unamestr" == "Linux" ]];
        then
            platform='linux'
    elif [[ "$unamestr" == "FreeBSD" ]];
        then
             platform='freebsd'
    fi

    echo $platform
}

# Send Notification
# - Sends a Notification Center message if using OSX.
# ! OSX Only.
# Usage: send-notification <message> [<title>]
# Example: send-notification "Hello world\nMy Script is complete." "My Script"
send-notification() {
    if [[ $(this-os) == "osx" && ! -z $1 ]];
        then
            title=''

            if [[ ! -z $2 ]];
                then
                    title=$2
            fi

            notificationstr="display notification \"$1\" with title \"$title\" sound name \"frog\""
            osascript -e $notificationstr
    fi
}

# Send Message
# - Sends a message using OSX's Messages App
# ! OSX Only.
# ! Sends to self if no recipient provided.
# Usage: send-message <message> [<recipient>]
# Example: send-message "I'll see you at 4." "+44712345678"
send-message() {
    if [[ $(this-os) == "osx" && ! -z $1 ]];
        then
            if [[ ! -z $2 ]];
                then
                    MOBILE_NUMBER=$2
            fi

            messagestr="tell application \"messages\"
                send \"$1\" to buddy \"$MOBILE_NUMBER\" of service \"E:$ICLOUD_EMAIL\"
            end tell"

            osascript -e $messagestr
            send-notification "Sent a message to $MOBILE_NUMBER" "Send Message"
    fi
}

# Current Working Directory
# - Shows the current working directory without the full path.
cpwd() {
    echo "${PWD##*/}"
}

# Die die die
# - Kills off the current process.
die() {
    kill -INT $$
}

# Clear Terminal Logs
# - Deletes all terminal logs - useful if prompt is slow.
clear-term-logs() {
    sudo rm -rf /private/var/log/asl/*.asl
}
