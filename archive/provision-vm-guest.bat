rem provision-vm-guest.bat

setlocal EnableDelayedExpansion

rem ensure VBoxManage is on your PATH
set "PATH=C:\Program Files\Oracle\VirtualBox;%PATH%"

rem Gather all registered VM names into vm1, vm2, … vm%count%
set count=0
for /f "tokens=1" %%A in ('VBoxManage list vms') do (
    set /a count+=1
    set "vm!count!=%%~A"
)

if !count! EQU 0 (
    echo No VirtualBox VMs found.
    endlocal
    exit /b 1
)

rem Display numbered menu
echo Available VirtualBox VMs:
for /L %%i in (1,1,!count!) do (
    echo    %%i) !vm%%i!
)

rem Prompt until we get a valid number
:choose
set /p selection=Select a VM by number: 
echo !selection!| findstr /R "^[0-9][0-9]*$" >nul || (
    echo Invalid input.& goto choose
)
if !selection! LSS 1 (
    echo Number out of range.& goto choose
)
if !selection! GTR !count! (
    echo Number out of range.& goto choose
)

rem Lookup the chosen VM name
set "VM=!vm%selection%!"
echo Configuring: %VM%

rem Enable bidirectional clipboard
VBoxManage controlvm "%VM%" clipboard bidirectional

rem Take a "clean-install" snapshot
VBoxManage snapshot "%VM%" take "clean-install" --description "After initial provisioning"

echo.
echo Clipboard enabled and snapshot "clean-install" taken for VM "%VM%".
endlocal
