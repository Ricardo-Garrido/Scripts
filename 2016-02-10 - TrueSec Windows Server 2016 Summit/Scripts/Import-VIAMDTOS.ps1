<#
.Synopsis
    Script for Deployment Fundamentals Vol 6
.DESCRIPTION
    Script for Deployment Fundamentals Vol 6
.EXAMPLE
    C:\Setup\Scripts\Import-VIAMDTOS.ps1 -Path "E:\MDTBuildlab" -ISO 'C:\Setup\ISO\Windows 10 Enterprise x64 build 10240.iso' -MDTDestinationPath "Operating Systems\Windows 10" -MDTDestinationFolderName W10X64-B10240
.NOTES
    Created:	 2015-12-15
    Version:	 1.0

    Author - Mikael Nystrom
    Twitter: @mikael_nystrom
    Blog   : http://deploymentbunny.com

    Author - Johan Arwidmark
    Twitter: @jarwidmark
    Blog   : http://deploymentresearch.com

    Disclaimer:
    This script is provided "AS IS" with no warranties, confers no rights and 
    is not supported by the authors or Deployment Artist.
.LINK
    http://www.deploymentfundamentals.com
#>

[cmdletbinding(SupportsShouldProcess=$True)]
Param (
    [Parameter(Mandatory=$True,Position=0)]
    [ValidateScript({Test-Path $_})]
    $Path,

    [Parameter(Mandatory=$True,Position=1)]
    [ValidateScript({Test-Path $_})]
    $ISO,

    [Parameter(Mandatory=$True,Position=2)]
    $MDTDestinationPath,

    [Parameter(Mandatory=$True,Position=3)]
    $MDTDestinationFolderName
)

# Check for elevation
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "Oupps, you need to run this script from an elevated PowerShell prompt!`nPlease start the PowerShell prompt as an Administrator and re-run the script."
	Write-Warning "Aborting script..."
    throw
}

#Set Variables
Write-Verbose "Starting"
$COMPUTERNAME = $Env:COMPUTERNAME
$RootDrive = $Env:SystemDrive

# Create the MDT Build Lab Deployment Share
Import-Module "$RootDrive\Program Files\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1"
New-PSDrive -Name "DS001" -PSProvider "MDTProvider" -Root "$Path"

#Mount ISO
Mount-DiskImage -ImagePath $ISO
$ISOImage = Get-DiskImage -ImagePath $ISO | Get-Volume
$ISODrive = [string]$ISOImage.DriveLetter+":"

#Import OS
$ImportedOS = Import-MDTOperatingSystem -path "DS001:\$MDTDestinationPath" -SourcePath "$ISODrive" -DestinationFolder "$MDTDestinationFolderName"

#Dismount ISO
Dismount-DiskImage -ImagePath $ISO
