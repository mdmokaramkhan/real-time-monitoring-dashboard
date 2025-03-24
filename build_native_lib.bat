REM filepath: c:\Users\DELL\projects\real-time-monitoring-dashboard\build_native_lib.bat
@echo off
echo Building native library...

REM Clean up build directory
cd native
if exist build (
    rd /s /q build
)
mkdir build
cd build

echo Configuring CMake...
cmake -G "Visual Studio 17 2022" -A x64 ..

if %ERRORLEVEL% NEQ 0 (
    echo CMake configuration failed!
    exit /b %ERRORLEVEL%
)

echo Building...
cmake --build . --config Release

if %ERRORLEVEL% NEQ 0 (
    echo Build failed!
    exit /b %ERRORLEVEL%
)

REM Create all necessary directories
if not exist "..\..\assets" mkdir "..\..\assets"
if not exist "..\..\assets\native" mkdir "..\..\assets\native"
if not exist "..\..\build\libs" mkdir "..\..\build\libs"

REM Copy DLL to all possible locations
echo Copying DLL to assets directory...
copy /Y Release\native_cpu_lib.dll "..\..\assets\native\libnative_cpu_lib.dll"
copy /Y Release\native_cpu_lib.dll "..\..\build\libs\cpu_monitor.dll"

cd ../..
echo Build complete!
echo.
echo DLL locations:
echo - assets\native\libnative_cpu_lib.dll
echo - build\libs\cpu_monitor.dll