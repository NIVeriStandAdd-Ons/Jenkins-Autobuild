@echo off

REM -- CHECK FOR BUILD MASS COMPILE LOG
set size=%~z1

set mcChkLvl=0

REM check if size is set
IF "%size%." == "." goto RUNEXIT

REM check is size is zero
IF %size% EQU 0 goto RUNEXIT

REM size is greater than zero, set level to 1
set mcChkLvl=1
echo Mass compile log exists

:RUNEXIT
EXIT /B %mcChkLvl%