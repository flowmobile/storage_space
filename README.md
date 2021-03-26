# Storage Space

Get the free, available and total disk space for the device.

The `StorageSpace` model contains values in bytes and human-readable versions.

The `lowOnSpace` flag shows when the device is low on space. The threshhold is up to you.

## Usage

```dart
StorageSpace freeSpace = await getStorageSpace(
  lowOnSpaceThreshold: 2 * 1024 * 1024 * 1024, // 2GB
  fractionDigits: 1, // How many digits to use for the human-readable values
);
```

## Example

The example directory shows how to use StorageSpace package to render a "progress meter" that renders a warning when the device is low on space

<img width="210" src="https://raw.githubusercontent.com/oodavid/storage_space/master/screenshots/normal.png" />
<img width="210" src="https://raw.githubusercontent.com/oodavid/storage_space/master/screenshots/lowOnSpace.png" />

## Background

This package is a reworking of three packages:

* https://pub.dev/packages/disk_space
* https://pub.dev/packages/storage_capacity
* https://pub.dev/packages/filesize

The end result is a simple package that is null-safe and can be easily maintained.
