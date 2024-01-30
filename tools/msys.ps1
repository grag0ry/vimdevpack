$ErrorActionPreference="Stop"
$Verbose = $false

$PackDir = Split-Path -Path $(Split-Path $script:MyInvocation.MyCommand.Path) -Parent
$DevenvDir = Join-Path -Path $PackDir -ChildPath "devenv"
$MsysDir = Join-Path -Path $DevenvDir -ChildPath "msys64"
$MSysSrc = "https://repo.msys2.org/distrib"
$MSysPkg = "msys2-x86_64-latest.sfx.exe"

function main
{
    param([switch]$Reinstall, [switch]$Verbose)
    if ($Verbose) { $VerbosePreference = 'Continue'; $Global:Verbose = $true; }
    Install-Msys2 -Reinstall:$Reinstall
    Invoke-Msys2 ($args -join " ")
}

function Install-Msys2
{
    param([switch]$Reinstall)
    if (Test-Path $MsysDir -PathType Container)
    {
        if ($Reinstall)
        {
            Write-Host "Cleaning destination dir ..."
            Get-ChildItem $MsysDir | Remove-Item -recurse -force
        }
        else
        {
            return
        }
    }
    Get-Msys2
    Invoke-Msys2 "pacman --noconfirm -S make git mingw-w64-ucrt-x86_64-gcc mingw-w64-ucrt-x86_64-python mingw-w64-ucrt-x86_64-python-requests unzip"
}

function Get-Msys2
{
    $url = $MSysSrc + "/" + $MSysPkg
    $pkg = Join-Path $DevenvDir -Child $MSysPkg
    New-Item -Path $DevenvDir -ItemType "directory" -Force -Verbose:$Verbose | out-null
    Write-Host "Downloading $url ..."
    (New-Object System.Net.WebClient).DownloadFile($url, $pkg)
    Write-Host "Extracting $pkg ..."
    & "$pkg" x -o"$DevenvDir"
}

function Invoke-Msys2
{
    param([string]$cmd)
    $batch = Join-Path $MsysDir -Child "msys2_shell.cmd"
    if ($cmd)
    {
        & $batch -defterm -here -ucrt64 -no-start -shell bash -l -c "$cmd"
    }
    else
    {
        & $batch -defterm -here -ucrt64 -no-start -shell bash
    }
}

main @args
