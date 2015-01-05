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
START "" "C:\Program Files (x86)\National Instruments\LabVIEW %1\LabVIEW.exe" "%~dp0Build.vi" -unattended -- %BUILD_NUMBER% %errorfile% %runfile% "%WORKSPACE%%~3" "%JOB_NAME%" %2 %mcfile% %buildlogfile% %4 %~5

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