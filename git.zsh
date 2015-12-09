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

# Git Commit
# - Commits and pushes everything in the current repo
# Usage: catt <commit message>
# Example: $ catt "Fix all the things!"
gc() {
    git init -q
    git add --all
    git commit -am $1 -q
    git push -q
    log=$(git log --name-status HEAD^..HEAD) | echo $log

    send-notification "Pushed commit:\n\"$1\"" "Git"
}

# Git Stash
# - Stashes everything in the current repo, then outputs files in stash.
# Usage: satt <stash name>
# Example: $ satt "Experiments"
gs() {
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

# Git Archive
# - Archives given branch and pushes changes to current repo
# Usage: garchive <branch>
garchive() {
    git tag archive/$1 $1
    git branch -D $1
    git push --tags
    git push origin :$1

    send-notification "Archived:\n\"$1\"" "Git"
}
