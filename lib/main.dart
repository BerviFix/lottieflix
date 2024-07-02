import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter JSON Loader',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<String, dynamic>? _jsonContent;
  Color _colorPrimary = Color(0xFF06DDB3);

  Future<void> _loadJson() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null) {
        if (result.files.single.bytes != null) {
          Uint8List fileBytes = result.files.single.bytes!;
          String content = utf8.decode(fileBytes);
          setState(() {
            _jsonContent = json.decode(content);
          });
        } else {
          setState(() {
            _jsonContent = {'Error': 'File bytes are null'};
          });
        }
      } else {
        setState(() {
          _jsonContent = {'Error': 'No file selected'};
        });
      }
    } catch (e) {
      setState(() {
        _jsonContent = {'Error': 'An error occurred: $e'};
      });
      debugPrint('Error loading file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Image.asset(
            'lottieflix-logo.png',
            height: 40,
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 20),
              _jsonContent != null
                  ? Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          _jsonContent.toString(),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    )
                  : const Text('No JSON loaded'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _loadJson,
          child: const Icon(Icons.add),
          backgroundColor: _colorPrimary,
        ));
  }
}
