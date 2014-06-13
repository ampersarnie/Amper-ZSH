# Github Access Token
# - Uncomment the variable below and add your token if you wish to use github.
# - Tokens can be generated here: https://github.com/settings/applications#personal-access-tokens
# GITHUB_ACCESS_TOKEN = <your token>;

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
        echo "$fg[red]To add a remote repository use the following command:"
        echo "git remote add origin https://example.com/user/repo.git"
    fi
}

# Github Init
# - Initializes git in the current directory, creates a README and .gitignore
#   then adds a repository to github.com and pushes.
# Usage: ghint <repo name>
# Example: $ ghint "My Repository"
ghint() {
    if [[ ! -z $1 ]];
        then
            touch README.md
            echo "# "$1 >> README.md
            touch .gitignore
            echo ".gitignore" >> .gitignore
            repo=$(gh-create-repo $1 2>&1)

            git init
            git add .
            git commit -am "Init"
            git remote add origin $repo
            git push -u origin master
    else
        echo "$fg[red]Oops! You haven't defined a repo."
        echo "Usage: ghint <repo name>"
    fi
}

# Github Create Repository
# - Makes an API call to Github, creates the given repository name
#   and outputs the SSH URL.
# - Requires API Token to be set.
# Usage: gh-create-repo <repo name>
# Example: $ gh-create-repo "My Repository"
gh-create-repo() {
    if [[ ! -z $1 ]];
        then
            # Create Github Repo
            output=$(curl -s -u $GITHUB_ACCESS_TOKEN":x-oauth-basic" https://api.github.com/user/repos -d "{\"name\": \""$1"\"}" 2>&1)
            sshurl=$(echo $output | egrep -o "\"ssh_url\": \"(.*)\"," | sed -E "s/^\"ssh_url\": \"(.*)\",/\1/")

            echo $sshurl

    else
        echo "$fg[red]Oops! You haven't defined a repo."
        echo "Usage: gh-create-repo <repo name>"
    fi
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
    echo "-----------------------------------"
    echo "Stashed files in $1"
    echo "-----------------------------------"
    gsl
}

# Git Stash List
# - Lists filenames of the most recent stash
# Usage: gsl
gsl() {
    output=$(git stash show -p | grep 'diff'); echo $output | egrep -o " b\/(.*)"
}
