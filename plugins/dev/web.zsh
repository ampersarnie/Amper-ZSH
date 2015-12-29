DEFAULT_HOSTS_FILE="/etc/hosts"
DEFAULT_HTTPD_VHOSTS_FILE="/private/etc/apache2/extra/httpd-vhosts.conf"

if [[ -z "$HOSTS_FILE" ]];
    then
        HOSTS_FILE=$DEFAULT_HOSTS_FILE;
fi

# Composer, Laravel/Artisan and Vagrant Aliases
# Add 'source ~/.zsh_alias' to the bottom of ~/.zshrc to use
# Can also add to these to /Homestead/aliases for us with your Homestead VM
# by @JamesMills
# https://gist.github.com/jamesmills/8a8d7d63abb6b51742ec

# Composer
alias csu="composer self-update"
alias cu="composer update"
alias ci="composer install"
alias cda="composer dump-autoload -o"

# Laravel / Artisan
alias pa="php artisan"
alias par="php artisan routes"
alias pam="php artisan migrate"
alias pam:r="php artisan migrate:refresh"
alias pam:roll="php artisan migrate:rollback"
alias pam:rs="php artisan migrate:refresh --seed"
alias pda="php artisan dumpautoload"

# Vagrant
alias v='vagrant version && vagrant global-status'
alias vst='vagrant status'
alias vup='vagrant up'
alias vdo='vagrant halt'
alias vssh='vagrant ssh'
alias vkill='vagrant destroy'

# Homestead
alias hsup='homestead up'
alias hsreboot='homestead halt && homestead up'

# General
alias edit-host="sudo nano "$HOSTS_FILE
alias showhidden='defaults write com.apple.finder AppleShowAllFiles True; killall Finder'
alias hidehidden='defaults write com.apple.finder AppleShowAllFiles False; killall Finder'

add-host() {
    if [[ ! -z "$2" ]];
        then
            ip=$(is-ip $1)

            touch "/tmp/hosts.tmp"
            cat $HOSTS_FILE >> "/tmp/hosts.tmp"

            echo $ip"\t"$2 >> "/tmp/hosts.tmp"

            sudo cp "/tmp/hosts.tmp" $HOSTS_FILE
            sudo rm "/tmp/hosts.tmp"

            print -P "$FG[155]Added: $FX[reverse]"$ip" "$2"$FX[no-reverse] to $FX[reverse]"$HOSTS_FILE$FX[reset]
    else
        print -P "$FG[124]Please provide a domain.$FX[reset]"
    fi

}

apache-add-vhost() {
    if [[ -z "$HTTPD_VHOSTS_FILE" ]];
        then
            print -P "$FG[208]HTTPD_VHOSTS_FILE is not set so using default: $FX[reverse]$DEFAULT_HTTPD_VHOSTS_FILE$FX[reset]"
            HTTPD_VHOSTS_FILE=$DEFAULT_HTTPD_VHOSTS_FILE;
    fi

    print -P "$FG[027]Port: $FX[reset]"
    read port

    if [[ -z "$port" ]];
        then
            port="80"
            print -P "$FG[208]Using default Port: $FX[reverse]$port$FX[no-reverse]$FX[reset]"
    fi

    print -P "$FG[027]Doument Root: $FX[reset]"
    read doc_root

    if [[ -z "$doc_root" ]];
        then
            doc_root=$(pwd)
            print -P "$FG[208]Using current directory path as Document Root: $FX[reverse]$doc_root$FX[no-reverse]$FX[reset]"
    fi

    print -P "$FG[027]Server Name: $FX[reset]"
    read server_name

    if [[ -z "$server_name" ]];
        then
            server_name=${PWD##*/}".dev"
            server_name=$(print -P $server_name:l:gs/" "/"-")
            print -P "$FG[208]Using current directory name as Server Name: $FX[reverse]$server_name$FX[reset]"
    else
        server_name=$(print -P $server_name:l:gs/" "/"-")
    fi

    print -P "$FG[027]Server Alias: $FX[reset]"
    read server_alias

    # Create contents
    content="<VirtualHost *:$port>\n\tDocumentRoot \"$doc_root\"\n\tServerName $server_name\n"

    if [[ ! -z "$server_alias" ]];
        then
            content=$content"\tServerAlias $server_alias\n"
    else
        print -P "$FG[124]Not setting a Server Alias$FX[reset]"
    fi

    content=$content"\n\t<Directory ${doc_root}>\n\t\tOptions Indexes FollowSymLinks\n\t\tAllowOverride All\n\t\tOrder allow,deny\n\t\tAllow from all\n\t</Directory>\n"
    content=$content"</VirtualHost>\n\n"

    touch "/tmp/httpd-vhosts.tmp"
    cat $HTTPD_VHOSTS_FILE >> "/tmp/httpd-vhosts.tmp"
    echo $content >> "/tmp/httpd-vhosts.tmp"

    sudo cp "/tmp/httpd-vhosts.tmp" $HTTPD_VHOSTS_FILE
    sudo rm "/tmp/httpd-vhosts.tmp"

    # Add to hosts file
    add-host "127.0.0.1" $server_name

    print -P "$FG[040]Added Virtual Host to $FX[reverse]$HTTPD_VHOSTS_FILE$FX[reset]"
    print -P "$FG[040]Restarting Apache...$FX[reset]"
    sudo apachectl restart
}

is-ip() {
    if [[ $1 =~ "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$" ]];
        then
            print -P $1
    else
        print -P "127.0.0.1"
    fi
}
