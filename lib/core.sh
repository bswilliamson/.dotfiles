#!/bin/bash

set -Eeu -o pipefail

error() {
	echo "error $2: $1"
}

trap 'error "$BASH_COMMAND" $?' ERR

# Constants
ROOT_DIR="$(readlink -f "$(dirname "${BASH_SOURCE[0]}")/..")"
CONFIG_DIR="$ROOT_DIR/etc"
PKG_DIR="$ROOT_DIR/pkg"
VIM_PLUGINS_DIR=~/.vim/pack/plugins/start

# Options
set +u
if [[ -z $CLEAN ]]; then
	CLEAN=0
fi
set -u

# Utility functions

download_repo() {
	local name=$1
	local version=$2
	local repo=$3

	local dir="$PKG_DIR/$name"
	
	if (( $CLEAN == 0 )) && [[ -d $dir ]]; then
		cd $dir
		return
	fi

	sudo rm -rf "$dir"
	git clone --branch="$version" --config="advice.detachedHead=false" --depth=1 "$repo" "$dir"
	cd $dir
}

download_file() {
	local pkg_name=$1
	local file_name=$2
	local url=$3

	local dir="$PKG_DIR/$pkg_name"

	if (( $CLEAN == 0 )) && [[ -f "$dir/$file_name" ]] ; then
		cd $dir
		return
	fi
	
	sudo rm -rf "$dir"
	mkdir -p $dir
	cd $dir
	if [[ $file_name == "-" ]]; then
		curl -LO "$url"
	else
		curl -Lo "$file_name" "$url"
	fi
}

vim_add_plugin() {
	local name=$1
	local version=$2
	local repo=$3

	download_repo "$name" "$version" "$repo"

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
