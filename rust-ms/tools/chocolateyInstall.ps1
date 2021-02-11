# Do not remove this test for UTF-8: if “Ω” doesn’t appear as greek uppercase omega letter enclosed in quotation marks, you should use an editor that supports UTF-8, not this one.

$ErrorActionPreference = 'Stop';

$version     = $env:chocolateyPackageVersion
$packageName = $env:chocolateyPackageName
$toolsDir    = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$rustcUrl = "https://static.rust-lang.org/dist/2021-02-11/rustc-1.50.0-i686-pc-windows-msvc.tar.gz"
$rustcUrl64 = "https://static.rust-lang.org/dist/2021-02-11/rustc-1.50.0-x86_64-pc-windows-msvc.tar.gz"

$cargoUrl = "https://static.rust-lang.org/dist/2021-02-11/cargo-1.50.0-i686-pc-windows-msvc.tar.gz"
$cargoUrl64 = "https://static.rust-lang.org/dist/2021-02-11/cargo-1.50.0-x86_64-pc-windows-msvc.tar.gz"

$stdUrl = "https://static.rust-lang.org/dist/2021-02-11/rust-std-1.50.0-i686-pc-windows-msvc.tar.gz"
$stdUrl64 = "https://static.rust-lang.org/dist/2021-02-11/rust-std-1.50.0-x86_64-pc-windows-msvc.tar.gz"

$packageArgs = @{
    packageName    = $packageName
    unzipLocation  = $toolsDir
    url            = $rustcUrl
    checksum       = "271d7ae615ea93d67f83e21144011f9f3274069da80df4115ce94df313a8055d"
    checksumType   = "sha256"
    url64bit       = $rustcUrl64
    checksum64     = "d7f7607c9cd3e137a335904e1186345f4328a971588ee8a54838e32a35a38e3a"
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
    checksum       = "be85c24b19ba0a20ef21740d6c399c2f30401af597fa42ab8b9b20ebbb98d7ab"
    checksumType   = "sha256"
    url64bit       = $cargoUrl64
    checksum64     = "dbd97ac5645668149d4a32b0b5f6274934d95f8b6d6e6926b7de13ee869aeedb"
    checksumType64 = "sha256"
}

$packageStdArgs = @{
    packageName    = $packageName
    unzipLocation  = $toolsDir
    url            = $stdUrl
    checksum       = "6548ad251fef683c3f5a1d434d2caa57ce5bb7c6ffc415cc5b64806182e75cd0"
    checksumType   = "sha256"
    url64bit       = $stdUrl64
    checksum64     = "48e562e1de58bd45aa0d8a95173e159c588ee76b0164affdc0140c928b1994c1"
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
