# Do not remove this test for UTF-8: if “Ω” doesn’t appear as greek uppercase omega letter enclosed in quotation marks, you should use an editor that supports UTF-8, not this one.

$ErrorActionPreference = 'Stop';

$version     = $env:chocolateyPackageVersion
$packageName = $env:chocolateyPackageName
$toolsDir    = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$rustcUrl = "https://static.rust-lang.org/dist/2022-08-11/rustc-1.63.0-i686-pc-windows-msvc.tar.gz"
$rustcUrl64 = "https://static.rust-lang.org/dist/2022-08-11/rustc-1.63.0-x86_64-pc-windows-msvc.tar.gz"

$cargoUrl = "https://static.rust-lang.org/dist/2022-08-11/cargo-1.63.0-i686-pc-windows-msvc.tar.gz"
$cargoUrl64 = "https://static.rust-lang.org/dist/2022-08-11/cargo-1.63.0-x86_64-pc-windows-msvc.tar.gz"

$stdUrl = "https://static.rust-lang.org/dist/2022-08-11/rust-std-1.63.0-i686-pc-windows-msvc.tar.gz"
$stdUrl64 = "https://static.rust-lang.org/dist/2022-08-11/rust-std-1.63.0-x86_64-pc-windows-msvc.tar.gz"

$packageArgs = @{
    packageName    = $packageName
    unzipLocation  = $toolsDir
    url            = $rustcUrl
    checksum       = "9e1c3ac7afc988bcee8c4150c4675b250cadc8e71b48e66e17c7a3a49bea54d2"
    checksumType   = "sha256"
    url64bit       = $rustcUrl64
    checksum64     = "258e22e8b6500038b421ed328dd844856409b78a3c76585b02b6d22b62dd818d"
    checksumType64 = "sha256"
}

$packageSrcArgs = @{
    packageName    = $packageName
    unzipLocation  = $toolsDir
    url            = "https://static.rust-lang.org/dist/2022-08-11/rust-src-1.63.0.tar.gz"
    checksum       = "bb5e585be3f02a1e994b7a372b071b3d00c7e0ff71c1f5fb2cdee353717dde8a"
    checksumType   = "sha256"
}

$packageCargoArgs = @{
    packageName    = $packageName
    unzipLocation  = $toolsDir
    url            = $cargoUrl
    checksum       = "a8de56d2e823209212cb50f82c2d457869f99a9760b10222ea2c55ace0407c7b"
    checksumType   = "sha256"
    url64bit       = $cargoUrl64
    checksum64     = "5b1d2d8ef410f218f1ecf5e853bd218cf6f40e3b3f46b04f477875c125821956"
    checksumType64 = "sha256"
}

$packageStdArgs = @{
    packageName    = $packageName
    unzipLocation  = $toolsDir
    url            = $stdUrl
    checksum       = "648a23e13c4e51026456679822c91a69ea11b637f5dbd9e896e79aadd05cd573"
    checksumType   = "sha256"
    url64bit       = $stdUrl64
    checksum64     = "e72b994d365e02242f2ef50cca73019c5c7ec57f55585b4f02e819a5cfd204f1"
    checksumType64 = "sha256"
}

$packageMingwArgs = @{
    packageName    = $packageName
    unzipLocation  = $toolsDir
    url            = ""
    checksum       = ""
    checksumType   = "sha256"
    url64bit       = ""
    checksum64     = ""
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
Get-ChocolateyUnzip -FileFullPath $toolsDir/rustc-$version-i686-pc-windows-msvc.tar -FileFullPath64 $toolsDir/rustc-$version-x86_64-pc-windows-msvc.tar -Destination $toolsDir
Install-ChocolateyZipPackage @packageSrcArgs
Get-ChocolateyUnzip -FileFullPath $toolsDir/rust-src-$version.tar -Destination $toolsDir
Install-ChocolateyZipPackage @packageCargoArgs
Get-ChocolateyUnzip -FileFullPath $toolsDir/cargo-$version-i686-pc-windows-msvc.tar -FileFullPath64 $toolsDir/cargo-$version-x86_64-pc-windows-msvc.tar -Destination $toolsDir
Install-ChocolateyZipPackage @packageStdArgs
Get-ChocolateyUnzip -FileFullPath $toolsDir/rust-std-$version-i686-pc-windows-msvc.tar -FileFullPath64 $toolsDir/rust-std-$version-x86_64-pc-windows-msvc.tar -Destination $toolsDir
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
if ("" -ne "") {
  Install-ChocolateyZipPackage @packageMingwArgs
  Get-ChocolateyUnzip -FileFullPath $toolsDir/rust-mingw-$version-i686-pc-windows-msvc.tar -FileFullPath64 $toolsDir/rust-mingw-$version-x86_64-pc-windows-msvc.tar -Destination $toolsDir
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
