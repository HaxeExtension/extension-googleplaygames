@echo off
SET dir=%~dp0
cd %dir%
haxelib remove extension-googleplaygames
haxelib local extension-googleplaygames.zip
