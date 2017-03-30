# notriddle-chocolatey-packages

## Pull new versions of all the packages

```
.\update.ps1
```

## Push

```
.\push.ps1 $package
```

## Test

```
cd package
choco pack
choco install package -s ..
```
