import 'dart:convert';
import 'dart:typed_data';
import 'dart:html' as html;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LottieFlix',
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
  Color _colorPrimary = const Color(0xFF06DDB3);
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _loadJson() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

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
            _jsonContent = _modifyJson(_jsonContent!);
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = 'File bytes are null';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'No file selected';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
        _isLoading = false;
      });
      debugPrint('Error loading file: $e');
    }
  }

  Map<String, dynamic> _modifyJson(Map<String, dynamic> json) {
    Map<String, dynamic> modify(Map<String, dynamic> json) {
      final newJson = <String, dynamic>{};
      json.forEach((key, value) {
        newJson[key] = value;
        if (value is String &&
            (value == 'tr' ||
                value == 'gr' ||
                value == 'sh' ||
                value == 'fl')) {
          newJson['nm'] = 'surface53362';
        } else if (value is Map<String, dynamic>) {
          newJson[key] = modify(value);
        } else if (value is List) {
          newJson[key] = value.map((item) {
            if (item is Map<String, dynamic>) {
              return modify(item);
            }
            return item;
          }).toList();
        }
      });
      return newJson;
    }

    return modify(json);
  }

  void _downloadJson() {
    final jsonContent = json.encode(_jsonContent);
    final bytes = utf8.encode(jsonContent);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "modified.json")
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Image.asset(
          'assets/lottieflix-logo.png',
          height: 40,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20),
            if (_isLoading)
              Column(
                children: [
                  const Text(
                    'Mettiti comodo mentre sistemo il tuo file Lottie...',
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 20),
                  LottieBuilder.asset(
                    'assets/hamster.json',
                    width: 250,
                  ),
                ],
              )
            else if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 20,
                ),
              ),
            if (!_isLoading && _errorMessage == null && _jsonContent == null)
              Column(
                children: [
                  const Text(
                    'Nessun JSON file caricato',
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 20),
                  LottieBuilder.asset(
                    'assets/astronaut.json',
                    width: 250,
                  ),
                ],
              ),
            if (_jsonContent != null && _errorMessage == null)
              ElevatedButton(
                onPressed: _downloadJson,
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(_colorPrimary),
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 20,
                    ),
                  ),
                ),
                child: RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                    children: [
                      TextSpan(text: 'Download Lottie Fixato '),
                      TextSpan(
                        text: '🚀',
                        style: TextStyle(fontFamily: 'Noto Color Emoji'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadJson,
        backgroundColor: _colorPrimary,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              children: [
                TextSpan(text: 'Made with '),
                TextSpan(
                  text: '♥️',
                  style: TextStyle(fontFamily: 'Noto Color Emoji'),
                ),
                TextSpan(text: ' by BerviFix from Italy '),
                TextSpan(
                  text: '🍕',
                  style: TextStyle(fontFamily: 'Noto Color Emoji'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
