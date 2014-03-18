@echo off
SET dir=%~dp0
cd %dir%
haxelib remove openfl-gpg
haxelib local openfl-gpg.zip
