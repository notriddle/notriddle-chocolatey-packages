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

---

Since the chars author does not publish binaries, this Chocolatey package is built to have reproducible builds.

LICENSE.txt is taken directly from <https://github.com/antifuchs/chars/blob/v$Version/LICENSE>.
It had sha256 $LicenseSha256 when pulled.

To reproduce the chars.exe executable, install the MSVC Build Tools, the MSVC Rust compiler,
and the [ducible](https://github.com/jasonwhite/ducible) CLI tool.
chars.exe had sha256 $ExeSha256 after built.

The MSVC build tools, and the Rust compiler, can both be installed directly using Chocolatey:

    PS> choco install rust-ms --version 1.40.0
    PS> choco install visualcppbuildtools --version 14.0.25420.1

Ducible is not currently available as a Chocolatey package. I downloaded it from <https://github.com/jasonwhite/ducible/releases>.

    PS> Invoke-WebRequest https://github.com/jasonwhite/ducible/releases/download/v1.2.2/ducible-windows-x64-Release.zip -OutFile ducible.zip
    PS> `$shell = New-Object -Com shell.application
    PS> `$zip = `$shell.NameSpace("`$PWD\ducible.zip")
    PS> foreach (`$item in `$zip.items()) { `$shell.NameSpace("C:\ProgramData\chocolatey\bin\").CopyHere(`$item) }

Then, after installing the toolchain, download the correct git tag version for this system, build it in release mode, and run ducible on it:

    PS> git clone --branch=v$Version https://github.com/antifuchs/chars
    PS> cd chars
    PS> cargo build --release
    PS> ducible target\release\chars.exe
    PS> cp target\release\chars.exe ..
    PS> cp LICENSE ..\LICENSE.txt

You can now verify that your hashes match mine using PowerShell's Get-FileHash applet.

    PS> `$LicenseSha256 = (Get-FileHash -Path ..\LICENSE.txt -Algorithm sha256).Hash
    PS> `$LicenseSha256 -Eq "$LicenseSha256"
    True
    PS> `$ExeSha256 = (Get-FileHash -Path ..\chars.exe -Algorithm sha256).Hash
    PS> `$ExeSha256 -Eq "$ExeSha256"
    True
"@

echo $VerificationText > VERIFICATION.txt

cd ..
