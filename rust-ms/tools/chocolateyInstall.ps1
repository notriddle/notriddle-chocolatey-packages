$PackageName = 'rust'
$InstallerType = 'msi'
$Url = 'https://static.rust-lang.org/dist/2018-03-29/rust-1.25.0-i686-pc-windows-msvc.msi'
$Checksum = '0694cd5ceb2a5d0146dced7ad86287d8294acb4a7a16753dfa6900bb304405f6'
$Url64 = "https://static.rust-lang.org/dist/2018-03-29/rust-1.25.0-x86_64-pc-windows-msvc.msi"
$Checksum64 = '1e135664b2848a4830fb4813a3c6fa796a5e83800e13f83fe217b40216b0a622'
$ChecksumType = 'sha256'
$SilentArgs = '/quiet'
$ValidExitCodes = @(0,3010)
 
Install-ChocolateyPackage "$PackageName" "$InstallerType" "$SilentArgs" "$Url" "$Url64" `
    -checksum $Checksum -checksum64 $Checksum64 -checksumType $ChecksumType -checksumType64 $ChecksumType `
    -validExitCodes $ValidExitCodes