#!/bin/bash

DOTFILES_DIR=$(pwd)
for dotfile in gitconfig spacemacs zprofile zshenv zshrc lein; do
  ln -fs $DOTFILES_DIR/$dotfile $HOME/.$dotfile
done
ln -fs $DOTFILES_DIR/tmux/tmux.conf $HOME/.tmux.conf
