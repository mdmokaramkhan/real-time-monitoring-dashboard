@echo off
setlocal enabledelayedexpansion

echo ========================================
echo Real-Time System Monitoring Dashboard Setup
echo ========================================

:: Check if Visual Studio is installed
where cl >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Visual Studio compiler (cl) not found in PATH
    echo Please run this script from a Visual Studio Developer Command Prompt
    exit /b 1
)

:: Build native libraries
echo.
echo [1/3] Building native libraries...
cd native

echo Building for Windows...
call build.bat
if %ERRORLEVEL% NEQ 0 (
    echo Failed to build native libraries
    exit /b 1
)

call post_build.bat
if %ERRORLEVEL% NEQ 0 (
    echo Failed to run post-build step
    exit /b 1
)

cd ..

:: Create libs directory and copy libraries
echo.
echo [2/3] Setting up library paths...
if not exist libs mkdir libs
copy build\libs\* libs\ /Y

:: Make the libraries accessible for Flutter
echo.
echo [3/3] Getting Flutter dependencies...
call flutter pub get

echo.
echo ========================================
echo Setup complete! You can now run the app with:
echo    flutter run -d windows
echo ======================================== 