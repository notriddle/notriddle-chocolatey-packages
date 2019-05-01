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

with open ("../rust-release-notes.txt", "r") as notes:
    release_notes = "".join(notes.readlines())

packages = [
    {
        "i686": channel["pkg"]["rust"]["target"]["i686-pc-windows-msvc"],
        "x86_64": channel["pkg"]["rust"]["target"]["x86_64-pc-windows-msvc"],
        "suffix": "-ms",
        "platform": "pc-windows-msvc",
        "desc": "Visual Studio ABI",
        "version": version,
        "release_notes": release_notes
    },
    {
        "i686": channel["pkg"]["rust"]["target"]["i686-pc-windows-gnu"],
        "x86_64": channel["pkg"]["rust"]["target"]["x86_64-pc-windows-gnu"],
        "suffix": "",
        "platform": "pc-windows-gnu",
        "desc": "GNU ABI",
        "version": version,
        "release_notes": release_notes
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
    <iconUrl>http://www.rust-lang.org/logos/rust-logo-128x128-blk.png</iconUrl>
    <requireLicenseAcceptance>false</requireLicenseAcceptance>
    <description>Rust is a curly-brace, block-structured expression language. It visually resembles the C language family, but differs significantly in syntactic and semantic details. Its design is oriented toward concerns of “programming in the large”, that is, of creating and maintaining boundaries – both abstract and operational – that preserve large-system integrity, availability and concurrency. </description>
    <summary>A systems programming language that runs blazingly fast, prevents nearly all segfaults, and guarantees thread safety</summary>
    <tags>rust cli portable programming language sdk</tags>
    <releaseNotes><![CDATA[%(release_notes)s]]></releaseNotes>
  </metadata>
</package>""" % package
        nuspec_open.write(nuspec)
    package32_url = package["i686"]["url"]
    package32_sha256 = requests.get(package32_url + ".sha256").text.split(" ")[0]
    package64_url = package["x86_64"]["url"]
    package64_sha256 = requests.get(package64_url + ".sha256").text.split(" ")[0]
    src_url = channel["pkg"]["rust-src"]["target"]["*"]["url"]
    src_sha256 = requests.get(src_url + ".sha256").text.split(" ")[0]
    with codecs.open(package_path + "tools/chocolateyInstall.ps1", 'w', 'utf-8') as install_open:
        install = """\ufeff# Do not remove this test for UTF-8: if “Ω” doesn’t appear as greek uppercase omega letter enclosed in quotation marks, you should use an editor that supports UTF-8, not this one.

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

$url         = "%(url)s"
$url64       = "%(url64)s"

$packageArgs = @{
    packageName    = $packageName
    unzipLocation  = $toolsDir
    url            = $url
    checksum       = "%(sha256)s"
    checksumType   = "sha256"
    url64bit       = $url64
    checksum64     = "%(sha256_64)s"
    checksumType64 = "sha256"
}

$packageSrcArgs = @{
    packageName    = $packageName
    unzipLocation  = $toolsDir
    url            = "%(src_url)s"
    checksum       = "%(src_sha256)s"
    checksumType   = "sha256"
}

# Note to the reader: Install-ChocolateyZipFile only extracts one layer,
# so it turns the tar.gz files that Rust distributes into bar tar files.
# Useless.
Install-ChocolateyZipPackage @packageArgs
Get-ChocolateyUnzip -FileFullPath $toolsDir/rust-$version-i686-%(platform)s.tar -FileFullPath64 $toolsDir/rust-$version-x86_64-%(platform)s.tar -Destination $toolsDir
Install-ChocolateyZipPackage @packageSrcArgs
Get-ChocolateyUnzip -FileFullPath $toolsDir/rust-src-$version.tar -Destination $toolsDir
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
rm -recurse -force $toolsDir/rust-$version-*.tar
rm -recurse -force $toolsDir/rust-src-$version.tar
dir $toolsDir/rust-$version-* | foreach { Install-RustPackage (join-path $_ '') }
Install-RustPackage $toolsDir/rust-src-$version
rm -recurse -force $toolsDir/rust-$version-*
rm -recurse -force $toolsDir/rust-src-$version
""" % {"url": package32_url, "sha256": package32_sha256, "url64": package64_url, "sha256_64": package64_sha256, "src_url": src_url, "src_sha256": src_sha256, "platform": package["platform"]}
        install_open.write(install)
