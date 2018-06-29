$PackageName = 'rust'
$InstallerType = 'msi'
$Url = 'https://static.rust-lang.org/dist/2018-06-21/rust-1.27.0-i686-pc-windows-msvc.msi'
$Checksum = '8eda61fd09d264b5c723411da2a57726dfcf6f52263f4205bc7bd9ceb0804b4b'
$Url64 = "https://static.rust-lang.org/dist/2018-06-21/rust-1.27.0-x86_64-pc-windows-msvc.msi"
$Checksum64 = '400219afb45c2a719b74c7680aaad2e60aee931734f9aa5163a5a73d0aa6fc49'
$ChecksumType = 'sha256'
$SilentArgs = '/quiet'
$ValidExitCodes = @(0,3010)
 
Install-ChocolateyPackage "$PackageName" "$InstallerType" "$SilentArgs" "$Url" "$Url64" `
    -checksum $Checksum -checksum64 $Checksum64 -checksumType $ChecksumType -checksumType64 $ChecksumType `
    -validExitCodes $ValidExitCodes