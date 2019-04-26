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

$url         = "https://static.rust-lang.org/dist/2019-04-25/rust-1.34.1-i686-pc-windows-gnu.tar.gz"
$url64       = "https://static.rust-lang.org/dist/2019-04-25/rust-1.34.1-x86_64-pc-windows-gnu.tar.gz"

$packageArgs = @{
    packageName    = $packageName
    unzipLocation  = $toolsDir
    url            = $url
    checksum       = "fe9d75fa4965b5e93f1b69c28b8d214cd5111c38139d66defe16cb5ce50374b3"
    checksumType   = "sha256"
    url64bit       = $url64
    checksum64     = "3f89a61710a370772c4d8238ef73b363e05d4fa0882043fac2b4208f652eeca4"
    checksumType64 = "sha256"
}

# Note to the reader: Install-ChocolateyZipFile only extracts one layer,
# so it turns the tar.gz files that Rust distributes into bar tar files.
# Useless.
Install-ChocolateyZipPackage @packageArgs
Get-ChocolateyUnzip -FileFullPath $toolsDir/rust-$version-i686-pc-windows-gnu.tar -FileFullPath64 $toolsDir/rust-$version-x86_64-pc-windows-gnu.tar -Destination $toolsDir
rm $toolsDir/rust-$version-*.tar
# This is basically what install.sh does, though with less customizability,
# because we delegate to Chocolatey for things like uninstalling and deciding where $toolsDir is.
cd $toolsDir/rust-$version-*
cat components | foreach {
  $c = $_
  cat $toolsDir/rust-$version-*/$c/manifest.in | foreach {
    if ($_.StartsWith("file:")) {
      $f = $_.SubString(5)
      $d = (split-path -parent $f)
      if (!(test-path $toolsDir/$d)) { mkdir $toolsDir/$d }
      mv $toolsDir/rust-$version-*/$c/$f $toolsDir/$f
    }
    # The assumption is that a manifest with a `dir:` directive is the sole provider of that directory,
    # unlike other rust components, where we're expected to merge the directories together.
    # Only component I've found with a `dir:` directive, currently, is rust-docs.
    if ($_.StartsWith("dir:")) {
      $f = $_.SubString(4)
      $d = (split-path -parent $f)
      if (!(test-path $toolsDir/$d)) { mkdir $toolsDir/$d }
      mv $toolsDir/rust-$version-*/$c/$f $toolsDir/$f
    }
  }
}
cd $toolsDir
rm -recurse -force $toolsDir/rust-$version-*.tar
rm -recurse -force $toolsDir/rust-$version-*
