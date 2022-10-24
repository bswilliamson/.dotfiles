#!/bin/bash

set -Eeu -o pipefail

source "./lib/core.sh"

install_macports() {
	if command -v port >/dev/null; then
		return
	fi
	
	download_repo macports v2.8.0 https://github.com/macports/macports-base.git

	sudo ./configure --enable-readline
	sudo make
	sudo make install
	sudo make distclean

	sudo port -v selfupdate
}

install_macports_packages() {
	pkgs=(
		go
		neovim
		nodejs16
		npm8
		tmux
	)

	sudo port -N install ${pkgs[@]}

	if (( $UPGRADE == 1 )); then
		sudo port upgrade ${pkgs[@]}
	fi
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
	ln -sf "$CONFIG_DIR/lsp.lua" ~/.vim/lsp.lua
}

install_vscode() {
	app_name="Visual Studio Code.app"

	if (( UPGRADE == 0 )) && [[ -d "/Applications/$app_name" ]]; then
		return
	fi

	os=darwin
	if [[ "$(uname -m)" == "arm64" ]]; then
		os=darwin-arm64
	fi

	download_file vscode vscode.zip "https://code.visualstudio.com/sha/download?build=stable&os=$os"
	unzip -oq vscode.zip
	sudo chown 0:0 "$app_name"
	sudo rm -rf "/Applications/$app_name"
	sudo mv "$app_name" /Applications/
}

install_macports
install_macports_packages
install_vim_plugins
configure_neovim
install_vscode
