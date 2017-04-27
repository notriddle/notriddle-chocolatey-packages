$PackageName = 'rust'
$InstallerType = 'msi'
$Url = 'https://static.rust-lang.org/dist/2017-04-27/rust-1.17.0-i686-pc-windows-msvc.msi'
$Checksum = '866efbced7bff47b328be4cd7ab0b8536b91eb5b822cee535e8d1e9a4cbdac04'
$Url64 = "https://static.rust-lang.org/dist/2017-04-27/rust-1.17.0-x86_64-pc-windows-msvc.msi"
$Checksum64 = 'c35e316a6af11883a45eb66a3a6f942fe2ce8ac5fb754f266a2ab60b4dbb7fd3'
$ChecksumType = 'sha256'
$SilentArgs = '/quiet'
$ValidExitCodes = @(0,3010)
 
Install-ChocolateyPackage "$PackageName" "$InstallerType" "$SilentArgs" "$Url" "$Url64" `
    -checksum $Checksum -checksum64 $Checksum64 -checksumType $ChecksumType -checksumType64 $ChecksumType `
    -validExitCodes $ValidExitCodes