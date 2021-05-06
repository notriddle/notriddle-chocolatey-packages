# Do not remove this test for UTF-8: if “Ω” doesn’t appear as greek uppercase omega letter enclosed in quotation marks, you should use an editor that supports UTF-8, not this one.

$ErrorActionPreference = 'Stop';

$version     = $env:chocolateyPackageVersion
$packageName = $env:chocolateyPackageName
$toolsDir    = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$rustcUrl = "https://static.rust-lang.org/dist/2021-05-06/rustc-1.52.0-i686-pc-windows-gnu.tar.gz"
$rustcUrl64 = "https://static.rust-lang.org/dist/2021-05-06/rustc-1.52.0-x86_64-pc-windows-gnu.tar.gz"

$cargoUrl = "https://static.rust-lang.org/dist/2021-05-06/cargo-1.52.0-i686-pc-windows-gnu.tar.gz"
$cargoUrl64 = "https://static.rust-lang.org/dist/2021-05-06/cargo-1.52.0-x86_64-pc-windows-gnu.tar.gz"

$stdUrl = "https://static.rust-lang.org/dist/2021-05-06/rust-std-1.52.0-i686-pc-windows-gnu.tar.gz"
$stdUrl64 = "https://static.rust-lang.org/dist/2021-05-06/rust-std-1.52.0-x86_64-pc-windows-gnu.tar.gz"

$packageArgs = @{
    packageName    = $packageName
    unzipLocation  = $toolsDir
    url            = $rustcUrl
    checksum       = "119950716305b16e65f0b2c4d09d5b1147f02a20462d3a763faa82fdd330850c"
    checksumType   = "sha256"
    url64bit       = $rustcUrl64
    checksum64     = "e787b496ec7875fcc27d3c14ce8725501b4110b182fa62659fc8b375428a8007"
    checksumType64 = "sha256"
}

$packageSrcArgs = @{
    packageName    = $packageName
    unzipLocation  = $toolsDir
    url            = "https://static.rust-lang.org/dist/2021-05-06/rust-src-1.52.0.tar.gz"
    checksum       = "861dcbf1faf2faca5b5e3afea5bbcf453cbda4ae00bd34ae67bfc36463f9e227"
    checksumType   = "sha256"
}

$packageCargoArgs = @{
    packageName    = $packageName
    unzipLocation  = $toolsDir
    url            = $cargoUrl
    checksum       = "e0ad9c2f54409c3eed252ad3233a4c2382d68dd8e0ee1d4c311c7b4b53455401"
    checksumType   = "sha256"
    url64bit       = $cargoUrl64
    checksum64     = "d9ad7e2fd9903ddd2a73c0e274266d6ec1f4724db295fba1591f4abec7aaf0f5"
    checksumType64 = "sha256"
}

$packageStdArgs = @{
    packageName    = $packageName
    unzipLocation  = $toolsDir
    url            = $stdUrl
    checksum       = "bc3616849cb307fba109e20f477728e396b4d02f40e8786b15369481dd0d09da"
    checksumType   = "sha256"
    url64bit       = $stdUrl64
    checksum64     = "8af7a2f14331ec5b0a2ac14a1d6b774a7f32df0f2902cb8956203e4066440977"
    checksumType64 = "sha256"
}

$packageMingwArgs = @{
    packageName    = $packageName
    unzipLocation  = $toolsDir
    url            = "https://static.rust-lang.org/dist/2021-05-06/rust-mingw-1.52.0-i686-pc-windows-gnu.tar.gz"
    checksum       = "29371eb3eb6c8f0a5f77c2a1cf73a623941741e6db56d15acca71319e05100dc"
    checksumType   = "sha256"
    url64bit       = "https://static.rust-lang.org/dist/2021-05-06/rust-mingw-1.52.0-x86_64-pc-windows-gnu.tar.gz"
    checksum64     = "010a03fde8b69eaf56948bdd1b51b35cc4c73b6e55d0f9d4346d195de0c10a6c"
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
if ("https://static.rust-lang.org/dist/2021-05-06/rust-mingw-1.52.0-i686-pc-windows-gnu.tar.gz" -ne "") {
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
