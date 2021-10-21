# Do not remove this test for UTF-8: if “Ω” doesn’t appear as greek uppercase omega letter enclosed in quotation marks, you should use an editor that supports UTF-8, not this one.

$ErrorActionPreference = 'Stop';

$version     = $env:chocolateyPackageVersion
$packageName = $env:chocolateyPackageName
$toolsDir    = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$rustcUrl = "https://static.rust-lang.org/dist/2021-10-21/rustc-1.56.0-i686-pc-windows-gnu.tar.gz"
$rustcUrl64 = "https://static.rust-lang.org/dist/2021-10-21/rustc-1.56.0-x86_64-pc-windows-gnu.tar.gz"

$cargoUrl = "https://static.rust-lang.org/dist/2021-10-21/cargo-1.56.0-i686-pc-windows-gnu.tar.gz"
$cargoUrl64 = "https://static.rust-lang.org/dist/2021-10-21/cargo-1.56.0-x86_64-pc-windows-gnu.tar.gz"

$stdUrl = "https://static.rust-lang.org/dist/2021-10-21/rust-std-1.56.0-i686-pc-windows-gnu.tar.gz"
$stdUrl64 = "https://static.rust-lang.org/dist/2021-10-21/rust-std-1.56.0-x86_64-pc-windows-gnu.tar.gz"

$packageArgs = @{
    packageName    = $packageName
    unzipLocation  = $toolsDir
    url            = $rustcUrl
    checksum       = "47eec1cf3876fa4873242a3770f1e23569bf7825dfab531eb84aff6853885743"
    checksumType   = "sha256"
    url64bit       = $rustcUrl64
    checksum64     = "116b7dd1406c265d208f3099b0b2da8dc89bf5a4162839a82dc820466d2a7a1f"
    checksumType64 = "sha256"
}

$packageSrcArgs = @{
    packageName    = $packageName
    unzipLocation  = $toolsDir
    url            = "https://static.rust-lang.org/dist/2021-10-21/rust-src-1.56.0.tar.gz"
    checksum       = "00c2225d0e1d430b1632373c46448b1b69839032b8384684091bb9cce19b2ce6"
    checksumType   = "sha256"
}

$packageCargoArgs = @{
    packageName    = $packageName
    unzipLocation  = $toolsDir
    url            = $cargoUrl
    checksum       = "b071e491b7bd8d06f8f932e1aabe2630285db443281d9a5c93fbb68aec67be2d"
    checksumType   = "sha256"
    url64bit       = $cargoUrl64
    checksum64     = "78897a0548c0b9b141adc76b4c33d4153633136456aa3157692a4b2f02d20f64"
    checksumType64 = "sha256"
}

$packageStdArgs = @{
    packageName    = $packageName
    unzipLocation  = $toolsDir
    url            = $stdUrl
    checksum       = "b0d3261ab5e346237f5be54c39631b68dea7e65638986971a3041bb1afd00e28"
    checksumType   = "sha256"
    url64bit       = $stdUrl64
    checksum64     = "278934ce9967a30e4c6bcfc3f506b703f2da042a718065814965c8be2319311d"
    checksumType64 = "sha256"
}

$packageMingwArgs = @{
    packageName    = $packageName
    unzipLocation  = $toolsDir
    url            = "https://static.rust-lang.org/dist/2021-10-21/rust-mingw-1.56.0-i686-pc-windows-gnu.tar.gz"
    checksum       = "28be9e7d713c3cd8e25a1624dff861ba9fb40353b2bd8bb48da278579aa6da3a"
    checksumType   = "sha256"
    url64bit       = "https://static.rust-lang.org/dist/2021-10-21/rust-mingw-1.56.0-x86_64-pc-windows-gnu.tar.gz"
    checksum64     = "58ad773b5fdcc4161fc6011f77980b89cd576f257d096e89d67119df6dbbe4e7"
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
        mv -force $Directory/$c/$f $toolsDir/$f
      }
      # The assumption is that a manifest with a `dir:` directive is the sole provider of that directory,
      # unlike other rust components, where we're expected to merge the directories together.
      # Only component I've found with a `dir:` directive, currently, is rust-docs.
      if ($_.StartsWith("dir:")) {
        $f = $_.SubString(4)
        $d = (split-path -parent $f)
        if (!(test-path $toolsDir/$d)) { mkdir $toolsDir/$d }
        mv -force $Directory/$c/$f $toolsDir/$f
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
if ("https://static.rust-lang.org/dist/2021-10-21/rust-mingw-1.56.0-i686-pc-windows-gnu.tar.gz" -ne "") {
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
