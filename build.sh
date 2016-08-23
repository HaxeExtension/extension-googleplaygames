#!/bin/bash
dir=`dirname "$0"`
cd "$dir"
rm -f extension-googleplaygames.zip
rm -rf project/obj
lime rebuild . ios || exit
rm -rf project/obj
zip -0r extension-googleplaygames.zip extension haxelib.json include.xml dependencies project ndll frameworks/Google*
