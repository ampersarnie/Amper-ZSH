# Send To Pushover
# - Sends a push notification using the Pushover API.
# Usage: send-to-pushover <message>
# Example: send-to-pushover "Notification from Terminal"
send-to-pushover() {
    if [[ ! -z $PUSHOVER_APP_TOKEN && ! -z $PUSHOVER_USER_TOKEN ]];
        then;
            message=$(get-piped)

            if [[ -z $1 ]];
                then;
                    print -R "${message_error}Message not set."
                    die
            fi

            # Check piping.
            if [ -z "$message" ];
                then
                    message=$1
            fi

            message=$(uri-escape $message)
            po_data="token=${PUSHOVER_APP_TOKEN}&user=${PUSHOVER_USER_TOKEN}&message=${message}"

            output=$(curl POST -s https://api.pushover.net/1/messages.json -d $po_data 2>&1)
            po_status=$(echo $output | sed -E -n 's/.*"status":"{0,1}([^,"]+)(,|").*/\1/p')
            po_request=$(echo $output | sed -E -n 's/.*"request":"{0,1}([^,"]+)(,|").*/\1/p')

            print -P "${message_complete}Pushover - sent the message: \"${1}\" and recieved the receipt id of \'${po_request}\'"

    else
        print -R "${message_error}PUSHOVER_API_TOKEN has not been set."
    fi
}
