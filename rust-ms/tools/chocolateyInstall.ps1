$PackageName = 'rust'
$InstallerType = 'msi'
$Url = 'https://static.rust-lang.org/dist/2017-07-20/rust-1.19.0-i686-pc-windows-msvc.msi'
$Checksum = '9540fe771afa845435816cbd88e60cfd19a4c805923c85145528dec3a121704d'
$Url64 = "https://static.rust-lang.org/dist/2017-07-20/rust-1.19.0-x86_64-pc-windows-msvc.msi"
$Checksum64 = '1d2cd906e2f93ebd2d156f68dcb9312b9e08b60e6f71e9742d6da7a30c216bcc'
$ChecksumType = 'sha256'
$SilentArgs = '/quiet'
$ValidExitCodes = @(0,3010)
 
Install-ChocolateyPackage "$PackageName" "$InstallerType" "$SilentArgs" "$Url" "$Url64" `
    -checksum $Checksum -checksum64 $Checksum64 -checksumType $ChecksumType -checksumType64 $ChecksumType `
    -validExitCodes $ValidExitCodes