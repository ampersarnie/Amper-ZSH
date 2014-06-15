commander-save() {
    if [[ ! -z "$1" ]];
        then
            touch ~/.zsh/.commander/$1.txt
            echo !! >> ~/zsh/.commander/$1.txt
    fi
}
