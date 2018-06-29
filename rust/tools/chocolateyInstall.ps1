$PackageName = 'rust'
$InstallerType = 'msi'
$Url = 'https://static.rust-lang.org/dist/2018-06-21/rust-1.27.0-i686-pc-windows-gnu.msi'
$Checksum = '8a36067c3849577503fd1adb3ecc1e7b97b9cabc84293b18085b23e685956255'
$Url64 = "https://static.rust-lang.org/dist/2018-06-21/rust-1.27.0-x86_64-pc-windows-gnu.msi"
$Checksum64 = 'cb36a6496b7e8475a58b5c069a260e0441d97c468df6769ff4428f76c4b7d1d3'
$ChecksumType = 'sha256'
$SilentArgs = '/quiet'
$ValidExitCodes = @(0,3010)
 
Install-ChocolateyPackage "$PackageName" "$InstallerType" "$SilentArgs" "$Url" "$Url64" `
    -checksum $Checksum -checksum64 $Checksum64 -checksumType $ChecksumType -checksumType64 $ChecksumType `
    -validExitCodes $ValidExitCodes