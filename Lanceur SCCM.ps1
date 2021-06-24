Param(
[Parameter(Mandatory=$False)]
[ValidateSet('Non','SiNecessaire','Force')]
[string]$Reboot_Consigne="Force"
)


$net_dir = "\\WP063NAS0001.commun01.svc\pdtsecu$\Outils\PatchManagement\MaJ Postes - Generalisation"
$Script_file = "Install KB Windows v1.2.cmd"
$Script_hash = "589C8E31289F6AE36A8C19BDEDDE23525AC988DA2A2D3A2103833E04A74EB97F"
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
