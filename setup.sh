#!/bin/bash

DOTFILES_DIR=$(pwd)
for dotfile in gitconfig spacemacs zshenv zshenv_local zshrc zshrc_local; do
  ln -fs $DOTFILES_DIR/$dotfile $HOME/.$dotfile
done
ln -fs $DOTFILES_DIR/tmux/tmux.conf $HOME/.tmux.conf
