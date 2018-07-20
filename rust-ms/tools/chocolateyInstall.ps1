$PackageName = 'rust'
$InstallerType = 'msi'
$Url = 'https://static.rust-lang.org/dist/2018-07-20/rust-1.27.2-i686-pc-windows-msvc.msi'
$Checksum = 'd99c94fc5990b70117222a27e564f813764b7d6ff5dcb5550c438b5be8e446a0'
$Url64 = "https://static.rust-lang.org/dist/2018-07-20/rust-1.27.2-x86_64-pc-windows-msvc.msi"
$Checksum64 = 'd4f9d0946103a78bcd8c984b81aff99b77de0d67546c9227f1156df2f824e8f2'
$ChecksumType = 'sha256'
$SilentArgs = '/quiet'
$ValidExitCodes = @(0,3010)
 
Install-ChocolateyPackage "$PackageName" "$InstallerType" "$SilentArgs" "$Url" "$Url64" `
    -checksum $Checksum -checksum64 $Checksum64 -checksumType $ChecksumType -checksumType64 $ChecksumType `
    -validExitCodes $ValidExitCodes