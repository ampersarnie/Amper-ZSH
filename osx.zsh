# Send Notification
# - Sends a Notification Center message if using OSX.
# ! OSX Only.
# Usage: send-notification <message> [<title>]
# Example: send-notification "Hello world\nMy Script is complete." "My Script"
send-notification() {
    message=$(get-piped)

    if [ -z "$message" ];
        then
            message=$1
    fi

    # Replace double quotes with single quotes
    # because AppleScript doesn't like them
    # and it's a pain in the arse to fix right now.
    message=$(echo $message | sed -e s/\"/\'/g)

    if [[ $(this-os) == "osx" && ! -z $1 ]];
        then
            title=''

            if [[ ! -z $2 ]];
                then
                    title=$2
            fi

            if [[ ! -z $(app-path "Growl") && ( -z "$USE_GROWL" && "$USE_GROWL" = true ) ]]
                then
                    growl-notification $message $2
            else
                notification-center $message $2
            fi
    fi
}

notification-center() {
    message=$(get-piped)

    if [ -z "$message" ];
        then
            message=$1
    fi

    # Replace double quotes with single quotes
    # because AppleScript doesn't like them
    # and it's a pain in the arse to fix right now.
    message=$(echo $message | sed -e s/\"/\'/g)

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
                    recipient=$2
            fi

            if [[ -z $MOBILE_NUMBER ]];
                then
                    print -P "${message_error} MOBILE_NUMBER is not set. Add it to your ${SCRIPT_SOURCE}/config.zsh"
                    return 1
            else
                recipient=$MOBILE_NUMBER
            fi

            messagestr="tell application \"messages\"
                send \"$1\" to buddy \"$recipient\" of service \"E:$ICLOUD_EMAIL\"
            end tell"

            osascript -e $messagestr
            send-notification "Sent a message to $recipient" "Send Message"

            unset recipient
    fi
}

growl-notification() {
    message=$(get-piped)

    if [ -z "$message" ];
        then
            message=$1
    fi

    # Replace double quotes with single quotes
    # because AppleScript doesn't like them
    # and it's a pain in the arse to fix right now.
    message=$(echo $message | sed -e s/\"/\'/g)

    if [[ $(this-os) == "osx" && ! -z $1 ]];
        then
            title=''

            if [[ ! -z $2 ]];
                then
                    title=$2
            fi

            growlScript="tell application \"System Events\"
                set isRunning to (count of (every process whose bundle identifier is \"com.Growl.GrowlHelperApp\")) > 0
            end tell

            if isRunning then
                tell application id \"com.Growl.GrowlHelperApp\"
                    set the allNotificationsList to {\"Amper ZSH\"}
                    set the enabledNotificationsList to {\"Amper ZSH\"}
                    register as application \"Amper ZSH\" all notifications allNotificationsList default notifications enabledNotificationsList icon of application \"Script Editor\"
                    notify with name \"Amper ZSH\" title \"$title\" description \"$message\" application name \"Amper ZSH\"
                end tell
            end if"

            osascript -e $growlScript
    fi
}
