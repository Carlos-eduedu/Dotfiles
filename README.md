# Dotfiles

esse repositório serve de backup para meus arquivos de configuração e pode ser que sirva de inspiração para alguém.

## Clone de repositório.

```bash
git clone https://github.com/Carlos-eduedu/Dotfiles.git ~/
```

## Instalação e configuração alacritty

Para a instalação do alacritty eu uso o [homebrew](https://formulae.brew.sh/) que o gerenciador de pacotes que eu uso.

Para instalar o alacritty execute:

```bash
brew install --cask alacritty
```

E execute:

```bash
brew install --cask font-jetbrains-mono-nerd-font
```

```bash
ln -s Dotfiles/alacritty/.alacritty.toml .alacritty.toml
```

## configuração do vim

para configurar o deve criar o link simbolico.

```bash
ln -s ~/Dotfiles/vim/.vimrc ~/.vimrc
```

depois de criar o link simbolico, temos que instalar o vim-plug
para carregar os plugins do vim.

```bash
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```
