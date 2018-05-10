$PackageName = 'rust'
$InstallerType = 'msi'
$Url = 'https://static.rust-lang.org/dist/2018-05-10/rust-1.26.0-i686-pc-windows-gnu.msi'
$Checksum = '2936bdba96a1738000907238f5b5d7187eb3bad243f89f332d7721d6d4f66b1f'
$Url64 = "https://static.rust-lang.org/dist/2018-05-10/rust-1.26.0-x86_64-pc-windows-gnu.msi"
$Checksum64 = '576f58601ddfae6c9e7227b194766815dc195ba9d1037c28f7b66a1498a8373d'
$ChecksumType = 'sha256'
$SilentArgs = '/quiet'
$ValidExitCodes = @(0,3010)
 
Install-ChocolateyPackage "$PackageName" "$InstallerType" "$SilentArgs" "$Url" "$Url64" `
    -checksum $Checksum -checksum64 $Checksum64 -checksumType $ChecksumType -checksumType64 $ChecksumType `
    -validExitCodes $ValidExitCodes