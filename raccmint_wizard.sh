#!/bin/bash

#1. Get the latest VSCode

curl -L "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64" -o $HOME/Downloads/vscode_latest.deb

#2. Install VSCode

sudo apt install $HOME/Downloads/vscode_latest.deb

#3. Delete the downloaded file

rm -rf $HOME/Downloads/vscode_latest.deb

#4. Get the RaccMint pack
