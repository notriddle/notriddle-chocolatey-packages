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

$url         = "https://static.rust-lang.org/dist/2019-04-25/rust-1.34.1-i686-pc-windows-msvc.tar.gz"
$url64       = "https://static.rust-lang.org/dist/2019-04-25/rust-1.34.1-x86_64-pc-windows-msvc.tar.gz"

$packageArgs = @{
    packageName    = $packageName
    unzipLocation  = $toolsDir
    url            = $url
    checksum       = "139233502977bb319c8cd28f9ef17b814747a2bc78c559284aa7df8bc78fed6e"
    checksumType   = "sha256"
    url64bit       = $url64
    checksum64     = "3b771a51f680bdf38e8e799fb3d9a76370be02e5968a55f7650a96bda7a4a0f5"
    checksumType64 = "sha256"
}

# Note to the reader: Install-ChocolateyZipFile only extracts one layer,
# so it turns the tar.gz files that Rust distributes into bar tar files.
# Useless.
Install-ChocolateyZipPackage @packageArgs
Get-ChocolateyUnzip -FileFullPath $toolsDir/rust-$version-i686-pc-windows-msvc.tar -FileFullPath64 $toolsDir/rust-$version-x86_64-pc-windows-msvc.tar -Destination $toolsDir
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
