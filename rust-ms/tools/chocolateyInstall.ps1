$PackageName = 'rust'
$InstallerType = 'msi'
$Url = 'https://static.rust-lang.org/dist/2018-05-29/rust-1.26.1-i686-pc-windows-msvc.msi'
$Checksum = '74214bba1dd638ba97ace080dc2161f165dfdc57bb31f0f11cdc648bf8083841'
$Url64 = "https://static.rust-lang.org/dist/2018-05-29/rust-1.26.1-x86_64-pc-windows-msvc.msi"
$Checksum64 = '0d9d811b10c6e9787f562fcf44f05a2a37100981ac34ebd9955987fb683905ba'
$ChecksumType = 'sha256'
$SilentArgs = '/quiet'
$ValidExitCodes = @(0,3010)
 
Install-ChocolateyPackage "$PackageName" "$InstallerType" "$SilentArgs" "$Url" "$Url64" `
    -checksum $Checksum -checksum64 $Checksum64 -checksumType $ChecksumType -checksumType64 $ChecksumType `
    -validExitCodes $ValidExitCodes