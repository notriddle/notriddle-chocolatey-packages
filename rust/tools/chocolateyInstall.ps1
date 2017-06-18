$PackageName = 'rust'
$InstallerType = 'msi'
$Url = 'https://static.rust-lang.org/dist/2017-06-08/rust-1.18.0-i686-pc-windows-gnu.msi'
$Checksum = '7e31c6bf0f7e27a87f6843f01e0151abc7c22d81554ec38316c8c9e2193f2977'
$Url64 = "https://static.rust-lang.org/dist/2017-06-08/rust-1.18.0-x86_64-pc-windows-gnu.msi"
$Checksum64 = 'cd093c19823e46f0b600f9b83fb1adae7adc94565056baf90e082ad91cb94110'
$ChecksumType = 'sha256'
$SilentArgs = '/quiet'
$ValidExitCodes = @(0,3010)
 
Install-ChocolateyPackage "$PackageName" "$InstallerType" "$SilentArgs" "$Url" "$Url64" `
    -checksum $Checksum -checksum64 $Checksum64 -checksumType $ChecksumType -checksumType64 $ChecksumType `
    -validExitCodes $ValidExitCodes