@echo off
setlocal enabledelayedexpansion

echo Setting up for Windows...

set SRC_DIR=..\build\libs
set TARGET_DIR=..\build\windows\runner\Release

:: Create the target directory if it doesn't exist
if not exist "%TARGET_DIR%" mkdir "%TARGET_DIR%"

:: Copy the library
echo Copying library to %TARGET_DIR%
copy "%SRC_DIR%\cpu_monitor.dll" "%TARGET_DIR%\" /Y

:: Create a libs directory in the project root as an alternative location
if not exist "..\libs" mkdir "..\libs"
copy "%SRC_DIR%\*" "..\libs\" /Y

echo Post-build setup completed! 