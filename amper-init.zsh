# The directory of the .zsh scripts
SCRIPT_SOURCE=${0%/*}

local amper_message_prefix=" ➜\n"

# Colours
local cwarning="$FG[208]%}Warning"$amper_message_prefix
local cerror="$FG[124]Error"$amper_message_prefix

load-files() {
    # Check that config exists
    if [[ ! -e $SCRIPT_SOURCE"/config.zsh" ]];
        then
            print -P "${cerror}config.zsh does not exist in ${SCRIPT_SOURCE}\nPlease copy config-example.zsh and add the appropriate settings.$FX[reset]"
            return 1
    fi

    # If LOAD_FILES is not defined, load all.
    if [[ -z $LOAD_FILES ]];
        then
            LOAD_FILES=("git" "web-dev" "commander")
    fi

    LOAD_FILES+=("globals")

    for file in "$LOAD_FILES[@]"
    do
        current_file=$SCRIPT_SOURCE$file".zsh"

        if [[ -e $current_file ]];
            then
                source $current_file
        fi
    done
}

load-files
