# Do not remove this test for UTF-8: if “Ω” doesn’t appear as greek uppercase omega letter enclosed in quotation marks, you should use an editor that supports UTF-8, not this one.

$ErrorActionPreference = 'Stop';

$version     = $env:chocolateyPackageVersion
$packageName = $env:chocolateyPackageName
$toolsDir    = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$rustcUrl = "https://static.rust-lang.org/dist/2021-05-10/rustc-1.52.1-i686-pc-windows-gnu.tar.gz"
$rustcUrl64 = "https://static.rust-lang.org/dist/2021-05-10/rustc-1.52.1-x86_64-pc-windows-gnu.tar.gz"

$cargoUrl = "https://static.rust-lang.org/dist/2021-05-10/cargo-1.52.1-i686-pc-windows-gnu.tar.gz"
$cargoUrl64 = "https://static.rust-lang.org/dist/2021-05-10/cargo-1.52.1-x86_64-pc-windows-gnu.tar.gz"

$stdUrl = "https://static.rust-lang.org/dist/2021-05-10/rust-std-1.52.1-i686-pc-windows-gnu.tar.gz"
$stdUrl64 = "https://static.rust-lang.org/dist/2021-05-10/rust-std-1.52.1-x86_64-pc-windows-gnu.tar.gz"

$packageArgs = @{
    packageName    = $packageName
    unzipLocation  = $toolsDir
    url            = $rustcUrl
    checksum       = "45cb2e22d193b3ca26808009b81d07942a02bcf60fcc2e55db159c356b1fe77a"
    checksumType   = "sha256"
    url64bit       = $rustcUrl64
    checksum64     = "5dd155eeb4dc60fcd7542ddc1adcfbad1d759a9b32ea1fefa59cf26cd9d511ce"
    checksumType64 = "sha256"
}

$packageSrcArgs = @{
    packageName    = $packageName
    unzipLocation  = $toolsDir
    url            = "https://static.rust-lang.org/dist/2021-05-10/rust-src-1.52.1.tar.gz"
    checksum       = "34fb417e94aadbace368e934e1f079dd09f2423ccd6cc0cc519cdd55ef3fa8bf"
    checksumType   = "sha256"
}

$packageCargoArgs = @{
    packageName    = $packageName
    unzipLocation  = $toolsDir
    url            = $cargoUrl
    checksum       = "db0ee581622256ecd2993380869172b87567e1c8422b8cf7f277aadad260bcab"
    checksumType   = "sha256"
    url64bit       = $cargoUrl64
    checksum64     = "dc03e8a7b8997a372d96bfb1d32556e17a5fc015f4dc508e2da0d28456f91b5a"
    checksumType64 = "sha256"
}

$packageStdArgs = @{
    packageName    = $packageName
    unzipLocation  = $toolsDir
    url            = $stdUrl
    checksum       = "8f5d023f49d0d27c6e732476a40068d03cf7e25b0bf0c9ffe6e3abd254a6f19a"
    checksumType   = "sha256"
    url64bit       = $stdUrl64
    checksum64     = "7787f732d31b74227782b4bcf9c1f33c057256b769ca2b09fab0adcef4ea2dcb"
    checksumType64 = "sha256"
}

$packageMingwArgs = @{
    packageName    = $packageName
    unzipLocation  = $toolsDir
    url            = "https://static.rust-lang.org/dist/2021-05-10/rust-mingw-1.52.1-i686-pc-windows-gnu.tar.gz"
    checksum       = "6f2ec01ca615789e57b25384e9aec5b8e2e3ea331db60c59fe7a3efb148916a7"
    checksumType   = "sha256"
    url64bit       = "https://static.rust-lang.org/dist/2021-05-10/rust-mingw-1.52.1-x86_64-pc-windows-gnu.tar.gz"
    checksum64     = "119bed85e794f0ddc19c14b449cf3326a1cb87fab7795f8a92979b244b0cb178"
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
if ("https://static.rust-lang.org/dist/2021-05-10/rust-mingw-1.52.1-i686-pc-windows-gnu.tar.gz" -ne "") {
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
