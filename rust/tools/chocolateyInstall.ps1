$PackageName = 'rust'
$InstallerType = 'msi'
$Url = 'https://static.rust-lang.org/dist/2018-05-29/rust-1.26.1-i686-pc-windows-gnu.msi'
$Checksum = '54f7541f2f9b0b71faec2ac93ae6d38f0f555a0eb7abb76440005e958393eb2c'
$Url64 = "https://static.rust-lang.org/dist/2018-05-29/rust-1.26.1-x86_64-pc-windows-gnu.msi"
$Checksum64 = 'e2fe4b096c04b6564451aa1f0a81d78e0c3270a2f640fecc1eef8afbfd05001f'
$ChecksumType = 'sha256'
$SilentArgs = '/quiet'
$ValidExitCodes = @(0,3010)
 
Install-ChocolateyPackage "$PackageName" "$InstallerType" "$SilentArgs" "$Url" "$Url64" `
    -checksum $Checksum -checksum64 $Checksum64 -checksumType $ChecksumType -checksumType64 $ChecksumType `
    -validExitCodes $ValidExitCodes