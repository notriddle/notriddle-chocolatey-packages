$PackageName = 'rust'
$InstallerType = 'msi'
$Url = 'https://static.rust-lang.org/dist/2017-07-20/rust-1.19.0-i686-pc-windows-gnu.msi'
$Checksum = '09f68b060f23b9effd9c7f4de292d99fda003682a4ecd9a85f14118158c0a545'
$Url64 = "https://static.rust-lang.org/dist/2017-07-20/rust-1.19.0-x86_64-pc-windows-gnu.msi"
$Checksum64 = 'e3182ae6106310328c0b878f8c1c63042685d23342dab153918d46b82030a197'
$ChecksumType = 'sha256'
$SilentArgs = '/quiet'
$ValidExitCodes = @(0,3010)
 
Install-ChocolateyPackage "$PackageName" "$InstallerType" "$SilentArgs" "$Url" "$Url64" `
    -checksum $Checksum -checksum64 $Checksum64 -checksumType $ChecksumType -checksumType64 $ChecksumType `
    -validExitCodes $ValidExitCodes