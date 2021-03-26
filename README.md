# Storage Space

Get the free, available and total storage space for the device.

There is a utility helper for human-readable sizes.

## Usage

```
StorageSpace freeSpace = await getStorageSpace(
  lowOnSpaceThreshold: 2 * 1024 * 1024 * 1024, // 2GB
  fractionDigits: 1, // How many digits to use for the human-readable values
);
```

## Example

The example directory shows how to use StorageSpace package to render a "progress meter" that renders a warning when the device is low on space

![demo](https://raw.githubusercontent.com/oodavid/storage_space/master/screenshots/normal.png)

![demo](https://raw.githubusercontent.com/oodavid/storage_space/master/screenshots/lowOnSpace.png)

## Background

This package is a reworking of three packages:

* https://pub.dev/packages/disk_space
* https://pub.dev/packages/storage_capacity
* https://pub.dev/packages/filesize

The end result is a simple package that is null-safe and can be easily maintained.
