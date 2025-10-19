#Shared for everyone
$uciChessDir = Join-Path $env:ProgramData "UCI-Chess"
$uciChessGuiDir = Join-Path $uciChessDir "GUI"
$uciChessEngineDir = Join-Path $uciChessDir "Engine"

$isAdmin = (New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if ($isAdmin) {
    $startMenuPath = Join-Path $env:ProgramData "Microsoft\Windows\Start Menu\Programs"
} else {
    $specialFolder = [System.Environment+SpecialFolder]::Programs
    $startMenuPath = [System.Environment]::GetFolderPath($specialFolder)
}

$uciChessShortcutDir = Join-Path $startMenuPath "UCI-Chess"

#Shared for this package

$uciChessPkgInstallDirName = "nibbler-windows"
$uciChessPkgInstallDir = Join-Path $uciChessGuiDir $uciChessPkgInstallDirName
$uciChessPkgExecPath = Join-Path $uciChessPkgInstallDir "nibbler.exe"

$uciChessPkgShortcutDir = Join-Path $uciChessShortcutDir "GUI"
$uciChessPkgShortcutPath = Join-Path $uciChessPkgShortcutDir "Nibbler.lnk"

#Individual for this script

if (Test-Path $uciChessPkgInstallDir) {
    "Removing old program installation"
    Remove-Item -Path $uciChessPkgInstallDir -Force -ErrorAction Stop -Recurse
}

if (Test-Path $uciChessPkgShortcutPath) {
    "Removing old shortcut"
    Remove-Item -Path $uciChessPkgShortcutPath
}

$packageArgs = @{
    PackageName    = 'ucichess-nibbler'
    ChecksumType   = 'sha256'
    Url64bit       = 'https://github.com/rooklift/nibbler/releases/download/v%%VERSION%%/nibbler-%%VERSION%%-windows.zip'
    Checksum64     = '%%CHECKSUM%%'
    ChecksumType64 = 'sha256'
    UnzipLocation  = "$uciChessGuiDir"
}

"Installing ZIP Package"
Install-ChocolateyZipPackage @packageArgs

"Renaming unpacked directory"
Move-Item $uciChessGuiDir\nibbler-%%VERSION%%-windows $uciChessPkgInstallDir

"Installing shortcut"
Install-ChocolateyShortcut -targetPath $uciChessPkgExecPath -ShortcutFilePath $uciChessPkgShortcutPath

"Installing engine maintenance script"
Copy-Item -Path (Join-Path $PSScriptRoot "sync-engines.ps1") -Destination $uciChessPkgInstallDir