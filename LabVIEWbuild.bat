REM Arguments passed to LabVIEWbuild.bat are:
REM 1 - Version of LV to launch and build in
REM 2 - Source version of the code being built
REM 3 - Maximum version of LabVIEW that will be used in this autobuild run
REM 4 - OPTIONAL! - path to append to the job's workspace before passing the workspace to the labview build VI. ex: "\FXP LLB". so the build VI works in this subdirectory.
REM 5 - OPTIONAL! - tells the labview build VI if it should skip copying from the "Built" dir after the build is done. "0", "f", "false", "n", "no" all mean skip the copy. anything else means copy
REM 6 - OPTIONAL! - specifies text that the labview build VI will look for after "autobuild" in the autobuild.csv file. ex: "pharlap" means it will look for autobuildpharlap.csv

REM -- INITIALIZE VARIABLES --
set errorfile="%~dp0CI_%EXECUTOR_NUMBER%_Error%1.txt"
set runfile="%~dp0CI_%EXECUTOR_NUMBER%_Running%1.txt"
set mcfile="%~dp0CI_%EXECUTOR_NUMBER%_mc%1.txt"
set buildlogfile="%~dp0CI_%EXECUTOR_NUMBER%_buildlog%1.txt"
set myTempErrLvl=0
set mcLogExists=0

REM -- CREATE TMP FILES
echo. 2>%runfile%
echo. 2>%errorfile%
echo. 2>%mcfile%

REM -- RUN BUILD
echo Starting %1 build...
REM -- 2011 and later support unattended mode to prevent dialogs
REM -- Use start command to launch them and not wait for finish. This is imporatnt so we can get the build logs as it runs.

REM User arguments (after the --) passed to Build.vi are:
REM 1 - Build number
REM 2 - File to store error information into
REM 3 - File to delete when finished running
REM 4 - Workspace to autobuild in
REM 5 - Name of the job autobuilding
REM 6 - Source version of the code being built
REM 7 - Log file to store mass compile info into
REM 8 - Log file used to pass run-time information back to the batch file
REM 9 - Maximum version of LabVIEW that will be used in this autobuild run
REM 10 - OPTIONAL! - tells the labview build VI if it should skip copying from the "Built" dir after the build is done. "0", "f", "false", "n", "no" all mean skip the copy. anything else means copy
REM 11 - OPTIONAL! - specifies text that the labview build VI will look for after "autobuild" in the autobuild.csv file. ex: "pharlap" means it will look for autobuildpharlap.csv
START "" "C:\Program Files (x86)\National Instruments\LabVIEW %1\LabVIEW.exe" "%~dp0Build.vi" -unattended -- %BUILD_NUMBER% %errorfile% %runfile% "%WORKSPACE%%~4" "%JOB_NAME%" %2 %mcfile% %buildlogfile% %3 %5 %~6 

REM -- MONITOR BUILD, LOOP UNTIL BUILD IS FINISHED, use PING to act as a 'sleep' function for loop
:BUILDRUNNING
REM -- WAIT FOR 1 SECOND, WINDOWS DOESN'T HAVE A COMMAND LINE WAIT
PING 192.168.2.254 -n 1 -w 3000 >NUL
REM -- Check for a build log file from labview and if found dump the info to the console
if exist %buildlogfile% CALL "%~dp0parsebuildlog.bat" %buildlogfile%
if exist %runfile% goto BUILDRUNNING
echo LabVIEW %1 Stopped

REM -- CHECK FOR BUILD ERRORS
echo Checking for %1 build errors...
CALL "%~dp0checkerror.bat" %errorfile%
set myTempErrLvl=%ERRORLEVEL%
IF %myTempErrLvl% EQU 0 GOTO ERRDONE

echo ============ LabVIEW %1 Build Error Start ============ 
type %errorfile%
echo.
echo ============= LabVIEW %1 Build Error End =============
GOTO RUNEXIT

:ERRDONE

REM -- CHECK FOR BUILD MASS COMPILE LOG
echo Checking for any %1 mass compile logs...
CALL "%~dp0checkmc.bat" %mcfile%
set mcLogExists=%ERRORLEVEL%
IF %mcLogExists% EQU 0 GOTO MCDONE

echo ============ LabVIEW %1 Mass Compile Log Start ============ 
type %mcfile%
echo.
echo ============= LabVIEW %1 Mass Compile Log End =============

:MCDONE

:RUNEXIT
echo ERRORLEVEL = %myTempErrLvl%
EXIT /B %myTempErrLvl%