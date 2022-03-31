param(
    [ValidateSet('rust', 'rust-ms', 'ducible', 'chars')]
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Package,
    [switch]$Confirm=$True
)

# choco apiKey -k YOURS-VERY-OWN-API-KEY -source https://chocolatey.org/

$here = (Split-Path -parent $MyInvocation.MyCommand.Definition)

if ($Package -eq 'chars' -and (test-path 'chars/chars')) {
  rm -recurse -force 'chars/chars'
}

pushd

try {

    cd $here/$Package

    rm *.nupkg
    choco pack

    gci *.nupkg | %{
        $PackagePath = $_
        Write-Host Push $PackagePath
        choco push $PackagePath
        rm $PackagePath
    }
} finally {
    popd
}

git add -A
