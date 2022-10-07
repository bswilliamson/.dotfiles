#!/bin/bash

set -Eeu -o pipefail

error() {
	echo "error $2: $1"
}

trap 'error "$BASH_COMMAND" $?' ERR

# Constants
export ROOT_DIR="$(readlink -f "$(dirname "${BASH_SOURCE[0]}")/..")"
export CONFIG_DIR="$ROOT_DIR/etc"
export PKG_DIR="$ROOT_DIR/src"
export VIM_PLUGINS_DIR=~/.vim/pack/plugins/start

# Utility functions

clean_clone() {
	local name=$1
	local version=$2
	local repo=$3
	
	local dir="$PKG_DIR/$name"
	rm -rf "$dir"
	git clone --branch="$version" --config="advice.detachedHead=false" --depth=1 "$repo" "$dir"
	cd $dir
}

clean_curl() {
	local name=$1
	local url=$2
	
	local dir="$PKG_DIR/$name"
	rm -rf "$dir"
	mkdir -p $dir
	cd $dir
	curl -LO "$url"
}

vim_add_plugin() {
	local name=$1
	local version=$2
	local repo=$3

	clean_clone "$name" "$version" "$repo"

	mkdir -p "$VIM_PLUGINS_DIR"
	ln -sf "$(pwd)" "$VIM_PLUGINS_DIR"/"$name"
}

add_line() {
	local line=$2
	local file=$1

	if ! [[ -f $file ]] || ! grep -qF "$line" "$file"; then
		echo "$line" >> "$file"
	fi	
}

# Platform independent install functions but have platform specific prerequisites
# so must be invoked in calling script.

# requires node
install_vim_plugins() {
	vim_add_plugin vim-code-dark master https://github.com/tomasiser/vim-code-dark.git
	vim_add_plugin vim-lightline master https://github.com/itchyny/lightline.vim
	vim_add_plugin vim-go master https://github.com/fatih/vim-go.git
	vim_add_plugin fugitive master https://tpope.io/vim/fugitive.git
	vim_add_plugin coc.nvim release https://github.com/neoclide/coc.nvim.git
}

# Platform indpendent functions that can be invoked now.

configure_shell() {
	local profile=$CONFIG_DIR/profile
	local bashrc=$CONFIG_DIR/bashrc

	add_line ~/.profile "[ -e \"$profile\" ] && . \"$profile\""
	add_line ~/.zprofile "[ -e ~/.profile ] && . ~/.profile"
	add_line ~/.bashrc "[ -e \"$bashrc\" ] && . \"$bashrc\""
	add_line ~/.zshrc "[ -e ~/.bashrc ] && . ~/.bashrc"

	source "$profile"
	source "$bashrc"
}

configure_shell
