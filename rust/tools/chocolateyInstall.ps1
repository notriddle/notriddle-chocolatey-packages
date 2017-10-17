$PackageName = 'rust'
$InstallerType = 'msi'
$Url = 'https://static.rust-lang.org/dist/2017-10-12/rust-1.21.0-i686-pc-windows-gnu.msi'
$Checksum = '57a4605dea348be5fd8e2ae9ad5aff46313622486b333fb760908f011590d820'
$Url64 = "https://static.rust-lang.org/dist/2017-10-12/rust-1.21.0-x86_64-pc-windows-gnu.msi"
$Checksum64 = 'ff4e22d71ee70e8fe4e24b02ae857ec75185a48200356435144387ea67899f4a'
$ChecksumType = 'sha256'
$SilentArgs = '/quiet'
$ValidExitCodes = @(0,3010)
 
Install-ChocolateyPackage "$PackageName" "$InstallerType" "$SilentArgs" "$Url" "$Url64" `
    -checksum $Checksum -checksum64 $Checksum64 -checksumType $ChecksumType -checksumType64 $ChecksumType `
    -validExitCodes $ValidExitCodes