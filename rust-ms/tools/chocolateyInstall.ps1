$PackageName = 'rust'
$InstallerType = 'msi'
$Url = 'https://static.rust-lang.org/dist/2017-03-11/rust-1.16.0-i686-pc-windows-msvc.msi'
$Checksum = 'dc996c784c13efe731e1c163c552f0d3965e71625165b0e1f398fe35dfdba82b'
$Url64 = "https://static.rust-lang.org/dist/2017-03-11/rust-1.16.0-x86_64-pc-windows-msvc.msi"
$Checksum64 = '2dff0d8e445614d6da00aa9931a003658a99ca5bdb8fe43893e0df164953915f'
$ChecksumType = 'sha256'
$SilentArgs = '/quiet'
$ValidExitCodes = @(0,3010)
 
Install-ChocolateyPackage "$PackageName" "$InstallerType" "$SilentArgs" "$Url" "$Url64" `
    -checksum $Checksum -checksum64 $Checksum64 -checksumType $ChecksumType -checksumType64 $ChecksumType `
    -validExitCodes $ValidExitCodes