import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:filepicker/filepicker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _filePath = 'Unknown';

  @override
  void initState() {
    super.initState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> invokeFilePicker() async {
    String filePath;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      filePath = await Filepicker.filePickerPath;
    } on PlatformException {
      filePath = 'Failed to get file path.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _filePath = filePath;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FlatButton(
              child: Text("Open File picker"),
              onPressed: (){
                invokeFilePicker();
              },
            ),
            Text("File Path::$_filePath"),
            _filePath == "Cancelled" ? (_filePath.split('/').last == "png" || _filePath.split('/').last == "jpg") ? Image.file(File(_filePath)) :Container() : SizedBox()
          ],
        ),
      ),
    );
  }
}
