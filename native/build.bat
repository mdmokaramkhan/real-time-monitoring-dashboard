@echo off
setlocal enabledelayedexpansion

echo Building Windows native library...

:: Check if Visual Studio is installed
where cl >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Error: Visual Studio compiler (cl) not found in PATH
    echo Please run this script from a Visual Studio Developer Command Prompt
    exit /b 1
)

:: Create build directory
if not exist ..\build\libs mkdir ..\build\libs

:: Compile the library
cl /nologo /LD /Fe:..\build\libs\cpu_monitor.dll windows\cpu_monitor.c pdh.lib

if %ERRORLEVEL% NEQ 0 (
    echo Failed to build the Windows library
    exit /b 1
)

echo Windows library built successfully: %CD%\..\build\libs\cpu_monitor.dll
echo Build complete!

:: Clean up intermediate files
del cpu_monitor.obj cpu_monitor.lib cpu_monitor.exp 2>nul 