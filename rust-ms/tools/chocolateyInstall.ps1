$PackageName = 'rust'
$InstallerType = 'msi'
$Url = 'https://static.rust-lang.org/dist/2017-06-08/rust-1.18.0-i686-pc-windows-msvc.msi'
$Checksum = '28dee99889a0fea8e5ed203c86ba662d29c302c9a52ace7eb0a8f78f576a56f0'
$Url64 = "https://static.rust-lang.org/dist/2017-06-08/rust-1.18.0-x86_64-pc-windows-msvc.msi"
$Checksum64 = '51023c40b17617b525f0f1fd6f2dd994c3700261158cb186e3fbf54ca21eb52b'
$ChecksumType = 'sha256'
$SilentArgs = '/quiet'
$ValidExitCodes = @(0,3010)
 
Install-ChocolateyPackage "$PackageName" "$InstallerType" "$SilentArgs" "$Url" "$Url64" `
    -checksum $Checksum -checksum64 $Checksum64 -checksumType $ChecksumType -checksumType64 $ChecksumType `
    -validExitCodes $ValidExitCodes