#!/bin/bash

DIR=$( cd $( dirname "${BASH_SOURCE[0]}" ) && pwd )

echo Installing dependences

pub install

echo Running core tests;

dart test/all.dart


download_contentshell.sh
unzip content_shell-linux-x64-release.zip
mv drt*/* .

./content_shell --dump-render-tree test/all_browser.html

rm content_shell-linux-x64-release.zip -f
rm drt* -rf
rm content_shell
rm content_shell.log
rm content_shell.pak
rm fonts.conf
rm libffmpegsumo.so
rm libosmesa.so
rm snapshot-size.txt

