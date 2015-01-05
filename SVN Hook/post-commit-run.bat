SET REPOS=%1
SET REV=%2
SET CSCRIPT=%windir%\system32\cscript.exe
SET VBSCRIPT=C:\csvn\data\repositories\svn_repository\hooks\post-commit-hook-jenkins.vbs
SET SVNLOOK=C:\csvn\bin\svnlook.exe
SET JENKINS=http://hil-autobuild:8080/
"%CSCRIPT%" "%VBSCRIPT%" "%REPOS%" %2 "%SVNLOOK%" %JENKINS%