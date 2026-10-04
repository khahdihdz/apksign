# apksign

Android signing manager for Termux.

## Features

- Create a single RSA-4096 Android release keystore
- Show certificate and SHA-256 fingerprint
- Export keystore as Base64 for GitHub Actions
- Verify APK signatures with `apksigner`
- Create secure keystore backups
- Standardize GitHub Actions secrets for `khahdihdz` Android projects

## Install

```bash
pkg update -y
pkg install git -y
git clone https://github.com/khahdihdz/apksign.git
cd apksign
chmod +x apksign
./apksign
```

## Shared GitHub Secrets

Use these names in every Android repository:

- `ANDROID_SIGNING_KEYSTORE_BASE64`
- `ANDROID_SIGNING_STORE_PASSWORD`
- `ANDROID_SIGNING_KEY_ALIAS`
- `ANDROID_SIGNING_KEY_PASSWORD`

The private keystore is stored locally under:

```
~/.apksign/khahdihdz-release.jks
```

**Never commit the private keystore or its Base64 contents to a public repository.**

## Compatibility

For an existing Android app update, keep both:

1. The same `applicationId`
2. The same release signing key

Changing either can prevent normal Android updates.

## License

MIT
