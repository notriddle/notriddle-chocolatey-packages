from __future__ import unicode_literals
import codecs
import requests
import toml
import sys
import os
import shutil

url = "https://static.rust-lang.org/dist/"
channel_file = "channel-rust-stable.toml"
packages_path = "../"

channel_sha256 = requests.get(url + channel_file + ".sha256")

if channel_sha256.status_code != 200:
    print("Failed to fetch channel sha256. Status code: " + str(channel_sha256.status_code))
    sys.exit(1)

try:
    with open("tmp/" + channel_file + ".sha256", 'rU') as channel_sha256_open:
        if channel_sha256_open.read() == channel_sha256.text:
            print("Nothing to do.")
            sys.exit(0)
except IOError:
    print("Unable to check the existing sha256; continuing")

with open("tmp/" + channel_file + ".sha256", 'w') as channel_sha256_open:
    channel_sha256_open.write(channel_sha256.text)

channel = requests.get(url + channel_file)

if channel.status_code != 200:
    print("Failed to fetch channel. Status code: " + str(channel.status_code))
    sys.exit(1)

with open("tmp/" + channel_file, 'w') as channel_open:
    channel_open.write(channel.text)

channel = toml.loads(channel.text)

assert(channel["manifest-version"] == "2")

version = channel["pkg"]["rust"]["version"].split(" ")[0]

packages = [
    {
        "rustc32": channel["pkg"]["rustc"]["target"]["i686-pc-windows-msvc"],
        "rustc64": channel["pkg"]["rustc"]["target"]["x86_64-pc-windows-msvc"],
        "cargo32": channel["pkg"]["cargo"]["target"]["i686-pc-windows-msvc"],
        "cargo64": channel["pkg"]["cargo"]["target"]["x86_64-pc-windows-msvc"],
        "std32": channel["pkg"]["rust-std"]["target"]["i686-pc-windows-msvc"],
        "std64": channel["pkg"]["rust-std"]["target"]["x86_64-pc-windows-msvc"],
        "suffix": "-ms",
        "platform": "pc-windows-msvc",
        "desc": "Visual Studio ABI",
        "version": version
    },
    {
        "rustc32": channel["pkg"]["rustc"]["target"]["i686-pc-windows-gnu"],
        "rustc64": channel["pkg"]["rustc"]["target"]["x86_64-pc-windows-gnu"],
        "cargo32": channel["pkg"]["cargo"]["target"]["i686-pc-windows-gnu"],
        "cargo64": channel["pkg"]["cargo"]["target"]["x86_64-pc-windows-gnu"],
        "std32": channel["pkg"]["rust-std"]["target"]["i686-pc-windows-gnu"],
        "std64": channel["pkg"]["rust-std"]["target"]["x86_64-pc-windows-gnu"],
        "suffix": "",
        "platform": "pc-windows-gnu",
        "desc": "GNU ABI",
        "version": version
    }
]

for package in packages:
    package_path = packages_path + "rust" + package["suffix"] + "/"
    try:
        shutil.rmtree(package_path)
    except IOError:
        pass
    os.mkdir(package_path)
    os.mkdir(package_path + "/tools")
    with codecs.open(package_path + "rust" + package["suffix"] + ".nuspec", 'w', 'utf-8') as nuspec_open:
        nuspec = """\ufeff<?xml version="1.0" encoding="utf-8"?>
<!-- Do not remove this test for UTF-8: if “Ω” doesn’t appear as greek uppercase omega letter enclosed in quotation marks, you should use an editor that supports UTF-8, not this one. -->
<package xmlns="http://schemas.microsoft.com/packaging/2010/07/nuspec.xsd">
  <metadata>
    <id>rust%(suffix)s</id>
    <version>%(version)s</version>
    <title>Rust (%(desc)s)</title>
    <authors>Mozilla</authors>
    <owners>Mike Chaliy, Francisco Gómez, Michael Howell</owners>
    <licenseUrl>https://github.com/rust-lang/rust/blob/master/LICENSE-MIT</licenseUrl>
    <projectUrl>https://www.rust-lang.org/</projectUrl>
    <projectSourceUrl>https://github.com/rust-lang/rust</projectSourceUrl>
    <bugTrackerUrl>https://github.com/rust-lang/rust/issues</bugTrackerUrl>
    <packageSourceUrl>https://github.com/notriddle/notriddle-chocolatey-packages/</packageSourceUrl>
    <iconUrl>http://www.rust-lang.org/logos/rust-logo-128x128-blk.png</iconUrl>
    <requireLicenseAcceptance>false</requireLicenseAcceptance>
    <description>Rust is a curly-brace, block-structured expression language. It visually resembles the C language family, but differs significantly in syntactic and semantic details. Its design is oriented toward concerns of “programming in the large”, that is, of creating and maintaining boundaries – both abstract and operational – that preserve large-system integrity, availability and concurrency. </description>
    <summary>A systems programming language that runs blazingly fast, prevents nearly all segfaults, and guarantees thread safety</summary>
    <tags>rust cli portable programming language sdk</tags>
    <releaseNotes>https://github.com/rust-lang/rust/blob/master/RELEASES.md</releaseNotes>
  </metadata>
</package>""" % package
        nuspec_open.write(nuspec)
    rustc32_url = package["rustc32"]["url"]
    rustc32_sha256 = requests.get(rustc32_url + ".sha256").text.split(" ")[0]
    rustc64_url = package["rustc64"]["url"]
    rustc64_sha256 = requests.get(rustc64_url + ".sha256").text.split(" ")[0]
    cargo32_url = package["cargo32"]["url"]
    cargo32_sha256 = requests.get(cargo32_url + ".sha256").text.split(" ")[0]
    cargo64_url = package["cargo64"]["url"]
    cargo64_sha256 = requests.get(cargo64_url + ".sha256").text.split(" ")[0]
    std32_url = package["std32"]["url"]
    std32_sha256 = requests.get(std32_url + ".sha256").text.split(" ")[0]
    std64_url = package["std64"]["url"]
    std64_sha256 = requests.get(std64_url + ".sha256").text.split(" ")[0]
    src_url = channel["pkg"]["rust-src"]["target"]["*"]["url"]
    src_sha256 = requests.get(src_url + ".sha256").text.split(" ")[0]
    if package["platform"] == "pc-windows-gnu":
        mingw32_url = channel["pkg"]["rust-mingw"]["target"]["i686-pc-windows-gnu"]["url"]
        mingw32_sha256 = requests.get(mingw32_url + ".sha256").text.split(" ")[0]
        mingw64_url = channel["pkg"]["rust-mingw"]["target"]["x86_64-pc-windows-gnu"]["url"]
        mingw64_sha256 = requests.get(mingw64_url + ".sha256").text.split(" ")[0]
    else:
        mingw32_url = ""
        mingw32_sha256 = ""
        mingw64_url = ""
        mingw64_sha256 = ""
    with codecs.open(package_path + "tools/chocolateyInstall.ps1", 'w', 'utf-8') as install_open:
        install = """\ufeff# Do not remove this test for UTF-8: if “Ω” doesn’t appear as greek uppercase omega letter enclosed in quotation marks, you should use an editor that supports UTF-8, not this one.

$ErrorActionPreference = 'Stop';

$version     = $env:chocolateyPackageVersion
$packageName = $env:chocolateyPackageName
$toolsDir    = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"

$rustcUrl = "%(rustc_url)s"
$rustcUrl64 = "%(rustc_url64)s"

$cargoUrl = "%(cargo_url)s"
$cargoUrl64 = "%(cargo_url64)s"

$stdUrl = "%(std_url)s"
$stdUrl64 = "%(std_url64)s"

$packageArgs = @{
    packageName    = $packageName
    unzipLocation  = $toolsDir
    url            = $rustcUrl
    checksum       = "%(rustc_sha256)s"
    checksumType   = "sha256"
    url64bit       = $rustcUrl64
    checksum64     = "%(rustc_sha256_64)s"
    checksumType64 = "sha256"
}

$packageSrcArgs = @{
    packageName    = $packageName
    unzipLocation  = $toolsDir
    url            = "%(src_url)s"
    checksum       = "%(src_sha256)s"
    checksumType   = "sha256"
}

$packageCargoArgs = @{
    packageName    = $packageName
    unzipLocation  = $toolsDir
    url            = $cargoUrl
    checksum       = "%(cargo_sha256)s"
    checksumType   = "sha256"
    url64bit       = $cargoUrl64
    checksum64     = "%(cargo_sha256_64)s"
    checksumType64 = "sha256"
}

$packageStdArgs = @{
    packageName    = $packageName
    unzipLocation  = $toolsDir
    url            = $stdUrl
    checksum       = "%(std_sha256)s"
    checksumType   = "sha256"
    url64bit       = $stdUrl64
    checksum64     = "%(std_sha256_64)s"
    checksumType64 = "sha256"
}

$packageMingwArgs = @{
    packageName    = $packageName
    unzipLocation  = $toolsDir
    url            = "%(mingw32_url)s"
    checksum       = "%(mingw32_sha256)s"
    checksumType   = "sha256"
    url64bit       = "%(mingw64_url)s"
    checksum64     = "%(mingw64_sha256)s"
    checksumType64 = "sha256"
}

# Updates require us to get rid of the existing installation
# https://chocolatey.org/packages/rust#comment-4632965834
if (Test-Path $toolsDir\\bin) { rm -Recurse -Force $toolsDir\\bin }
if (Test-Path $toolsDir\\etc) { rm -Recurse -Force $toolsDir\\etc }
if (Test-Path $toolsDir\\lib) { rm -Recurse -Force $toolsDir\\lib }
if (Test-Path $toolsDir\\share) { rm -Recurse -Force $toolsDir\\share }

# Note to the reader: Install-ChocolateyZipFile only extracts one layer,
# so it turns the tar.gz files that Rust distributes into bar tar files.
# Useless.
Install-ChocolateyZipPackage @packageArgs
Get-ChocolateyUnzip -FileFullPath $toolsDir/rustc-$version-i686-%(platform)s.tar -FileFullPath64 $toolsDir/rustc-$version-x86_64-%(platform)s.tar -Destination $toolsDir
Install-ChocolateyZipPackage @packageSrcArgs
Get-ChocolateyUnzip -FileFullPath $toolsDir/rust-src-$version.tar -Destination $toolsDir
Install-ChocolateyZipPackage @packageCargoArgs
Get-ChocolateyUnzip -FileFullPath $toolsDir/cargo-$version-i686-%(platform)s.tar -FileFullPath64 $toolsDir/cargo-$version-x86_64-%(platform)s.tar -Destination $toolsDir
Install-ChocolateyZipPackage @packageStdArgs
Get-ChocolateyUnzip -FileFullPath $toolsDir/rust-std-$version-i686-%(platform)s.tar -FileFullPath64 $toolsDir/rust-std-$version-x86_64-%(platform)s.tar -Destination $toolsDir
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
if ("%(mingw32_url)s" -ne "") {
  Install-ChocolateyZipPackage @packageMingwArgs
  Get-ChocolateyUnzip -FileFullPath $toolsDir/rust-mingw-$version-i686-%(platform)s.tar -FileFullPath64 $toolsDir/rust-mingw-$version-x86_64-%(platform)s.tar -Destination $toolsDir
  rm -recurse -force $toolsDir/rust-mingw-$version-*.tar
  dir $toolsDir/rust-mingw-$version-* | foreach { Install-RustPackage (join-path $_ '') }
  rm -recurse -force $toolsDir/rust-mingw-$version-*
}
# Mark gcc.exe, and its relatives, as not-for-shimming.
# https://chocolatey.org/packages/rust#comment-4690124900
$files = Get-ChildItem $toolsDir\\lib\\rustlib\\ -include '*.exe' -recurse -name
foreach ($file in $files) {
  New-Item "$toolsDir\\lib\\rustlib\\$file.ignore" -type file -force | Out-Null
}
""" % {
    "rustc_url": rustc32_url, "rustc_sha256": rustc32_sha256, "rustc_url64": rustc64_url, "rustc_sha256_64": rustc64_sha256,
    "cargo_url": cargo32_url, "cargo_sha256": cargo32_sha256, "cargo_url64": cargo64_url, "cargo_sha256_64": cargo64_sha256,
    "std_url": std32_url, "std_sha256": std32_sha256, "std_url64": std64_url, "std_sha256_64": std64_sha256,
    "mingw32_url": mingw32_url, "mingw32_sha256": mingw32_sha256, "mingw64_url": mingw64_url, "mingw64_sha256": mingw64_sha256,
    "src_url": src_url, "src_sha256": src_sha256, "platform": package["platform"]}
        install_open.write(install)
