# Dotfiles

## Terminal
- alacritty
## Shell
- zsh/ohmyzsh
## Package Manager
- homebrew
## IDE
- vim

# configuração do vim
para configurar o deve criar o link simbolico.
```bash
ln -s ~/Dotfiles/vim/.vimrc ~/.vimrc
```
depois de criar o link simbolico, temos que instalar o vim-plug
para carregar os plugins do vim.
```bash
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```
