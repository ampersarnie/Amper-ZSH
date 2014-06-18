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

# Get Piped
# - Get's piped data and allows it to be used elsewhere.
get-piped() {
    piped=''
    if [ ! -t 0 ];
        then
            while read data;
                do
                    piped=$data
            done
    fi
    echo $piped
}
