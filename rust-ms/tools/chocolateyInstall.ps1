$PackageName = 'rust'
$InstallerType = 'msi'
$Url = 'https://static.rust-lang.org/dist/2018-01-04/rust-1.23.0-i686-pc-windows-msvc.msi'
$Checksum = '15f71a32a33051baad8f52c836d4bed0bea99779c07b3ca8dbffb7b1e3f6e429'
$Url64 = "https://static.rust-lang.org/dist/2018-01-04/rust-1.23.0-x86_64-pc-windows-msvc.msi"
$Checksum64 = '602f63b59a27c8e2cc202fb7966909c4ccc33bc649b1af5200758b37cd32b15d'
$ChecksumType = 'sha256'
$SilentArgs = '/quiet'
$ValidExitCodes = @(0,3010)
 
Install-ChocolateyPackage "$PackageName" "$InstallerType" "$SilentArgs" "$Url" "$Url64" `
    -checksum $Checksum -checksum64 $Checksum64 -checksumType $ChecksumType -checksumType64 $ChecksumType `
    -validExitCodes $ValidExitCodes