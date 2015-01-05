@echo off

REM -- CHECK FOR BUILD ERRORS
set size=%~z1

set errChkLvl=0

REM check if size is set
IF "%size%." == "." goto RUNEXIT

REM check is size is zero
IF %size% EQU 0 goto RUNEXIT

REM size is greater than zero, set error
set errChkLvl=1
echo Build error occurred

:RUNEXIT
REM set %myNumber% = %errChkLvl%
EXIT /B %errChkLvl%