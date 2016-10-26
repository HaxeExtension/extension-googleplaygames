#!/bin/bash
dir=`dirname "$0"`
cd "$dir"
rm -f extension-googleplaygames.zip
zip -9r extension-googleplaygames.zip extension haxelib.json include.xml dependencies 
