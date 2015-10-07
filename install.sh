#!/bin/bash
dir=`dirname "$0"`
cd "$dir"
haxelib remove extension-googleplaygames
haxelib local extension-googleplaygames.zip
