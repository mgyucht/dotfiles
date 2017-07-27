#!/bin/bash

for dotfile in gitconfig spacemacs tmux vimrc vim_runtime zshenv zshenv_local zshrc zshrc_local; do
  ln -s $dotfile $HOME/.$dotfile
done

echo "export PATH=$PATH:$(pwd)/bin" >> $HOME/.zshenv_local
