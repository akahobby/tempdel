@echo off
setlocal EnableExtensions EnableDelayedExpansion

call :EnsureElevated
if errorlevel 1 exit /b 0

:: Enable ANSI escape sequences for color (Windows 10+).
for /f "delims=" %%E in ('echo prompt $E ^| cmd') do set "ESC=%%E"
set "RST=%ESC%[0m"
set "BOLD=%ESC%[1m"
set "DIM=%ESC%[2m"
set "RED=%ESC%[91m"
set "GRN=%ESC%[92m"
set "YLW=%ESC%[93m"
set "BLU=%ESC%[94m"
set "CYN=%ESC%[96m"
set "WHT=%ESC%[97m"

set "TARGET_1=%TEMP%"
set "TARGET_2=C:\Windows\Temp"
set "TARGET_3=C:\Windows\Prefetch"

set /a TOTAL_FILES=0
set /a TOTAL_DIRS=0
set /a TOTAL_SKIPPED=0
set /a TOTAL_ERRORS=0

call :Header
call :Intro

for %%D in ("%TARGET_1%" "%TARGET_2%" "%TARGET_3%") do (
    call :CleanDirectory "%%~D"
)

call :Summary
exit /b 0

:EnsureElevated
net session >nul 2>&1
if %errorlevel%==0 exit /b 0

echo Requesting Administrator privileges...
powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
exit /b 1

:Header
cls
echo %CYN%%BOLD%======================================================================%RST%
echo %CYN%%BOLD%                     TEMPORARY FILE CLEANUP TOOL                        %RST%
echo %CYN%%BOLD%======================================================================%RST%
echo %DIM%Looks best in Windows Terminal / modern Command Prompt.%RST%
echo.
exit /b 0

:Intro
echo %WHT%This utility cleans:%RST%
echo   %BLU%[1]%RST% %TARGET_1%
echo   %BLU%[2]%RST% %TARGET_2%
echo   %BLU%[3]%RST% %TARGET_3%
echo.
echo %YLW%Run as Administrator for best results.%RST%
echo.
pause
exit /b 0

:CleanDirectory
set "DIR=%~1"
set /a FILES=0
set /a DIRS=0
set /a ERRORS=0

echo %CYN%----------------------------------------------------------------------%RST%
echo %BOLD%%WHT%Cleaning:%RST% %DIR%

if not exist "%DIR%" (
    echo %YLW%  [SKIP]%RST% Directory not found.
    set /a TOTAL_SKIPPED+=1
    exit /b 0
)

for /f "delims=" %%F in ('dir /a:-d /b /s "%DIR%" 2^>nul') do (
    del /f /q "%%F" >nul 2>&1
    if errorlevel 1 (
        set /a ERRORS+=1
    ) else (
        set /a FILES+=1
    )
)

for /f "delims=" %%G in ('dir /a:d /b /s "%DIR%" 2^>nul ^| sort /R') do (
    rd /s /q "%%G" >nul 2>&1
    if errorlevel 1 (
        rem Directory may be locked or still in use.
    ) else (
        set /a DIRS+=1
    )
)

set /a TOTAL_FILES+=FILES
set /a TOTAL_DIRS+=DIRS
set /a TOTAL_ERRORS+=ERRORS

if !ERRORS! GTR 0 (
    echo %YLW%  [DONE with warnings]%RST% Files deleted: !FILES! ^| Folders removed: !DIRS! ^| Access issues: !ERRORS!
) else (
    echo %GRN%  [DONE]%RST% Files deleted: !FILES! ^| Folders removed: !DIRS!
)

exit /b 0

:Summary
echo.
echo %CYN%%BOLD%======================================================================%RST%
echo %BOLD%%WHT%Cleanup complete.%RST%
echo.
echo %GRN%  Total files deleted : %TOTAL_FILES%%RST%
echo %GRN%  Total folders removed: %TOTAL_DIRS%%RST%
echo %YLW%  Skipped locations    : %TOTAL_SKIPPED%%RST%
if %TOTAL_ERRORS% GTR 0 (
    echo %RED%  Access/lock issues  : %TOTAL_ERRORS%%RST%
    echo %DIM%  Some files may require elevated privileges or a reboot.%RST%
)
echo %CYN%%BOLD%======================================================================%RST%
echo.
pause
exit /b 0
