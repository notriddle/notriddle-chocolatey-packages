$PackageName = 'rust'
$InstallerType = 'msi'
$Url = 'https://static.rust-lang.org/dist/2019-04-25/rust-1.34.1-i686-pc-windows-gnu.msi'
$Checksum = '89243261b0b0427f4c90b1e24921b78468f966b0dbc3b6cbe68e52559bc67cee'
$Url64 = "https://static.rust-lang.org/dist/2019-04-25/rust-1.34.1-x86_64-pc-windows-gnu.msi"
$Checksum64 = '887786842739c1b5c8de631413e886147db529dcf1b6be86e2e8a2e0f430b600'
$ChecksumType = 'sha256'
$SilentArgs = '/quiet'
$ValidExitCodes = @(0,3010)
 
Install-ChocolateyPackage "$PackageName" "$InstallerType" "$SilentArgs" "$Url" "$Url64" `
    -checksum $Checksum -checksum64 $Checksum64 -checksumType $ChecksumType -checksumType64 $ChecksumType `
    -validExitCodes $ValidExitCodes