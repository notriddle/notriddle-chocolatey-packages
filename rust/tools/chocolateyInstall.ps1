$PackageName = 'rust'
$InstallerType = 'msi'
$Url = 'https://static.rust-lang.org/dist/2019-02-28/rust-1.33.0-i686-pc-windows-gnu.msi'
$Checksum = 'fd4680e91ac3e859b2aa1a0197ab9823ea9f0edb54073ab57838939dd17d363b'
$Url64 = "https://static.rust-lang.org/dist/2019-02-28/rust-1.33.0-x86_64-pc-windows-gnu.msi"
$Checksum64 = '1235c3d5bf51a2543efd5389618a394e51c3c5de2fc8390171f132d5c5557d09'
$ChecksumType = 'sha256'
$SilentArgs = '/quiet'
$ValidExitCodes = @(0,3010)
 
Install-ChocolateyPackage "$PackageName" "$InstallerType" "$SilentArgs" "$Url" "$Url64" `
    -checksum $Checksum -checksum64 $Checksum64 -checksumType $ChecksumType -checksumType64 $ChecksumType `
    -validExitCodes $ValidExitCodes