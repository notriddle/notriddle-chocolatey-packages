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

$url         = "https://static.rust-lang.org/dist/2020-02-27/rust-1.41.1-i686-pc-windows-gnu.tar.gz"
$url64       = "https://static.rust-lang.org/dist/2020-02-27/rust-1.41.1-x86_64-pc-windows-gnu.tar.gz"

$packageArgs = @{
    packageName    = $packageName
    unzipLocation  = $toolsDir
    url            = $url
    checksum       = "1744ee246a39d0631db2bffef2cb9e42d16792324bc801a5917cad18ab0d5b5d"
    checksumType   = "sha256"
    url64bit       = $url64
    checksum64     = "48d1c06c2024f3a623081b42781f9ba86b4e8733a67a925e3705ce9f6dc08088"
    checksumType64 = "sha256"
}

$packageSrcArgs = @{
    packageName    = $packageName
    unzipLocation  = $toolsDir
    url            = "https://static.rust-lang.org/dist/2020-02-27/rust-src-1.41.1.tar.gz"
    checksum       = "fefed77800b250f43ce0e0660eac02ea7501450ebee943469fd1aec87d27b8a6"
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
Get-ChocolateyUnzip -FileFullPath $toolsDir/rust-$version-i686-pc-windows-gnu.tar -FileFullPath64 $toolsDir/rust-$version-x86_64-pc-windows-gnu.tar -Destination $toolsDir
Install-ChocolateyZipPackage @packageSrcArgs
Get-ChocolateyUnzip -FileFullPath $toolsDir/rust-src-$version.tar -Destination $toolsDir
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
rm -recurse -force $toolsDir/rust-$version-*.tar
rm -recurse -force $toolsDir/rust-src-$version.tar
dir $toolsDir/rust-$version-* | foreach { Install-RustPackage (join-path $_ '') }
Install-RustPackage $toolsDir/rust-src-$version
rm -recurse -force $toolsDir/rust-$version-*
rm -recurse -force $toolsDir/rust-src-$version
# Mark gcc.exe, and its relatives, as not-for-shimming.
# https://chocolatey.org/packages/rust#comment-4690124900
$files = Get-ChildItem $toolsDir\lib\rustlib\ -include '*.exe' -recurse -name
foreach ($file in $files) {
  New-Item "$toolsDir\lib\rustlib\$file.ignore" -type file -force | Out-Null
}
