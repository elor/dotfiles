# elor's Dotfiles

## Description

elor's personal collection of dotfiles - To be used with [chezmoi](https://www.chezmoi.io/).

## Use (note to self, no comprehensive manual of chezmoi)

On a new machine (with chezmoi installed):

    # download dotfiles from github
    chezmoi init git@github.com:elor/dotfiles

    # check for differences
    chezmoi diff

    # apply local dotfiles
    chezmoi apply -v

Fast install on a new machine:

    chezmoi init --apply git@github.com:elor/dotfiles

Edit a file through chezmoi:

    # make changes to chezmoi's working copy
    chezmoi edit ~/.config/my/file

    # apply changes to local dotfiles
    chezmoi apply -v

Update from the local dotfile

    chezmoi merge ~/.config/my/file

Add a new dotfile:

    chezmoi add ~/.config/my/new_file

Pull from github and apply:

    chezmoi update -v

