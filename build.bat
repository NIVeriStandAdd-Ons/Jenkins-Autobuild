@echo off

REM Parameters are listed here. you do not need to add any parameters for the build to work, but if you need to add a later parameter like #5... you must add all the previous parameters too.
REM 1: specific labview version to build in. ex: "2012". value "0" means build in all versions >= source version
REM 2: path to append to the job's workspace before passing the workspace to the labview build VI. ex: "\FXP LLB". so the build VI works in this subdirectory. use "\" if you dont want a subdir.
REM 3: tells the labview build VI if it should skip copying from the "Built" dir after the build is done. "0", "f", "false", "n", "no" all mean skip the copy. anything else means copy
REM 4: specifies text that the labview build VI will look for after "autobuild" in the autobuild.csv file. ex: "pharlap" means it will look for autobuildpharlap.csv
REM 5: value 0 means skip the source version check before building. be careful only to specify this as 0 if you have specified a specific version with parameter 1

REM -- INITIALIZE VARIABLES --
setlocal
set SourceVer=0
set myTempErrLvl=0
set minBuildVer=2011
set maxBuildVer=2014
set stopAfterOneBuild=0

if [%5]==[] goto NOParam5
REM -- if param 5 equals 0, skip version check. 
if %5 EQU 0 (
	echo Skipping version check on request
	goto Build
	)
:NOParam5

REM -- GET PROJECT VERSION --
"%~dp0\Get Project LV Version\GetProjVersion.exe" -- "%WORKSPACE%%~2"
set SourceVer=%ERRORLEVEL%
if %SourceVer% GEQ %minBuildVer% (
	if %SourceVer% LEQ %maxBuildVer% (
		echo Source version detected at LabVIEW %SourceVer%
		goto BUILD
		)
	)
if %SourceVer% LSS %minBuildVer% (
	echo Source version is %SourceVer% and minimum build version is %minBuildVer%. Will only build in %minBuildVer% and higher.
	set SourceVer=%minBuildVer%
)
	
if %SourceVer% GTR %maxBuildVer% (
	echo Source version is %SourceVer% and maximum build version is %maxBuildVer%. Cannot build.
	set myTempErrLvl=%SourceVer%
	goto runexit
)

:BUILD
REM If no first parameter defined for this batch file call, skip the following version specific build code
if [%1]==[] goto %SourceVer%Build
REM if this parameter is 0, also skip the following version specific build code
if %1 EQU 0 goto %SourceVer%Build
REM If parameter 1 is defined, that means build in a specific version of LV. Make sure that version is greater than or equal to source and less than or equal to max build version
if %1 GEQ %SourceVer% (
	if %1 GEQ %minBuildVer% (
		if %1 LEQ %maxBuildVer% (
			echo Running specific version build: LabVIEW %1
			set stopAfterOneBuild=1
			goto %1Build
		)
	)
)
	
echo Error! Can't build in %1 when minimum build version is %minBuildVer%, maximum build version is %maxBuildVer% and source version is %SourceVer%.
set myTempErrLvl=1
goto runexit
	
:2011Build
CALL "%~dp0LabVIEWbuild.bat" 2011 %SourceVer% %2 %3 %4
set myTempErrLvl=%ERRORLEVEL%
IF %myTempErrLvl% NEQ 0 GOTO RUNEXIT
IF %stopAfterOneBuild% EQU 1 GOTO RUNEXIT

:2012Build
CALL "%~dp0LabVIEWbuild.bat" 2012 %SourceVer% %2 %3 %4
set myTempErrLvl=%ERRORLEVEL%
IF %myTempErrLvl% NEQ 0 GOTO RUNEXIT
IF %stopAfterOneBuild% EQU 1 GOTO RUNEXIT

:2013Build
CALL "%~dp0LabVIEWbuild.bat" 2013 %SourceVer% %2 %3 %4
set myTempErrLvl=%ERRORLEVEL%
IF %myTempErrLvl% NEQ 0 GOTO RUNEXIT
IF %stopAfterOneBuild% EQU 1 GOTO RUNEXIT

:2014Build
CALL "%~dp0LabVIEWbuild.bat" 2014 %SourceVer% %2 %3 %4
set myTempErrLvl=%ERRORLEVEL%
IF %myTempErrLvl% NEQ 0 GOTO RUNEXIT
IF %stopAfterOneBuild% EQU 1 GOTO RUNEXIT

:RUNEXIT
echo ERRORLEVEL = %myTempErrLvl%
EXIT /B %myTempErrLvl%