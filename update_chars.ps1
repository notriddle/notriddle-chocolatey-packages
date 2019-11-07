param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Version,
    [switch]$Confirm=$True
)

rm -recurse -force chars
mkdir chars

$SpecText = @"
<?xml version="1.0" encoding="utf-8"?>
<!-- Do not remove this test for UTF-8: if “Ω” doesn’t appear as greek uppercase omega letter enclosed in quotation marks, you should use an editor that supports UTF-8, not this one. -->
<package xmlns="http://schemas.microsoft.com/packaging/2010/07/nuspec.xsd">
  <metadata>
    <id>chars</id>
    <version>$Version</version>
    <title>cha(rs)</title>
    <authors>Andreas Fuchs</authors>
    <owners>Michael Howell</owners>
    <licenseUrl>https://github.com/antifuchs/chars/blob/master/LICENSE</licenseUrl>
    <projectUrl>https://github.com/antifuchs/chars</projectUrl>
    <projectSourceUrl>https://github.com/antifuchs/chars</projectSourceUrl>
    <packageSourceUrl>https://github.com/notriddle/notriddle-chocolatey-packages/</packageSourceUrl>
    <bugTrackerUrl>https://github.com/antifuchs/chars/issues</bugTrackerUrl>
    <requireLicenseAcceptance>false</requireLicenseAcceptance>
    <description>cha(rs) is a commandline tool to display information about unicode characters</description>
    <summary>A commandline tool to display information about unicode characters</summary>
    <tags>rust cli</tags>
    <releaseNotes>https://github.com/antifuchs/chars/releases</releaseNotes>
  </metadata>
</package>
"@

echo $SpecText > chars\chars.nuspec

cd chars
git clone --branch=v$Version https://github.com/antifuchs/chars
cd chars
cargo build --release
ducible target\release\chars.exe
cp target\release\chars.exe ..
cp LICENSE ..\LICENSE.txt
cd ..

$LicenseSha256 = (get-filehash -path LICENSE.txt -algorithm sha256).Hash
$ExeSha256 = (get-filehash -path chars.exe -algorithm sha256).Hash

$RustVersion = (rustc --version)
$RustCfg = (rustc -O --print cfg)

$VerificationText = @"
VERIFICATION
Verification is intended to assist the Chocolatey moderators and community
in verifying that this package's contents are trustworthy.

LICENSE.txt is taken directly from <https://github.com/antifuchs/chars/blob/v$Version/LICENSE>.
It had sha256 $LicenseSha256 when pulled.

chars.exe was built using the following toolchain when packaged.
To reproduce it, install the MSVC Build Tools, the MSVC Rust compiler (the rust-ms package works),
and the [ducible](https://github.com/jasonwhite/ducible) CLI tool.
It had sha256 $ExeSha256 after built.

PS> rustc --version
$RustVersion
PS> rustc -O --print cfg
$RustCfg
PS> cargo build --release
...
PS> ducible target\release\chars.exe
...
"@

echo $VerificationText > VERIFICATION.txt

cd ..
