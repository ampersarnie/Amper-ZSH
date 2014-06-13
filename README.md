# Ampersandwich Zsh Files
These are just a collection of custom Zsh scripts that I have begun to write and thought might be worth sharing.

## Setup
To keep the scripts separate from my main `.zshrc` file I will be adding each one to it’s own grouped file based on it’s function. For example git based functionality resides in the git.zsh file.

To add these to your zsh setup simply add the following to your `~/.zshrc` file for each that you require: `source ~/<filepath>.zsh`

For example: `source ~/.zsh/git.zsh`

You will end up with an `~/.zshrc` file that looks a bit like this:

```
export ZSH=$HOME/.oh-my-zsh
ZSH_THEME="agnoster"
DEFAULT_USER=“you”
source ~/.zshvars
source ~/.zsh/git.zsh
…
```