#!/bin/bash
dir=`dirname "$0"`
cd "$dir"
rm -f openfl-gpg.zip
zip -0r openfl-gpg.zip gpgex haxelib.json include.xml dependencies 
