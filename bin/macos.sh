#!/bin/bash

set -Eeu -o pipefail

source "./lib/core.sh"

install_macports() {
	if command -v port >/dev/null; then
		return
	fi
	
	download_repo macports v2.7.2 https://github.com/macports/macports-base.git

	sudo ./configure --enable-readline
	sudo make
	sudo make install
	sudo make distclean

	sudo port -v selfupdate
}

install_tmux() {
	sudo port -N install tmux
}

install_node() {
	sudo port -N install nodejs16
	sudo port -N install npm8
}

install_neovim() {
	sudo port -N install neovim
}

configure_neovim() {
	mkdir -p ~/.config/nvim/
	cat > ~/.config/nvim/init.vim <<-EOF
	set runtimepath^=~/.vim runtimepath+=~/.vim/after
	let &packpath = &runtimepath
	source ~/.vim/vimrc
	EOF

	mkdir -p ~/.vim/
	ln -sf "$CONFIG_DIR/vimrc" ~/.vim/vimrc

	mkdir -p ~/.vim/after/plugin/
	ln -sf "$CONFIG_DIR/coc.vim" ~/.vim/after/plugin/
}

install_go() {
	sudo port -N install go
}

install_macports
install_tmux
install_node
install_neovim
install_vim_plugins
configure_neovim
install_go
