$PackageName = 'rust'
$InstallerType = 'msi'
$Url = 'https://static.rust-lang.org/dist/2018-03-01/rust-1.24.1-i686-pc-windows-gnu.msi'
$Checksum = 'f6f0195745e0d7a2691dba9d62ec7bf3b9c2afc0902dd0ef30e51ac728ee5b2e'
$Url64 = "https://static.rust-lang.org/dist/2018-03-01/rust-1.24.1-x86_64-pc-windows-gnu.msi"
$Checksum64 = '9ddbcfea35083f75eea6a4874d09d5a1245f141aa0f551caa03bad8a488193a8'
$ChecksumType = 'sha256'
$SilentArgs = '/quiet'
$ValidExitCodes = @(0,3010)
 
Install-ChocolateyPackage "$PackageName" "$InstallerType" "$SilentArgs" "$Url" "$Url64" `
    -checksum $Checksum -checksum64 $Checksum64 -checksumType $ChecksumType -checksumType64 $ChecksumType `
    -validExitCodes $ValidExitCodes