# Do not remove this test for UTF-8: if “Ω” doesn’t appear as greek uppercase omega letter enclosed in quotation marks, you should use an editor that supports UTF-8, not this one.

$ErrorActionPreference = 'Stop';

# Uninstall old versions of Rust.
if (Test-ProcessAdminRights) {
  Get-WmiObject -Class Win32_Product | Where-Object {
    ($_.Vendor -eq "The Rust Project Developers") -And ($_.Name -match "Rust")
  } | foreach {
    $_.Uninstall()
  }
}

$version     = $env:chocolateyPackageVersion
$packageName = $env:chocolateyPackageName
$toolsDir    = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$url         = "https://static.rust-lang.org/dist/2019-11-07/rust-1.39.0-i686-pc-windows-gnu.tar.gz"
$url64       = "https://static.rust-lang.org/dist/2019-11-07/rust-1.39.0-x86_64-pc-windows-gnu.tar.gz"

$packageArgs = @{
    packageName    = $packageName
    unzipLocation  = $toolsDir
    url            = $url
    checksum       = "fcb85f968b13dcb909a3cb197c8ca1aff36c5d75c625d7dbc99aa11f50d849a5"
    checksumType   = "sha256"
    url64bit       = $url64
    checksum64     = "0f7f50605786dc4ab02a33eb9ef840fd212d20ce395cb19886b7690608a15d1d"
    checksumType64 = "sha256"
}

$packageSrcArgs = @{
    packageName    = $packageName
    unzipLocation  = $toolsDir
    url            = "https://static.rust-lang.org/dist/2019-11-07/rust-src-1.39.0.tar.gz"
    checksum       = "068186f866703ffeae804a0642588a78a492f03b62c0113e6cdfcb4eeca56df6"
    checksumType   = "sha256"
}

# Updates require us to get rid of the existing installation
# https://chocolatey.org/packages/rust#comment-4632965834
if (Test-Path $toolsDir\bin) { rm -Recurse -Force $toolsDir\bin }
if (Test-Path $toolsDir\etc) { rm -Recurse -Force $toolsDir\etc }
if (Test-Path $toolsDir\lib) { rm -Recurse -Force $toolsDir\lib }
if (Test-Path $toolsDir\share) { rm -Recurse -Force $toolsDir\share }

# Note to the reader: Install-ChocolateyZipFile only extracts one layer,
# so it turns the tar.gz files that Rust distributes into bar tar files.
# Useless.
Install-ChocolateyZipPackage @packageArgs
Get-ChocolateyUnzip -FileFullPath $toolsDir/rust-1.39.0-i686-pc-windows-gnu.tar -FileFullPath64 $toolsDir/rust-1.39.0-x86_64-pc-windows-gnu.tar -Destination $toolsDir
Install-ChocolateyZipPackage @packageSrcArgs
Get-ChocolateyUnzip -FileFullPath $toolsDir/rust-src-1.39.0.tar -Destination $toolsDir
# This is basically what install.sh does, though with less customizability,
# because we delegate to Chocolatey for things like uninstalling and deciding where $toolsDir is.
function Install-RustPackage([string]$Directory) {
  cd $Directory
  cat components | foreach {
    $c = $_
    cat $Directory/$c/manifest.in | foreach {
      if ($_.StartsWith("file:")) {
        $f = $_.SubString(5)
        $d = (split-path -parent $f)
        if (!(test-path $toolsDir/$d)) { mkdir $toolsDir/$d }
        mv $Directory/$c/$f $toolsDir/$f
      }
      # The assumption is that a manifest with a `dir:` directive is the sole provider of that directory,
      # unlike other rust components, where we're expected to merge the directories together.
      # Only component I've found with a `dir:` directive, currently, is rust-docs.
      if ($_.StartsWith("dir:")) {
        $f = $_.SubString(4)
        $d = (split-path -parent $f)
        if (!(test-path $toolsDir/$d)) { mkdir $toolsDir/$d }
        mv $Directory/$c/$f $toolsDir/$f
      }
    }
  }
  cd $toolsDir
}
rm -recurse -force $toolsDir/rust-1.39.0-*.tar
rm -recurse -force $toolsDir/rust-src-1.39.0.tar
dir $toolsDir/rust-1.39.0-* | foreach { Install-RustPackage (join-path $_ '') }
Install-RustPackage $toolsDir/rust-src-1.39.0
rm -recurse -force $toolsDir/rust-1.39.0-*
rm -recurse -force $toolsDir/rust-src-1.39.0
# Mark gcc.exe, and its relatives, as not-for-shimming.
# https://chocolatey.org/packages/rust#comment-4690124900
$files = Get-ChildItem $toolsDir\lib\rustlib\ -include '*.exe' -recurse -name
foreach ($file in $files) {
  New-Item "$toolsDir\lib\rustlib\$file.ignore" -type file -force | Out-Null
}
