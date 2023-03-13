@echo off
set bot_host=%1
set bot_home=%2
set branch=%3

set curdir=%CD%

cd ..\..\..\..\bot
set botrepo=%CD%

cd %botrepo%\Scripts
call setup_repos -T -n

cd %curdir%

:: get fds hash of lastest successful firebot run

call :getfile FDS_HASH
set /p fds_hash=<fds_hash
cd ..\..\..\..\fds
set fdsrepo=%CD%
git checkout -b %branch% %fds_hash%
git describe --dirty --long | gawk -F"-" "{print $1\"-\"$2}" > fds_version
set /p fds_version=<fds_version
cd %curdir%

:: get smv hash of lastest successful firebot run

call :getfile SMV_HASH
set /p smv_hash=<smv_hash
cd ..\..\..\..\smv
set smvrepo=%CD%
git checkout -b %branch% %smv_hash%
git describe --dirty --long | gawk -F"-" "{print $1\"-\"$2}" > smv_version
set /p smv_version=<smv_version
cd %curdir%

echo fds_version=%fds_version%
echo smv_version=%smv_version%
pause

call make_fds_progs.bat
cd %fdsrepo%
git checkout master

call make_smv_progs.bat
cd %smvrepo%
git checkout master

call copy_apps firebot
call copy_apps smokebot
call copy_pubs firebot  .firebot/pubs  %bot_host%
call copy_pubs smokebot .smokebot/pubs %bot_host%

call make_bundle
goto eof

::-----------------------------------------------------------------------
:getfile
::-----------------------------------------------------------------------
set file=%1
if exist %HASHDIR%\%file% erase %HASHDIR%\%file%

echo gh release download %GH_FDS_TAG% -p %type% -R github.com/%GH_OWNER%/%GH_REPO% -D %PDFS%
gh release download %GH_FDS_TAG% -p %file% -R github.com/%GH_OWNER%/%GH_REPO% -D %PDFS%

if NOT exist %PDFS%\%file% echo failed
if exist %PDFS%\%file% echo succeeded
exit /b


:eof

