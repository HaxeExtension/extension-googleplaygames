#!/bin/bash
dir=`dirname "$0"`
cd "$dir"
haxelib remove openfl-gpg
haxelib local openfl-gpg.zip
