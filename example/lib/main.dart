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

  @override
  void initState() {
    super.initState();
    initStorageSpace();
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
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                  if (_storageSpace != null) ...[
                    Column(
                      children: [
                        Text(
                          '${_storageSpace?.freeSize}',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        if (_storageSpace?.lowOnSpace != true) ...[
                          Text(
                            'Remaining',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                        if (_storageSpace?.lowOnSpace == true) ...[
                          Text(
                            'Low On Space',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
