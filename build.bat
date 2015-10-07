@echo off
SET dir=%~dp0
cd %dir%
if exist extension-googleplaygames.zip del /F extension-googleplaygames.zip
winrar a -afzip extension-googleplaygames.zip extension haxelib.json include.xml dependencies
pause