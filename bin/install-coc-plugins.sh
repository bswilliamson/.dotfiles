#!/bin/bash

plugins=(
	go
	sh
)

install_command=

for plugin in "${plugins[@]}"; do
	install_command+=":CocInstall coc-$plugin |"
done

nvim -c "$install_command" 
