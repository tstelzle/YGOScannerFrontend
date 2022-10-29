import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:http_parser/http_parser.dart';

class DisplayPictureScreen extends StatefulWidget {
  const DisplayPictureScreen({super.key, required this.imagePath});

  final String imagePath;

  @override
  DisplayPictureScreenState createState() => DisplayPictureScreenState();
}

class DisplayPictureScreenState extends State<DisplayPictureScreen> {
  late String _imagePath;
  late String _text = "Text";

  @override
  void initState() {
    _imagePath = widget.imagePath;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Display the Picture')),
        body: Center(
            child: Column(
          children: <Widget>[
            Image.file(File(_imagePath)),
            Text(_text),
            FloatingActionButton(
              onPressed: () async {
                String response = await upload(_imagePath);
                setState(() {
                  _text = response;
                });
              },
              child: const Icon(Icons.send),
            ),
          ],
        )));
  }

  Future<String> upload(String imagePath) async {

    final img.Image? capturedImage = img.decodeImage(await File(imagePath).readAsBytes());
    final img.Image orientedImage = img.bakeOrientation(capturedImage!);
    await File(imagePath).writeAsBytes(img.encodeJpg(orientedImage));

    var request = http.MultipartRequest(
        "POST", Uri.parse("http://192.168.177.28:8080/api/ocr"));

    var multipartFile = await http.MultipartFile.fromPath("image", imagePath, contentType: MediaType("image", "jpg"));
    request.files.add(multipartFile);

    final http.StreamedResponse response = await request.send();

    return response.stream.bytesToString();
  }
}
