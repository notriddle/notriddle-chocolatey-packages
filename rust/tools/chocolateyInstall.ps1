$PackageName = 'rust'
$InstallerType = 'msi'
$Url = "https://static.rust-lang.org/dist/rust-1.16.0-i686-pc-windows-gnu.msi"
$Checksum = '51692ca58962d54bd96a00f7bd527980b0984948c781c3b1d7a17caf5ec617fc'
$Url64 = "https://static.rust-lang.org/dist/rust-1.16.0-x86_64-pc-windows-gnu.msi"
$Checksum64 = 'b20aacbca077b23674a4575dc3e63ac0e02162481f22a487cf53f676ff72b061'
$ChecksumType = 'sha256'
$SilentArgs = '/quiet'
$ValidExitCodes = @(0,3010)
 
Install-ChocolateyPackage "$PackageName" "$InstallerType" "$SilentArgs" "$Url" "$Url64" `
    -checksum $Checksum -checksum64 $Checksum64 -checksumType $ChecksumType -checksumType64 $ChecksumType `
    -validExitCodes $ValidExitCodes