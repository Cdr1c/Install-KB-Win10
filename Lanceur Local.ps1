Param(
[Parameter(Mandatory=$False)]
[ValidateSet('Non','SiNecessaire','Force')]
[string]$Reboot_Consigne="SiNecessaire"
)


#$net_dir = "\\WP063NAS0001.commun01.svc\pdtsecu$\Outils\PatchManagement\MaJ Postes - Generalisation"
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
$net_dir = "$scriptPath\NetworkShare"
$Script_file = "Install KB Windows v1.3.cmd"
$Script_hash = "4BC2249D7E19F5406AA0D515F5BAED7CBDC8BB433B65840B20C04DCDBD8DD633"
$Script_Check = $true
$Context_lancement = "SCCM GCA"
$local_dir= "c:\temp"


if ( -not (Test-Path -Path ($net_dir + "\" + $Script_file) ) )
{
    Write-Host "Script ""$Script_file"" non accessible"
    break
}

Remove-Item -Path "$local_dir\$Script_file" -Force 2> $null
Copy-Item -Path ($net_dir + "\" + $Script_file) -Destination $local_dir -Force

$local_Script_Hash = Get-FileHash -Path "$local_dir\$Script_file" -Algorithm SHA256

if ( -not ($Script_Check) -or ($local_Script_Hash.Hash -eq $Script_hash) )
{
    $local_WMI_Win32_ComputerSystem = Get-WmiObject Win32_ComputerSystem
    $local_DomainName = $local_WMI_Win32_ComputerSystem.Domain

    $NomExe = "cmd.exe"
    $MesVariables = "/C call ""$local_dir\$Script_file"" ""$Context_lancement"" ""$local_DomainName"" ""$Reboot_Consigne"" "
    $WorkingDir = "C:\Temp\"
    #Start-Process -FilePath $NomExe -ArgumentList $MesVariables -WorkingDirectory $WorkingDir -Wait
    $Commande = $NomExe + " " + $MesVariables
    $shell = New-Object -Com WScript.Shell
    $ObjExec = $shell.Exec($Commande)

    Start-Sleep 1 #Attente du script

    $i=1
    Write-Host "ProcessID : $($ObjExec.ProcessID)"
    Do 
    { 
        #Write-Host $i
        $i++
	    $MaLigne = $ObjExec.StdOut.ReadLine()
        Write-Host $MaLigne
	
	    
     }
     while ($ObjExec.StdOut.AtEndOfStream -ne $true)
}
else
{
    Write-Host "Script ""$Script_file"" hash incorrect"
}

Remove-Item -Path "$local_dir\$Script_file"
