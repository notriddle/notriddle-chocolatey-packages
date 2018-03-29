$PackageName = 'rust'
$InstallerType = 'msi'
$Url = 'https://static.rust-lang.org/dist/2018-03-29/rust-1.25.0-i686-pc-windows-gnu.msi'
$Checksum = '16e149cca84830ae62adc5e1d3b906048641dfb4cee3cf25fa2413f10a756034'
$Url64 = "https://static.rust-lang.org/dist/2018-03-29/rust-1.25.0-x86_64-pc-windows-gnu.msi"
$Checksum64 = '070d3a0bf481f2ac0c48b236d07d60d704ace35b7ee8e902be64ce53fe3fd9ff'
$ChecksumType = 'sha256'
$SilentArgs = '/quiet'
$ValidExitCodes = @(0,3010)
 
Install-ChocolateyPackage "$PackageName" "$InstallerType" "$SilentArgs" "$Url" "$Url64" `
    -checksum $Checksum -checksum64 $Checksum64 -checksumType $ChecksumType -checksumType64 $ChecksumType `
    -validExitCodes $ValidExitCodes