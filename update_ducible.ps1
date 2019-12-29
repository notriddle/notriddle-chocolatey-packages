param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Version,
    [switch]$Confirm=$True
)

rm -recurse -force ducible
mkdir ducible

$SpecText = @"
<?xml version="1.0" encoding="utf-8"?>
<!-- Do not remove this test for UTF-8: if “Ω” doesn’t appear as greek uppercase omega letter enclosed in quotation marks, you should use an editor that supports UTF-8, not this one. -->
<package xmlns="http://schemas.microsoft.com/packaging/2010/07/nuspec.xsd">
  <metadata>
    <id>ducible</id>
    <version>$Version</version>
    <title>ducible</title>
    <authors>Jason White</authors>
    <owners>Michael Howell</owners>
    <licenseUrl>https://github.com/jasonwhite/ducible/blob/master/LICENSE</licenseUrl>
    <projectUrl>https://github.com/jasonwhite/ducible</projectUrl>
    <projectSourceUrl>https://github.com/jasonwhite/ducible</projectSourceUrl>
    <packageSourceUrl>https://github.com/notriddle/notriddle-chocolatey-packages/</packageSourceUrl>
    <bugTrackerUrl>https://github.com/jasonwhite/ducible/issues</bugTrackerUrl>
    <requireLicenseAcceptance>false</requireLicenseAcceptance>
    <description>This is a tool to make builds of Portable Executables (PEs) and PDBs reproducible.

Timestamps and other non-deterministic data are embedded in DLLs, EXEs, and PDBs. If some source is compiled and linked twice without changing any source, the binary and PDB will not be bit-for-bit identical both times. This tool fixes that by modifying DLLs/EXEs in-place and rewriting PDBs.

Don't worry, Ducible won't mess with the functionality of your executable. All changes have no functional effect. It merely transforms one perfectly good executable into another perfectly good, yet reproducible(!), executable.</description>
    <summary>A tool to make Windows builds reproducible.</summary>
    <tags>cli build tools</tags>
    <releaseNotes>https://github.com/jasonwhite/ducible/releases</releaseNotes>
  </metadata>
</package>
"@

echo $SpecText > ducible\ducible.nuspec

cd ducible

Invoke-WebRequest https://github.com/jasonwhite/ducible/releases/download/v$Version/ducible-windows-Win32-Release.zip -OutFile ducible.zip
$shell = New-Object -Com shell.application
$zip = $shell.NameSpace("$PWD\ducible.zip")
foreach ($item in $zip.items()) { $shell.NameSpace("$PWD").CopyHere($item) }

Invoke-WebRequest https://github.com/jasonwhite/ducible/raw/v$Version/LICENSE -OutFile LICENSE.txt

$LicenseSha256 = (get-filehash -path LICENSE.txt -algorithm sha256).Hash
$DucibleExeSha256 = (get-filehash -path ducible.exe -algorithm sha256).Hash
$PdbdumpExeSha256 = (get-filehash -path pdbdump.exe -algorithm sha256).Hash
$ZipSha256 = (get-filehash -path ducible.zip -algorithm sha256).Hash

rm ducible.zip

$VerificationText = @"
VERIFICATION
Verification is intended to assist the Chocolatey moderators and community
in verifying that this package's contents are trustworthy.

---

LICENSE.txt is taken directly from <https://github.com/jasonwhite/ducible/blob/v$Version/LICENSE>.
The files ducible.exe and pdbdump.exe were extracted from ducible-windows-Win32-Release.zip at <https://github.com/jasonwhite/ducible/releases>.

 File        | Sha256
-------------|-------------------
 LICENSE.txt | $LicenseSha256
 ducible.exe | $DucibleExeSha256
 pdbdump.exe | $PdbDumpExeSha256

For your convenience, the following PowerShell command line can be used to download, extract, and validate the SHA256 of every file.

``````powershell
mkdir ducible
cd ducible

# Download ducible.zip
Invoke-WebRequest https://github.com/jasonwhite/ducible/releases/download/v$Version/ducible-windows-Win32-Release.zip -OutFile ducible.zip

# Validate ducible.zip
`$ZipSha256 = (get-filehash -path ducible.zip -algorithm sha256).Hash
if (`$ZipSha256 -Ne "$ZipSha256") { throw "ducible.zip changed!" }

# Download LICENSE.txt
Invoke-WebRequest https://github.com/jasonwhite/ducible/raw/v$Version/LICENSE -OutFile LICENSE.txt

# Validate LICENSE.txt
`$LicenseSha256 = (get-filehash -path LICENSE.txt -algorithm sha256).Hash
if (`$LicenseSha256 -Ne "$LicenseSha256") { throw "LICENSE.txt changed!" }

# Extract ducible.zip
`$shell = New-Object -Com shell.application
`$zip = `$shell.NameSpace("`$PWD\ducible.zip")
foreach (`$item in `$zip.items()) { `$shell.NameSpace("`$PWD").CopyHere(`$item) }

# Validate zip file contents
`$DucibleExeSha256 = (get-filehash -path ducible.exe -algorithm sha256).Hash
`$PdbdumpExeSha256 = (get-filehash -path pdbdump.exe -algorithm sha256).Hash
if (`$DucibleExeSha256 -Ne "$DucibleExeSha256") { throw "ducible.exe changed!" }
if (`$PdbdumpExeSha256 -Ne "$PdbdumpExeSha256") { throw "pdbdump.exe changed!" }
``````
"@

echo $VerificationText > VERIFICATION.txt

cd ..
