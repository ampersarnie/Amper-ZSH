gh_request=""

# Git Init
# - Initializes git in the current directory, creates a README and .gitignore
# Usage: gint <name> <url>
# Example: $ gint origin https://example.com/user/repo.git
gint() {
    git init
    touch README.md
    touch .gitignore
    echo ".gitignore" >> .gitignore
    if [[ ! -z $1 && ! -z $2 ]];
        then
            git remote add $1 $2
    else
        print -P "${message_default}To add a remote repository use the following command:\n$FX[reverse]git remote add origin https://example.com/user/repo.git$FX[reset]"
    fi

    message=".git created in "$(cpwd)
    send-notification $message "Git Initialize"
}

# Github Init
# - Initializes git in the current directory, creates a README and .gitignore
#   then adds a repository to github.com and pushes.
# - Requires API Token to be set.
# Usage: ghint <api key>:<value>
# Example: $ ghint name:"My Repository" description:"this is my repository, it's a very fine one."
ghint() {
    gh-has-access-token;

    if [[ ! -z $@ ]];
        then
            touch README.md
            echo "# "$1 >> README.md
            touch .gitignore
            echo ".gitignore" >> .gitignore

            # Create the repo on github.
            repo=$(gh-create-repo $@ 2>&1)

            git init
            git add .
            git commit -am "Init"
            git remote add origin $repo
            git push -u origin master
    else
        print -P "${message_error}Oops! You haven't defined a repo.\nUsage: ghint <repo name>"
    fi
}

# Github Create Repository
# - Makes an API call to Github, creates the given repository name
#   and outputs the SSH URL.
# - Requires API Token to be set.
# Usage: gh-create-repo <api key>:<value>
# Example: $ gh-create-repo name:"My Repository" description:"this is my repository, it's a very fine one."
gh-create-repo() {
    gh-create-request $@
    gh-check-request-name

    # Create Github Repo
    output=$(curl -s -u $GITHUB_ACCESS_TOKEN":x-oauth-basic" https://api.github.com/user/repos -d $gh_request[1] 2>&1)
    sshurl=$(echo $output | egrep -o "\"ssh_url\": \"(.*)\"," | sed -E "s/^\"ssh_url\": \"(.*)\",/\1/")

    if [ "$sshurl" ];
        then
            print -P $message_none$sshurl
    else
        print -P "${message_error}There was a problem creating the repo on Github."
    fi
}

# Github Edit Repository
# - Makes an API call to Github and edits the repository with the given parameters
# - Requires API Token to be set.
# Usage: gh-edit-repo <repo name> <repo owner> <api key>:<value>
# Example: $ gh-edit-repo "Some Repo" "ampersarnie" name:"My Repository" description:"this is my repository, it's a very fine one."
gh-edit-repo() {
    if [[ ! -z $1 && ! -z $2 ]];
        then
            current_name=$(echo $1 | grep -E "^(.*):(.*)$")
            owner=$(echo $2 | grep -E "^(.*):(.*)$")
            current_name_len=${#current_name}
            owner_len=${#owner}
    fi

    if [[ $current_name_len == "0" ]] && [[ $owner_len == "0" ]];
        then
            print -P "${message_default}Updating \"${1}\" by $2"
            current_name=$1
            owner=$2
            shift $@[0] # Remove the current name
            shift $@[0] # Remove the owner
    else
        print -P "${message_error}Please provide the current repository name as the first argument and owner as the second."
        die
    fi

    gh-create-request $@

    # Edit Github Repo
    output=$(curl PATCH -s -u $GITHUB_ACCESS_TOKEN":x-oauth-basic" https://api.github.com/repos/$owner/$current_name -d $gh_request[1] 2>&1)
    sshurl=$(echo $output | egrep -o "\"ssh_url\": \"(.*)\"," | sed -E "s/^\"ssh_url\": \"(.*)\",/\1/")

    if [ "$sshurl" ];
        then
            print -P $message_none$sshurl
    else
        print -P "${message_error}There was a problem editing the \"$current_name\" repo on Github."
    fi

}

# Github Get Repository
# - Makes an API call to retrieve the information of the given repository
# - Requires API Token to be set.
# ! Only Returns SSH location at the moment
# Usage: gh-get-repo <repo name> <repo owner>
# Example: $ gh-get-repo "Some Repo" "ampersarnie"
gh-get-repo() {
    gh-has-access-token
    output=$(curl -s -u $GITHUB_ACCESS_TOKEN":x-oauth-basic" https://api.github.com/repos/$1/$2  2>&1)
    sshurl=$(echo $output | egrep -o "\"ssh_url\": \"(.*)\"," | sed -E "s/^\"ssh_url\": \"(.*)\",/\1/")

    echo $sshurl
}

# Checks if the request has a required "name" parameter
gh-check-request-name() {
    # If $hasname is true then check for access token,
    # otherwise echo message and ctrl-c
    if [[ $gh_request[2] -eq "true" ]];
        then
            gh-has-access-token;
    else
        print -P "${message_error}An argument of 'name:\"<Repository Name>\"' is required to be able to create a repository on Github."
        die
    fi
}

gh-create-request() {
    hasname=false

    # Create the request JSON by looping through all passed
    # arguments.
    COUNT=0;
    request="{"
    for ARG in "$@"
    do
        # Check for "name" in the current argument.
        name=$(echo $ARG | sed -E "s/^(.*):(.*)$/\1/")
        if [ $name = "name" ];
            then
                hasname=true;
        fi

        addition=$(echo $ARG | sed -E "s/^(.*):(.*)$/\"\1\":\"\2\"/")

        if [[ $COUNT > 0 ]];
            then
                request=$request","$addition
        else
            request=$request$addition
        fi

        COUNT=$COUNT+1
    done
    request=$request"}"

    gh_request=("$request" "$hasname")
}

# Commit All The Things
# - Commits and pushes everything in the current repo
# Usage: catt <commit message>
# Example: $ catt "Fix all the things!"
catt() {
    git init -q
    git add --all
    git commit -am $1 -q
    git push -q
    log=$(git log --name-status HEAD^..HEAD) | echo $log
}

# Stash All The Things
# - Stashes everything in the current repo, then outputs files in stash.
# Usage: satt <stash name>
# Example: $ satt "Experiments"
satt() {
    git init
    git add --all
    git stash save $1
    print -P "${message_none}Stashed files in $1"
    gsl
}

# Git Stash List
# - Lists filenames of the most recent stash
# Usage: gsl
gsl() {
    output=$(git stash show -p | grep 'diff'); echo $output | egrep -o " b\/(.*)"
}

# Github: Has Access Token
gh-has-access-token() {
    if [[ -z $GITHUB_ACCESS_TOKEN ]];
        then
            echo "${message_error}Please set the GITHUB_ACCESS_TOKEN variable."
    fi

    if [[ -z $GITHUB_ACCESS_TOKEN ]];
        then
            die
    fi
}
