# Do not remove this test for UTF-8: if “Ω” doesn’t appear as greek uppercase omega letter enclosed in quotation marks, you should use an editor that supports UTF-8, not this one.

$ErrorActionPreference = 'Stop';

$version     = $env:chocolateyPackageVersion
$packageName = $env:chocolateyPackageName
$toolsDir    = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$rustcUrl = "https://static.rust-lang.org/dist/2021-02-11/rustc-1.50.0-i686-pc-windows-gnu.tar.gz"
$rustcUrl64 = "https://static.rust-lang.org/dist/2021-02-11/rustc-1.50.0-x86_64-pc-windows-gnu.tar.gz"

$cargoUrl = "https://static.rust-lang.org/dist/2021-02-11/cargo-1.50.0-i686-pc-windows-gnu.tar.gz"
$cargoUrl64 = "https://static.rust-lang.org/dist/2021-02-11/cargo-1.50.0-x86_64-pc-windows-gnu.tar.gz"

$stdUrl = "https://static.rust-lang.org/dist/2021-02-11/rust-std-1.50.0-i686-pc-windows-gnu.tar.gz"
$stdUrl64 = "https://static.rust-lang.org/dist/2021-02-11/rust-std-1.50.0-x86_64-pc-windows-gnu.tar.gz"

$packageArgs = @{
    packageName    = $packageName
    unzipLocation  = $toolsDir
    url            = $rustcUrl
    checksum       = "404ab1e701621715c5c2e98186ff5a3663a1eb5bb680c95436c15faee1d7d3ab"
    checksumType   = "sha256"
    url64bit       = $rustcUrl64
    checksum64     = "19a26721587469772797713fb740b3bdf949c47a128c3f605b279ab2ec59dac1"
    checksumType64 = "sha256"
}

$packageSrcArgs = @{
    packageName    = $packageName
    unzipLocation  = $toolsDir
    url            = "https://static.rust-lang.org/dist/2021-02-11/rust-src-1.50.0.tar.gz"
    checksum       = "678e140e88656f19a49aa802eb6e1ea117a520c6f3eb0da265a7dc6e0c012a9c"
    checksumType   = "sha256"
}

$packageCargoArgs = @{
    packageName    = $packageName
    unzipLocation  = $toolsDir
    url            = $cargoUrl
    checksum       = "018aa452cc4f5629c7c85df2de2661660aa7830e18b5793f5f8f5b935dcc9786"
    checksumType   = "sha256"
    url64bit       = $cargoUrl64
    checksum64     = "9db2a297c25fdd9d2fd399fbfbf1b0ba9291d11e7fa2f431b35449676e836375"
    checksumType64 = "sha256"
}

$packageStdArgs = @{
    packageName    = $packageName
    unzipLocation  = $toolsDir
    url            = $stdUrl
    checksum       = "4b39eeb3f3e2ff35b7e368aaf0209543f7ec38643f94da9b19ea85caaa70da59"
    checksumType   = "sha256"
    url64bit       = $stdUrl64
    checksum64     = "631a8d6525cc2e8c7c6c458ac646ac43342e392b8918119bd0fdc230f1550c67"
    checksumType64 = "sha256"
}

$packageMingwArgs = @{
    packageName    = $packageName
    unzipLocation  = $toolsDir
    url            = "https://static.rust-lang.org/dist/2021-02-11/rust-mingw-1.50.0-i686-pc-windows-gnu.tar.gz"
    checksum       = "576ccd3849f5e997371394ce95e3d6cf89bec1998b6b3c96087e6c1a1a035679"
    checksumType   = "sha256"
    url64bit       = "https://static.rust-lang.org/dist/2021-02-11/rust-mingw-1.50.0-x86_64-pc-windows-gnu.tar.gz"
    checksum64     = "123272800833fa52e353de785293307c5005b0b2c08d53b2d567ebcc147807c9"
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
if ("https://static.rust-lang.org/dist/2021-02-11/rust-mingw-1.50.0-i686-pc-windows-gnu.tar.gz" -ne "") {
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
