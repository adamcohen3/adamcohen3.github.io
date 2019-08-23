@echo off
cls
set __network_path=.\
set __with_title=
if "%~d0" == "\\" set __network_path=%~dp0

echo %__network_path% | %windir%\system32\find.exe " " > nul
if %ERRORLEVEL% == 0 set __with_title=1 

set Both_found=1
set QV_found=0
set HRS_found=0
set GX_found=0

if exist "%__network_path%DiscView.htm" set QV_found=1
if exist "%__network_path%data\Viewer\bin\AliHRS.exe" set HRS_found=1 
if exist "%__network_path%data\Viewer\AliDiskViewer.exe" set GX_found=1 

ver | %windir%\system32\find.exe "ersion 5." > nul
if %ERRORLEVEL% == 0 goto setviewer

ver | %windir%\system32\find.exe "ersion 6." > nul
if %ERRORLEVEL% == 0 goto setviewer

ver | %windir%\system32\find.exe "ersion 7." > nul
if %ERRORLEVEL% == 0 goto setviewer

ver | %windir%\system32\find.exe "ersion 10." > nul
if %ERRORLEVEL% == 0 goto setviewer

set HRS_found=0

:setviewer
if %QV_found% == 0 set Both_found=0
if %HRS_found% == 1 goto start
if %GX_found% == 1 goto start
set Both_found=0

:start
if "%1" NEQ "" goto %1
if "%TMP%" NEQ "" goto tmp
if "%TEMP%" NEQ "" goto temp
goto media

:tmp
if exist "%TMP%\ALI_USER_CONFIG\QV.lch" goto qv
if exist "%TMP%\ALI_USER_CONFIG\AV.lch" goto av
goto media

:temp
if exist "%TEMP%\ALI_USER_CONFIG\QV.lch" goto qv
if exist "%TEMP%\ALI_USER_CONFIG\AV.lch" goto av

:media
if not exist "%__network_path%data\start.bat" goto choose
type "%__network_path%data\start.bat" | %windir%\system32\find.exe "qv" > nul
if %ERRORLEVEL%==0 goto qv
type "%__network_path%data\start.bat" | %windir%\system32\find.exe "av" > nul
if %ERRORLEVEL%==0 goto av

:choose
if %Both_found% == 0 goto av
if exist "%__network_path%data\ali\AliPageHolder.exe" goto common
goto av

:common
%windir%\system32\taskkill.exe /F /IM alihrs.exe > nul 2>&1
%windir%\system32\taskkill.exe /F /IM alisal.exe > nul 2>&1
if "%__with_title%" NEQ "" goto title_common
start /D %__network_path%data\ali %__network_path%data\ali\AliPageHolder.exe .\HTML\McKesson Radiology Station Disc.htm
goto end
:title_common
start "%__network_path%data\ali\AliPageHolder.exe" /D "%__network_path%data\ali" "%__network_path%data\ali\AliPageHolder.exe" .\HTML\McKesson Radiology Station Disc.htm
goto end

:qv
if %QV_found% == 1 goto qvlch
if %HRS_found% == 1  goto hrslch
if %GX_found% == 1  goto gxlch
goto no_viewer

:av
if %HRS_found% == 1  goto hrslch
if %GX_found% == 1  goto gxlch
if %QV_found% == 1 goto qvlch
goto no_viewer

:qvlch
if "%__with_title%" NEQ "" goto title_qvlch
start %__network_path%data\ali\splashscreen.exe %__network_path%data\ali\logo\splash.bmp
start %__network_path%data\ali\AliPageHolder.exe ..\..\DiscView.htm
goto end
:title_qvlch
start "%__network_path%data\ali\splashscreen.exe" "%__network_path%data\ali\splashscreen.exe" %__network_path%data\ali\logo\splash.bmp
start "%__network_path%data\ali\AliPageHolder.exe" "%__network_path%data\ali\AliPageHolder.exe" ..\..\DiscView.htm
goto end

:gxlch
if "%__with_title%" NEQ "" goto title_gxlch
start %__network_path%data\Viewer\AliDiskViewer.exe
goto end
:title_gxlch
start "%__network_path%data\Viewer\AliDiskViewer.exe" "%__network_path%data\Viewer\AliDiskViewer.exe"
goto end

:hrslch
%windir%\system32\taskkill.exe /F /IM alihrs.exe > nul 2>&1
%windir%\system32\taskkill.exe /F /IM alisal.exe > nul 2>&1
if "%__network_path%" NEQ ".\" goto hrsnet
cd .\data\Viewer\bin
start AVLaunch.exe
goto end
:hrsnet
if "%__with_title%" NEQ "" goto title_hrslch
start /D %__network_path%data\Viewer\bin %__network_path%data\Viewer\bin\AVLaunch.exe
goto end
:title_hrslch
start "%__network_path%data\Viewer\bin\AVLaunch.exe" /D "%__network_path%data\Viewer\bin" "%__network_path%data\Viewer\bin\AVLaunch.exe"
goto end

:no_viewer
echo.
echo.
echo.
echo *****************************
echo *****************************
echo.
echo *****************************
echo.
echo NO VIEWER WAS FOUND. QUIT
echo.
echo *****************************
echo.
echo *****************************
echo *****************************
pause

:end
set Both_found=
set QV_found=
set HRS_found=
set GX_found=
set __network_path=
set __with_title=