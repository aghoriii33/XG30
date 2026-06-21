@echo off
echo ====================================================
echo JARVIS AI - Production Build Script
echo ====================================================

cd jarvis_ai

echo.
echo [1/3] Building Android App Bundle (Play Store)...
call flutter build appbundle --release
if errorlevel 1 goto error

echo.
echo [2/3] Building Web Release...
call flutter build web --release
if errorlevel 1 goto error

echo.
echo [3/3] Building Windows Executable...
call flutter build windows --release
if errorlevel 1 goto error

echo.
echo ====================================================
echo ALL BUILDS SUCCESSFUL!
echo ====================================================
echo Android AAB: build\app\outputs\bundle\release\app-release.aab
echo Web Build:   build\web\
echo Windows Exe: build\windows\runner\Release\jarvis_ai.exe
goto end

:error
echo.
echo Build Failed! Please check the output logs above.

:end
pause
