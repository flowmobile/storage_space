# Storage Space

Get the free, available and total disk space for the device.

The `StorageSpace` model contains values in bytes and human-readable versions.

The `lowOnSpaceThreshold` triggers `lowOnSpace` to be set to true when the value is less than or equal to it (including when the value is equal).

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

<img width="210" src="https://raw.githubusercontent.com/flowmobile/storage_space/master/screenshots/normal.png" />
<img width="210" src="https://raw.githubusercontent.com/flowmobile/storage_space/master/screenshots/lowOnSpace.png" />

## Background

This package is a reworking of [disk_space](https://pub.dev/packages/disk_space) and [storage_capacity](https://pub.dev/packages/storage_capacity).

The reworking adds `null-safety`, as well as some convenience features:

* A single method-call for all properties in a `StorageSpace` class
* All values in `bytes` **and** human-readable, ie: 12.1 MB, 8 GB, 1.5 TB etc.
* Usage as a percent
* A flag to show if the system is low-on-space. The threshold is user-defined

Take a peek at the [StorageSpace class](https://pub.dev/documentation/storage_space/latest/storage_space/StorageSpace-class.html) in the API reference for more details.
