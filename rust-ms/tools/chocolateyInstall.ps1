$PackageName = 'rust'
$InstallerType = 'msi'
$Url = 'https://static.rust-lang.org/dist/2019-04-25/rust-1.34.1-i686-pc-windows-msvc.msi'
$Checksum = 'f6632d62de4e1218e446dc54b13cb3028c04ab5630ab8c82c2953bf748137abf'
$Url64 = "https://static.rust-lang.org/dist/2019-04-25/rust-1.34.1-x86_64-pc-windows-msvc.msi"
$Checksum64 = '8ff7da5d26fad8986f485ac5f77c51511f52863b08e83aef295f2f29cd0c78d9'
$ChecksumType = 'sha256'
$SilentArgs = '/quiet'
$ValidExitCodes = @(0,3010)
 
Install-ChocolateyPackage "$PackageName" "$InstallerType" "$SilentArgs" "$Url" "$Url64" `
    -checksum $Checksum -checksum64 $Checksum64 -checksumType $ChecksumType -checksumType64 $ChecksumType `
    -validExitCodes $ValidExitCodes