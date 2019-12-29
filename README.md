# notriddle-chocolatey-packages

## Pull new versions of the Rust packages

```
.\update_rust.ps1
```

## Pull new version of the chars package

```
.\update_chars.ps1 0.4.1
```

## Pull new version of the ducible package

```
.\update_ducible.ps1 1.2.2
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
