$PackageName = 'rust'
$InstallerType = 'msi'
$Url = 'https://static.rust-lang.org/dist/2018-01-04/rust-1.23.0-i686-pc-windows-gnu.msi'
$Checksum = 'c508e3c7f465f82c8542c63c46f8787cc5c740d1a67b8fe55add0879677a1ab5'
$Url64 = "https://static.rust-lang.org/dist/2018-01-04/rust-1.23.0-x86_64-pc-windows-gnu.msi"
$Checksum64 = 'ebc9323a2a449bbb29c7e8a3da1f7494d10a063a113b0374a186ff01faaae670'
$ChecksumType = 'sha256'
$SilentArgs = '/quiet'
$ValidExitCodes = @(0,3010)
 
Install-ChocolateyPackage "$PackageName" "$InstallerType" "$SilentArgs" "$Url" "$Url64" `
    -checksum $Checksum -checksum64 $Checksum64 -checksumType $ChecksumType -checksumType64 $ChecksumType `
    -validExitCodes $ValidExitCodes