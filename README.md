# notriddle-chocolatey-packages

## Pull new versions of the Rust packages

```
.\update.ps1
```

## Pull new version of the chars package

```
.\update_chars.ps1 0.4.1
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
