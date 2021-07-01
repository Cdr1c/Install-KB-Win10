@echo off
rem ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
rem :: Install KB Windows - Version 1.3
rem :: Utiliser pour installer les derniers KB references dans  le repertoire KBSource 
rem :: pour les versions Windows 10 cibles 
rem ::
rem :: call "Install KB Windows v1.3.cmd" Parametre1 Parametre2 Parametre3
rem :: Parametre1 : Information sur le source de l'execution (Obligatoire). Exemple : "SCCM GCA"
rem :: Parametre2 : Nom du Domaine du poste au format FQDN
rem :: Parametre3 : Consigne de Redemarrage du poste. Valeur : SiNecessaire, Force, Non
rem ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

rem :: Positionnement dans le repertoire temp de l'utilisateur et positionnement de l'environnement
setlocal
pushd "%temp%"

call :LNow
set sdate=%LNow_date%
set stime=%LNow_time%
set ldate=%LNow_date%
set ltime=%LNow_time%


set Param1=%~1
set Param2=%~2
set Param3=%~3

set Context=%Param1%
if "%Param1%". EQU "". echo *** Script "%~n0" Non Autorise
if "%Param1%". EQU "". exit /B 0
set DomainFQDN=%Param2%
if "%Param2%". EQU "". set DomainFQDN=Temp
set Reboot_Consigne=%Param3%
if "%Param3%". EQU "". set Reboot_Consigne=SiNecessaire

set KBSource=\\wp063nas0001.commun01.svc\pdtsecu$\Outils\PatchManagement\MaJ Postes - Generalisation\Windows10-x64
set KBDest=c:\temp\Windows10-x64\KB
set KBlog=c:\temp\Windows10-x64\Log
if not exist "%KBDest%" md "%KBDest%"
if not exist "%KBLog%" md "%KBLog%"
set logfile=%KBlog%\%COMPUTERNAME%_%~n0_%sdate%-%stime%.log

set RepLogCentral=\\wp063nas0001.commun01.svc\pdtsecu$\End-Point\Log\%DomainFQDN%\%COMPUTERNAME%
set RepMonitor=\\wp063nas0001.commun01.svc\pdtsecu$\End-Point\Ordonnancement\Install KB Windows
set FileMonitorEncours=%RepMonitor%\En cours\%COMPUTERNAME%.flag
set FileMonitorFini=%RepMonitor%\Fini\%COMPUTERNAME%.flag
set RepMonitorFini=%RepMonitor%\Fini\


echo.>>"%logfile%"
echo [%ldate% %ltime%] *** Debut Script "%~n0"
echo [%ldate% %ltime%] *** Debut Script "%~n0" >>"%logfile%"
echo [%ldate% %ltime%] *** Debut Script "%~n0" >>"%FileMonitorEncours%"

echo.>>"%logfile%"
echo [%ldate% %ltime%] *** Recuperation de la version de Windows10
echo [%ldate% %ltime%] *** Recuperation de la version de Windows10 >>"%logfile%"
echo [%ldate% %ltime%] *** Recuperation de la version de Windows10 >>"%FileMonitorEncours%"
echo [%ldate% %ltime%] Commande : for /F "delims=.] tokens=3" %%I in ('ver') do set Win10_build=%%I >>"%logfile%"
for /F "delims=.] tokens=3" %%I in ('ver') do set Win10_build=%%I
echo [%ldate% %ltime%] Commande : call :Win10_Version "%Win10_build%"  >>"%logfile%"
call :Win10_Version "%Win10_build%"

call :LNow
set ldate=%LNow_date%
set ltime=%LNow_time%
echo [%ldate% %ltime%] Build Windows10 : %Win10_build% >>"%logfile%
echo [%ldate% %ltime%] Version Windows10 : %Win10_Version% >>"%logfile%

echo.>>"%logfile%"
echo [%ldate% %ltime%] *** Copie des KB localement
echo [%ldate% %ltime%] *** Copie des KB localement >>"%logfile%"
echo [%ldate% %ltime%] *** Copie des KB localement >>"%FileMonitorEncours%"
echo [%ldate% %ltime%] Commande : robocopy "%KBSource%" "%KBDest%" *-v%Win10_Version%*.* /XA:H /MIR /W:1 /R:1 /NP >>"%logfile%"
robocopy "%KBSource%" "%KBDest%" *-v%Win10_Version%*.* /XA:H /MIR /W:1 /R:1 /NP >>"%logfile%" 2>&1
set err=%ERRORLEVEL%

call :LNow
set ldate=%LNow_date%
set ltime=%LNow_time%
echo [%ldate% %ltime%] Errorlevel : %err% >>"%logfile%

echo.>>"%logfile%"
echo [%ldate% %ltime%] *** Installation des KB
echo [%ldate% %ltime%] *** Installation des KB >>"%logfile%"
echo [%ldate% %ltime%] *** Installation des KB >>"%FileMonitorEncours%"
echo [%ldate% %ltime%] Commande : for /F "tokens=1" %%I in ('dir /B /O:N %KBDest%') do echo call :Install_KB "%%I"  >>"%logfile%"
for /F "tokens=1" %%I in ('dir /B /O:N %KBDest%') do call :Install_KB "%KBDest%\%%I" 

rem echo.>>"%logfile%"
rem echo [%ldate% %ltime%] *** Suppression des KB localement
rem echo [%ldate% %ltime%] *** Suppression des KB localement >>"%logfile%"
rem echo [%ldate% %ltime%] *** Suppression des KB localement >>"%FileMonitorEncours%"
rem echo [%ldate% %ltime%] Commande : rd /Q /S "%KBDest%"  >>"%logfile%"
rem rd /Q /S "%KBDest%" >>"%logfile%" 2>&1
rem set err=%ERRORLEVEL%
rem 
rem call :LNow
rem set ldate=%LNow_date%
rem set ltime=%LNow_time%
rem echo [%ldate% %ltime%] Errorlevel : %err% >>"%logfile%

echo.>>"%logfile%"
echo [%ldate% %ltime%] *** Le poste doit reboot : %Reboot%
echo [%ldate% %ltime%] *** Le poste doit reboot : %Reboot% >>"%logfile%"
echo [%ldate% %ltime%] *** Le poste doit reboot : %Reboot% >>"%FileMonitorEncours%"


echo.>>"%logfile%"
echo [%ldate% %ltime%] *** Declenchement d'une remontee d'info vers SCCM
echo [%ldate% %ltime%] *** Declenchement d'une remontee d'info vers SCCM >>"%logfile%"
echo [%ldate% %ltime%] *** Declenchement d'une remontee d'info vers SCCM >>"%FileMonitorEncours%"
echo [%ldate% %ltime%] Commande : WMIC /namespace:\\root\ccm path sms_client CALL TriggerSchedule "{00000000-0000-0000-0000-000000000108}" /NOINTERACTIVE >>"%logfile%"
WMIC /namespace:\\root\ccm path sms_client CALL TriggerSchedule "{00000000-0000-0000-0000-000000000108}" /NOINTERACTIVE >>"%logfile%" 2>&1
set err=%ERRORLEVEL%
call :LNow
set ldate=%LNow_date%
set ltime=%LNow_time%
echo [%ldate% %ltime%] Errorlevel : %err% >>"%logfile%

echo [%ldate% %ltime%] Commande : WMIC /namespace:\\root\ccm path sms_client CALL TriggerSchedule "{00000000-0000-0000-0000-000000000113}" /NOINTERACTIVE >>"%logfile%"
WMIC /namespace:\\root\ccm path sms_client CALL TriggerSchedule "{00000000-0000-0000-0000-000000000113}" /NOINTERACTIVE >>"%logfile%" 2>&1
set err=%ERRORLEVEL%
call :LNow
set ldate=%LNow_date%
set ltime=%LNow_time%
echo [%ldate% %ltime%] Errorlevel : %err% >>"%logfile%

echo [%ldate% %ltime%] Commande : WMIC /namespace:\\root\ccm path sms_client CALL TriggerSchedule "{00000000-0000-0000-0000-000000000001}" /NOINTERACTIVE >>"%logfile%"
WMIC /namespace:\\root\ccm path sms_client CALL TriggerSchedule "{00000000-0000-0000-0000-000000000001}" /NOINTERACTIVE >>"%logfile%" 2>&1
set err=%ERRORLEVEL%
call :LNow
set ldate=%LNow_date%
set ltime=%LNow_time%
echo [%ldate% %ltime%] Errorlevel : %err% >>"%logfile%

echo [%ldate% %ltime%] *** Traitement du Redemarrage du poste
echo [%ldate% %ltime%] *** Traitement du Redemarrage du poste >>"%logfile%"
echo [%ldate% %ltime%] *** Traitement du Redemarrage du poste >>"%FileMonitorEncours%"
echo [%ldate% %ltime%] *** Redemarrage necessaire : %Reboot%
echo [%ldate% %ltime%] *** Redemarrage necessaire : %Reboot% >>"%logfile%"
echo [%ldate% %ltime%] *** Redemarrage necessaire : %Reboot% >>"%FileMonitorEncours%"
echo [%ldate% %ltime%] *** Consigne pour le redemarrage : %Reboot_Consigne%
echo [%ldate% %ltime%] *** Consigne pour le redemarrage : %Reboot_Consigne% >>"%logfile%"
echo [%ldate% %ltime%] *** Consigne pour le redemarrage : %Reboot_Consigne% >>"%FileMonitorEncours%"
if /I "%Reboot_Consigne%". EQU "Force". echo [%ldate% %ltime%] Commande : if /I "%Reboot_Consigne%". EQU "Force". shutdown /r /t 600 /f /d 2:18 >>"%logfile%"
if /I "%Reboot_Consigne%". EQU "Force". shutdown /r /t 600 /f /d 2:18
if /I "%Reboot_Consigne%". EQU "SiNecessaire". if /I "%Reboot%". EQU "Oui". echo [%ldate% %ltime%] Commande : if /I "%Reboot%". EQU "Oui". if "%Reboot_Consigne%". EQU "Oui". shutdown /r /t 600 /f /d 2:18 >>"%logfile%"
if /I "%Reboot_Consigne%". EQU "SiNecessaire". if /I "%Reboot%". EQU "Oui". shutdown /r /t 600 /f /d 2:18
if /I "%Reboot_Consigne%". EQU "SiNecessaire". if /I "%Reboot%". EQU "Non". echo [%ldate% %ltime%] Commande : Pas de redemarrage >>"%logfile%"
if /I "%Reboot_Consigne%". EQU "Non". echo [%ldate% %ltime%] Commande : Pas de redemarrage >>"%logfile%"

echo.>>"%logfile%"
echo [%ldate% %ltime%] *** Copie de la log dans le repertoire central
echo [%ldate% %ltime%] *** Copie de la log dans le repertoire central >>"%logfile%"
echo [%ldate% %ltime%] *** Copie de la log dans le repertoire central >>"%FileMonitorEncours%"
echo [%ldate% %ltime%] Commande : if not exist "%RepLogCentral%" md "%RepLogCentral%" >>"%logfile%"
if not exist "%RepLogCentral%" md "%RepLogCentral%" >>"%logfile%" 2>&1
echo [%ldate% %ltime%] Commande : copy "%logfile%" "%RepLogCentral%" >>"%logfile%"
copy "%logfile%" "%RepLogCentral%" >>"%logfile%" 2>&1

echo [%ldate% %ltime%] *** Fin Script "%~n0"
echo [%ldate% %ltime%] *** Fin Script "%~n0" >>"%logfile%"
echo [%ldate% %ltime%] *** Fin Script "%~n0" >>"%FileMonitorEncours%"
type "%FileMonitorEncours%" >>"%FileMonitorFini%"
del "%FileMonitorEncours%" /F /Q >>"%logfile%" 2>&1
exit /B 0


:Win10_Version
set Version=%~1
set Win10_Version=Non_determiner
if %Version%. EQU 10240. set Win10_Version=1507
if %Version%. EQU 10586. set Win10_Version=1511
if %Version%. EQU 14393. set Win10_Version=1607
if %Version%. EQU 15063. set Win10_Version=1703
if %Version%. EQU 16299. set Win10_Version=1709
if %Version%. EQU 17134. set Win10_Version=1803
if %Version%. EQU 17763. set Win10_Version=1809
if %Version%. EQU 18362. set Win10_Version=1903
if %Version%. EQU 18363. set Win10_Version=1909
if %Version%. EQU 19041. set Win10_Version=2004
if %Version%. EQU 19042. set Win10_Version=20H2
if %Version%. EQU 19043. set Win10_Version=21H1
set Version=
exit /B 0


:Install_KB 
set NameKB=%~nx1
set InstallKB=%~1
set InstallLog=%KBlog%\%~n1.log

call :LNow
set ldate=%LNow_date%
set ltime=%LNow_time%

echo.>>"%logfile%"
echo [%ldate% %ltime%] ---- Installation du KB %NameKB%
echo [%ldate% %ltime%] ---- Installation du KB %NameKB% >>"%logfile%"
echo [%ldate% %ltime%] ---- Installation du KB %NameKB% >>"%FileMonitorEncours%"
echo [%ldate% %ltime%] Commande : wusa.exe "%InstallKB%" /norestart /quiet /log:"%InstallLog%" >>"%logfile%"
wusa.exe "%InstallKB%" /norestart /quiet /log:"%InstallLog%"
set err=%ERRORLEVEL%
call :Err_WUSA %err%

call :LNow
set ldate=%LNow_date%
set ltime=%LNow_time%
echo [%ldate% %ltime%] Errorlevel : %err%
echo [%ldate% %ltime%] Message : %Err_Txt%
echo [%ldate% %ltime%] Errorlevel : %err% >>"%logfile%
echo [%ldate% %ltime%] Message : %Err_Txt% >>"%logfile%
echo [%ldate% %ltime%] Errorlevel : %err% >>"%FileMonitorEncours%"
echo [%ldate% %ltime%] Message : %Err_Txt% >>"%FileMonitorEncours%"

set NameKB=
set InstallKB=
set InstallLog=
exit /B 0

:Err_WUSA
set Erreur=%~1
set Err_Txt=Non_determiner (Err=%Erreur%)
if %Reboot%. EQU . set Reboot=Non
if %Erreur%. EQU 2359302. set Err_Txt=KB deja installe
if %Erreur%. EQU -2145124329. set Err_Txt=KB Non requis
if %Erreur%. EQU 0. set Err_Txt=KB installe et operationnel
if %Erreur%. EQU 5. set Err_Txt=Utilisateur non administrateur
if %Erreur%. EQU 1618. set Err_Txt=Autre installation est déjà en cours
if %Erreur%. EQU 3010. set Err_Txt=KB necessite un reboot du poste
if %Erreur%. EQU 3010. set Reboot=Oui
set Erreur=
exit /B 0


:LNow
set LNow_date=%date%
set LNow_date=%LNow_date: =0%
set LNow_date=%LNow_date:/=%
set LNow_time=%time%
set LNow_time=%LNow_time: =0%
set LNow_time=%LNow_time::=%
set LNow_time=%LNow_time:~0,6%
exit /B 0
