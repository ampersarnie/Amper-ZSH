# The directory of the .zsh scripts
SCRIPT_SOURCE=${0%/*}

local amper_message_postfix=" ➜\n"

local colour_blue="$FG[027]"
local colour_green="$FG[040]"
local colour_orange="$FG[208]"
local colour_red="$FG[124]"

# Message Colours
local message_default=$colour_blue"Message"$amper_message_postfix
local message_complete=$colour_green"Complete"$amper_message_postfix
local message_warning=$colour_orange"Warning"$amper_message_postfix
local message_error=$colour_red"Error"$amper_message_postfix

local message_none=$colour_blue" ➜ "
local message_question$colour_blue"message_question"$amper_message_postfix

load-files() {
    # Check that config exists
    if [[ ! -e $SCRIPT_SOURCE"/config.zsh" ]];
        then
            print -P "${message_error}config.zsh does not exist in ${SCRIPT_SOURCE}\nPlease copy config-example.zsh and add the appropriate settings.$FX[reset]"
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
