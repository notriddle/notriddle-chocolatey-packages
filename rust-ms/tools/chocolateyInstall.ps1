$PackageName = 'rust'
$InstallerType = 'msi'
$Url = 'https://static.rust-lang.org/dist/2019-02-28/rust-1.33.0-i686-pc-windows-msvc.msi'
$Checksum = '6f6efc5a825575ef8c53fd323462a35cb9a3350de0e1fb029d734feae958bae6'
$Url64 = "https://static.rust-lang.org/dist/2019-02-28/rust-1.33.0-x86_64-pc-windows-msvc.msi"
$Checksum64 = 'cc27799843a146745d4054afa5de1f1f5ab19d539d8c522a909b3c8119e46f99'
$ChecksumType = 'sha256'
$SilentArgs = '/quiet'
$ValidExitCodes = @(0,3010)
 
Install-ChocolateyPackage "$PackageName" "$InstallerType" "$SilentArgs" "$Url" "$Url64" `
    -checksum $Checksum -checksum64 $Checksum64 -checksumType $ChecksumType -checksumType64 $ChecksumType `
    -validExitCodes $ValidExitCodes