$PackageName = 'rust'
$InstallerType = 'msi'
$Url = 'https://static.rust-lang.org/dist/2017-04-27/rust-1.17.0-i686-pc-windows-gnu.msi'
$Checksum = '43bc9018b8d0f96614447f51cab6c7c84516e65081c98a4d5a08596f7c3da8ce'
$Url64 = "https://static.rust-lang.org/dist/2017-04-27/rust-1.17.0-x86_64-pc-windows-gnu.msi"
$Checksum64 = '15a642324b658bbf91f8b4b1446fe28cfaf7806542366015d0b5faf7971bdb36'
$ChecksumType = 'sha256'
$SilentArgs = '/quiet'
$ValidExitCodes = @(0,3010)
 
Install-ChocolateyPackage "$PackageName" "$InstallerType" "$SilentArgs" "$Url" "$Url64" `
    -checksum $Checksum -checksum64 $Checksum64 -checksumType $ChecksumType -checksumType64 $ChecksumType `
    -validExitCodes $ValidExitCodes