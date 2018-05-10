$PackageName = 'rust'
$InstallerType = 'msi'
$Url = 'https://static.rust-lang.org/dist/2018-05-10/rust-1.26.0-i686-pc-windows-msvc.msi'
$Checksum = '9ad631473c5306428cbd8edd22beae928c70463859750fb4ce9d357836a704a3'
$Url64 = "https://static.rust-lang.org/dist/2018-05-10/rust-1.26.0-x86_64-pc-windows-msvc.msi"
$Checksum64 = '19447a1a35a508aa13a0da3afd5e9892b8dbe5257e5028282fc213a31bfdd49b'
$ChecksumType = 'sha256'
$SilentArgs = '/quiet'
$ValidExitCodes = @(0,3010)
 
Install-ChocolateyPackage "$PackageName" "$InstallerType" "$SilentArgs" "$Url" "$Url64" `
    -checksum $Checksum -checksum64 $Checksum64 -checksumType $ChecksumType -checksumType64 $ChecksumType `
    -validExitCodes $ValidExitCodes