@echo off
setlocal EnableDelayedExpansion

REM — Gather all registered VM names into an indexed array —
set count=0
for /f "tokens=2 delims=\" %%i in ('VBoxManage list vms') do (
    set /a count+=1
    set "vm[!count!]=%%i"
)

if %count%==0 (
    echo No VirtualBox VMs found.
    exit /b 1
)

REM — Display numbered menu —
echo Available VirtualBox VMs:
for /L %%i in (1,1,%count%) do (
    echo   %%i) !vm[%%i]!
)

REM — Prompt for selection —
set /p selection=Select a VM by number: 

REM — Validate numeric input —
echo %selection% | findstr /R "^[0-9][0-9]*$" >nul || (
    echo Invalid selection.
    exit /b 1
)

REM — Validate range —
if %selection% LSS 1 (
    echo Invalid selection.
    exit /b 1
)
if %selection% GTR %count% (
    echo Invalid selection.
    exit /b 1
)

set "VM=!vm[%selection%]!"
echo Configuring: %VM%

REM — Enable bidirectional clipboard —
VBoxManage controlvm "%VM%" clipboard bidirectional

REM — Take a “clean-install” snapshot —
set "SNAP=clean-install"
VBoxManage snapshot "%VM%" take "%SNAP%" --description "After initial provisioning"

echo.
echo ✅  Clipboard set and snapshot "%SNAP%" taken for VM "%VM%".
endlocal
