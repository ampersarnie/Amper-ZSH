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

cpwd() {
    echo "${PWD##*/}"
}

die() {
    kill -INT $$
}

clear-term-logs() {
    sudo rm -rf /private/var/log/asl/*.asl
}
