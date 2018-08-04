$PackageName = 'rust'
$InstallerType = 'msi'
$Url = 'https://static.rust-lang.org/dist/2018-08-02/rust-1.28.0-i686-pc-windows-gnu.msi'
$Checksum = '6c3899ea2bc7655c5b483451da266a57d9ee212e0cc30936b14246f992e31ec1'
$Url64 = "https://static.rust-lang.org/dist/2018-08-02/rust-1.28.0-x86_64-pc-windows-gnu.msi"
$Checksum64 = '5151122c2c902765161257403eb49038c77f704a4e13a0c38e90b0fbdf9a9ca3'
$ChecksumType = 'sha256'
$SilentArgs = '/quiet'
$ValidExitCodes = @(0,3010)
 
Install-ChocolateyPackage "$PackageName" "$InstallerType" "$SilentArgs" "$Url" "$Url64" `
    -checksum $Checksum -checksum64 $Checksum64 -checksumType $ChecksumType -checksumType64 $ChecksumType `
    -validExitCodes $ValidExitCodes