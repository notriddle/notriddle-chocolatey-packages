$PackageName = 'rust'
$InstallerType = 'msi'
$Url = 'https://static.rust-lang.org/dist/2018-03-01/rust-1.24.1-i686-pc-windows-msvc.msi'
$Checksum = '4b5412bbefb6f71844f9fc83f99d49c13798d496fca2dfc690499c13d474cd76'
$Url64 = "https://static.rust-lang.org/dist/2018-03-01/rust-1.24.1-x86_64-pc-windows-msvc.msi"
$Checksum64 = '4a9e6d5a74a65d4bfb071e778e90bd2789aa715bafebba7fa90f7c1a31643804'
$ChecksumType = 'sha256'
$SilentArgs = '/quiet'
$ValidExitCodes = @(0,3010)
 
Install-ChocolateyPackage "$PackageName" "$InstallerType" "$SilentArgs" "$Url" "$Url64" `
    -checksum $Checksum -checksum64 $Checksum64 -checksumType $ChecksumType -checksumType64 $ChecksumType `
    -validExitCodes $ValidExitCodes