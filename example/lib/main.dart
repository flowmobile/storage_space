import 'package:flutter/material.dart';
import 'package:storage_space/storage_space.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StorageSpace? _storageSpace;
  AppStorageUsage? _appStorageUsage;

  @override
  void initState() {
    super.initState();
    initStorageSpace();
    initAppStorageUsage();
  }

  void initStorageSpace() async {
    StorageSpace storageSpace = await getStorageSpace(
      lowOnSpaceThreshold: 2 * 1024 * 1024 * 1024, // 2GB
      fractionDigits: 1,
    );
    setState(() {
      _storageSpace = storageSpace;
    });
  }

  void initAppStorageUsage() async {
    AppStorageUsage appStorageUsage = await getAppStorageUsage(
      fractionDigits: 1,
    );
    setState(() {
      _appStorageUsage = appStorageUsage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Storage Space'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 200,
                    width: 200,
                    child: CircularProgressIndicator(
                      strokeWidth: 20,
                      value: _storageSpace?.usageValue ?? null,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        (_storageSpace?.lowOnSpace ?? false)
                            ? Colors.red
                            : Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                  if (_storageSpace == null) ...[
                    Text(
                      'Loading',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  if (_storageSpace != null) ...[
                    Column(
                      children: [
                        Text(
                          '${_storageSpace?.freeSize}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        if (_storageSpace?.lowOnSpace != true) ...[
                          Text(
                            'Remaining',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                        if (_storageSpace?.lowOnSpace == true) ...[
                          Text(
                            'Low On Space',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
              if (_storageSpace != null) ...[
                SizedBox(height: 24),
                Text(
                  '${_storageSpace?.usedSize} of ${_storageSpace?.totalSize} used',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              if (_appStorageUsage != null) ...[
                SizedBox(height: 8),
                Text(
                  'This app uses ${_appStorageUsage?.totalSize}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  'App ${_appStorageUsage?.appSize} · '
                  'Data ${_appStorageUsage?.dataSize} · '
                  'Cache ${_appStorageUsage?.cacheSize}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
