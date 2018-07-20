$PackageName = 'rust'
$InstallerType = 'msi'
$Url = 'https://static.rust-lang.org/dist/2018-07-20/rust-1.27.2-i686-pc-windows-gnu.msi'
$Checksum = 'c51c7de444e4b473579b64c9926a317d6c1dfb29c8049e6dd2b435c667a1ba3f'
$Url64 = "https://static.rust-lang.org/dist/2018-07-20/rust-1.27.2-x86_64-pc-windows-gnu.msi"
$Checksum64 = '7464660785550cf3bdfd2b10fe41af9c9b6bfa7c1f9560fac09961e65b6dd725'
$ChecksumType = 'sha256'
$SilentArgs = '/quiet'
$ValidExitCodes = @(0,3010)
 
Install-ChocolateyPackage "$PackageName" "$InstallerType" "$SilentArgs" "$Url" "$Url64" `
    -checksum $Checksum -checksum64 $Checksum64 -checksumType $ChecksumType -checksumType64 $ChecksumType `
    -validExitCodes $ValidExitCodes