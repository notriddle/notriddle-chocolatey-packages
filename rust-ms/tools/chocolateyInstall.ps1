$PackageName = 'rust'
$InstallerType = 'msi'
$Url = 'https://static.rust-lang.org/dist/2018-08-02/rust-1.28.0-i686-pc-windows-msvc.msi'
$Checksum = 'dfffc2b89d5772f6b354861ec07ec343db5d4dcf9d67d6cd285c926392a5088f'
$Url64 = "https://static.rust-lang.org/dist/2018-08-02/rust-1.28.0-x86_64-pc-windows-msvc.msi"
$Checksum64 = '2ff48fa4eb89c574cf0cda595a29ef08e7deffaa1d091f4cd0087c3e25ba05a2'
$ChecksumType = 'sha256'
$SilentArgs = '/quiet'
$ValidExitCodes = @(0,3010)
 
Install-ChocolateyPackage "$PackageName" "$InstallerType" "$SilentArgs" "$Url" "$Url64" `
    -checksum $Checksum -checksum64 $Checksum64 -checksumType $ChecksumType -checksumType64 $ChecksumType `
    -validExitCodes $ValidExitCodes