$PackageName = 'rust'
$InstallerType = 'msi'
$Url = 'https://static.rust-lang.org/dist/2017-10-12/rust-1.21.0-i686-pc-windows-msvc.msi'
$Checksum = 'bfc6648e823f9ed42a72b0fd5abccddd956c9348c07d6f3a120101a1ee55dcb0'
$Url64 = "https://static.rust-lang.org/dist/2017-10-12/rust-1.21.0-x86_64-pc-windows-msvc.msi"
$Checksum64 = 'bc0cb9966a7d979b91c56b3fa772fef05518d8a5889527a615b415f131f4ff05'
$ChecksumType = 'sha256'
$SilentArgs = '/quiet'
$ValidExitCodes = @(0,3010)
 
Install-ChocolateyPackage "$PackageName" "$InstallerType" "$SilentArgs" "$Url" "$Url64" `
    -checksum $Checksum -checksum64 $Checksum64 -checksumType $ChecksumType -checksumType64 $ChecksumType `
    -validExitCodes $ValidExitCodes