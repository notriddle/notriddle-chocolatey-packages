# Do not remove this test for UTF-8: if “Ω” doesn’t appear as greek uppercase omega letter enclosed in quotation marks, you should use an editor that supports UTF-8, not this one.

$ErrorActionPreference = 'Stop';

$version     = "1.48.0"
$packageName = $env:chocolateyPackageName
$toolsDir    = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$rustcUrl = "https://static.rust-lang.org/dist/2020-11-19/rustc-1.48.0-i686-pc-windows-gnu.tar.gz"
$rustcUrl64 = "https://static.rust-lang.org/dist/2020-11-19/rustc-1.48.0-x86_64-pc-windows-gnu.tar.gz"

$cargoUrl = "https://static.rust-lang.org/dist/2020-11-19/cargo-1.48.0-i686-pc-windows-gnu.tar.gz"
$cargoUrl64 = "https://static.rust-lang.org/dist/2020-11-19/cargo-1.48.0-x86_64-pc-windows-gnu.tar.gz"

$stdUrl = "https://static.rust-lang.org/dist/2020-11-19/rust-std-1.48.0-i686-pc-windows-gnu.tar.gz"
$stdUrl64 = "https://static.rust-lang.org/dist/2020-11-19/rust-std-1.48.0-x86_64-pc-windows-gnu.tar.gz"

$packageArgs = @{
    packageName    = $packageName
    unzipLocation  = $toolsDir
    url            = $rustcUrl
    checksum       = "16f707e06dec35d9724798f26543ecc186acd5751dd908a8dad68f357291c0e0
"
    checksumType   = "sha256"
    url64bit       = $rustcUrl64
    checksum64     = "4a66b17fc7984b73fb74ad30276ad9f9ad8a0da8ecb1074da8cb1db6adc98bb8
"
    checksumType64 = "sha256"
}

$packageSrcArgs = @{
    packageName    = $packageName
    unzipLocation  = $toolsDir
    url            = "https://static.rust-lang.org/dist/2020-11-19/rust-src-1.48.0.tar.gz"
    checksum       = "e8f15bdfcb5ced76ae40dd9aa6b387d5f9cece82b7a340cdcaa353fbc94f53da
"
    checksumType   = "sha256"
}

$packageCargoArgs = @{
    packageName    = $packageName
    unzipLocation  = $toolsDir
    url            = $cargoUrl
    checksum       = "57f457d937495aa6736bdddd319c27bb9f05473890785e2b7021dad8cb163dd2
"
    checksumType   = "sha256"
    url64bit       = $cargoUrl64
    checksum64     = "51535a1b4ec28a2d9960f4b04490a6b27a0ee6758782e5ab197199738227a66e
"
    checksumType64 = "sha256"
}

$packageStdArgs = @{
    packageName    = $packageName
    unzipLocation  = $toolsDir
    url            = $stdUrl
    checksum       = "cd9666419a65b8f51707cbbea47e687f2182b2c272e21a3474db5b83d04d9266
"
    checksumType   = "sha256"
    url64bit       = $stdUrl64
    checksum64     = "d000cf4425bbb7210e5c57e973d805222cedca86477ce7463b75647551209343
"
    checksumType64 = "sha256"
}

$packageMingwArgs = @{
    packageName    = $packageName
    unzipLocation  = $toolsDir
    url            = "https://static.rust-lang.org/dist/2020-11-19/rust-mingw-1.48.0-i686-pc-windows-gnu.tar.gz"
    checksum       = "77be767f332ea873a4e975aba201ebe1baa8a0f3c09d90a5ec40b22a04332181
"
    checksumType   = "sha256"
    url64bit       = "https://static.rust-lang.org/dist/2020-11-19/rust-mingw-1.48.0-x86_64-pc-windows-gnu.tar.gz"
    checksum64     = "3aa9e206099906fa0b8240e1011abe8b5150fe42689694d7a7d974a7c7ebc000
"
    checksumType64 = "sha256"
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
Get-ChocolateyUnzip -FileFullPath $toolsDir/rustc-$version-i686-pc-windows-gnu.tar -FileFullPath64 $toolsDir/rustc-$version-x86_64-pc-windows-gnu.tar -Destination $toolsDir
Install-ChocolateyZipPackage @packageSrcArgs
Get-ChocolateyUnzip -FileFullPath $toolsDir/rust-src-$version.tar -Destination $toolsDir
Install-ChocolateyZipPackage @packageCargoArgs
Get-ChocolateyUnzip -FileFullPath $toolsDir/cargo-$version-i686-pc-windows-gnu.tar -FileFullPath64 $toolsDir/cargo-$version-x86_64-pc-windows-gnu.tar -Destination $toolsDir
Install-ChocolateyZipPackage @packageStdArgs
Get-ChocolateyUnzip -FileFullPath $toolsDir/rust-std-$version-i686-pc-windows-gnu.tar -FileFullPath64 $toolsDir/rust-std-$version-x86_64-pc-windows-gnu.tar -Destination $toolsDir
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
rm -recurse -force $toolsDir/rustc-$version-*.tar
rm -recurse -force $toolsDir/rust-src-$version.tar
rm -recurse -force $toolsDir/rust-std-$version-*.tar
rm -recurse -force $toolsDir/cargo-$version-*.tar
dir $toolsDir/rustc-$version-* | foreach { Install-RustPackage (join-path $_ '') }
dir $toolsDir/cargo-$version-* | foreach { Install-RustPackage (join-path $_ '') }
dir $toolsDir/rust-std-$version-* | foreach { Install-RustPackage (join-path $_ '') }
Install-RustPackage $toolsDir/rust-src-$version
rm -recurse -force $toolsDir/rustc-$version-*
rm -recurse -force $toolsDir/cargo-$version-*
rm -recurse -force $toolsDir/rust-std-$version-*
rm -recurse -force $toolsDir/rust-src-$version
if ("https://static.rust-lang.org/dist/2020-11-19/rust-mingw-1.48.0-i686-pc-windows-gnu.tar.gz" -ne "") {
  Install-ChocolateyZipPackage @packageMingwArgs
  Get-ChocolateyUnzip -FileFullPath $toolsDir/rust-mingw-$version-i686-pc-windows-gnu.tar -FileFullPath64 $toolsDir/rust-mingw-$version-x86_64-pc-windows-gnu.tar -Destination $toolsDir
  rm -recurse -force $toolsDir/rust-mingw-$version-*.tar
  dir $toolsDir/rust-mingw-$version-* | foreach { Install-RustPackage (join-path $_ '') }
  rm -recurse -force $toolsDir/rust-mingw-$version-*
}
# Mark gcc.exe, and its relatives, as not-for-shimming.
# https://chocolatey.org/packages/rust#comment-4690124900
$files = Get-ChildItem $toolsDir\lib\rustlib\ -include '*.exe' -recurse -name
foreach ($file in $files) {
  New-Item "$toolsDir\lib\rustlib\$file.ignore" -type file -force | Out-Null
}
