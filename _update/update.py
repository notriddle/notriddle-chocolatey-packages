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
        "i686": channel["pkg"]["rust"]["target"]["i686-pc-windows-msvc"],
        "x86_64": channel["pkg"]["rust"]["target"]["x86_64-pc-windows-msvc"],
        "suffix": "-ms",
        "desc": "Visual Studio ABI"
    },
    {
        "i686": channel["pkg"]["rust"]["target"]["i686-pc-windows-gnu"],
        "x86_64": channel["pkg"]["rust"]["target"]["x86_64-pc-windows-gnu"],
        "suffix": "",
        "desc": "GNU ABI"
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
        nuspec = """\ufeff<?xml version="1.0"?>
<package xmlns="http://schemas.microsoft.com/packaging/2010/07/nuspec.xsd">
  <metadata>
    <id>rust%(suffix)s</id>
    <version>1.16.0</version>
    <title>Rust (%(desc)s)</title>
    <authors>Mozilla</authors>
    <owners>Mike Chaliy, Francisco Gómez, Michael Howell</owners>
    <licenseUrl>https://github.com/mozilla/rust/blob/master/LICENSE-MIT</licenseUrl>
    <projectUrl>https://www.rust-lang.org/</projectUrl>
    <iconUrl>http://www.rust-lang.org/logos/rust-logo-128x128-blk.png</iconUrl>
    <requireLicenseAcceptance>false</requireLicenseAcceptance>
    <description>Rust is a curly-brace, block-structured expression language. It visually resembles the C language family, but differs significantly in syntactic and semantic details. Its design is oriented toward concerns of “programming in the large”, that is, of creating and maintaining boundaries – both abstract and operational – that preserve large-system integrity, availability and concurrency. </description>
    <summary>A systems programming language that runs blazingly fast, prevents nearly all segfaults, and guarantees thread safety</summary>
    <tags>rust</tags>
  </metadata>
</package>""" % package
        nuspec_open.write(nuspec)
    package32_url = package["i686"]["url"].replace("tar.gz", "msi")
    package32_sha256 = requests.get(package32_url + ".sha256").text.split(" ")[0]
    package64_url = package["x86_64"]["url"].replace("tar.gz", "msi")
    package64_sha256 = requests.get(package64_url + ".sha256").text.split(" ")[0]
    with codecs.open(package_path + "tools/chocolateyInstall.ps1", 'w', 'utf-8') as install_open:
        install = """\ufeff$PackageName = 'rust'
$InstallerType = 'msi'
$Url = '%(url)s'
$Checksum = '%(sha256)s'
$Url64 = "%(url64)s"
$Checksum64 = '%(sha256_64)s'
$ChecksumType = 'sha256'
$SilentArgs = '/quiet'
$ValidExitCodes = @(0,3010)
 
Install-ChocolateyPackage "$PackageName" "$InstallerType" "$SilentArgs" "$Url" "$Url64" `
    -checksum $Checksum -checksum64 $Checksum64 -checksumType $ChecksumType -checksumType64 $ChecksumType `
    -validExitCodes $ValidExitCodes""" % {"url": package32_url, "sha256": package32_sha256, "url64": package64_url, "sha256_64": package64_sha256}
        install_open.write(install)
