import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:clipboard/clipboard.dart'; // Import for clipboard functionality
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(CamApp());
}

class CamApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TakePhotoScreen(),
    );
  }
}

class TakePhotoScreen extends StatefulWidget {
  @override
  _TakePhotoScreenState createState() => _TakePhotoScreenState();
}

class _TakePhotoScreenState extends State<TakePhotoScreen> {
  late File _imageFile = File('');
  List<String> _recognizedLines = [];
  late BannerAd _bannerAd;

  @override
  void initState() {
    super.initState();
    _bannerAd = BannerAd(
      adUnitId: 'Add Your unit id here', 
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
        _performTextRecognition(_imageFile);
      } else {
        print('Take a photo.');
      }
    });
  }

  Future<void> _performTextRecognition(File imageFile) async {
    final inputImage = InputImage.fromFilePath(imageFile.path);
    final textRecognizer = TextRecognizer();
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
    setState(() {
      _recognizedLines = recognizedText.text.split('\n');
    });
    textRecognizer.close();
  }

  // Function to copy recognized text to clipboard
  void _copyToClipboard() {
    String textToCopy = _recognizedLines.join('\n');
    FlutterClipboard.copy(textToCopy);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Text copied to clipboard'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Text recognition(OCR)',style: TextStyle(color: Colors.black),),
        backgroundColor: Color.fromARGB(255, 242, 240, 244),
        centerTitle: true,
      ),
      backgroundColor: Color.fromARGB(255, 15, 4, 1),
      body: Column(
        children: <Widget>[
          _bannerAd != null
              ? Container(
                  alignment: Alignment.topCenter,
                  child: AdWidget(ad: _bannerAd),
                  width: MediaQuery.of(context).size.width,
                  height: _bannerAd.size.height.toDouble(),
                )
              : SizedBox(),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _imageFile.path.isNotEmpty
                      ? Image.file(
                          File(_imageFile.path),
                          height: 200,
                        )
                      : Text(
                          '1. Take a photo.',
                          style: TextStyle(color: Color.fromARGB(255, 211, 206, 235)),
                        ),
                        Text(
                          '2. copy the text to clipboard.',
                          style: TextStyle(color: Color.fromARGB(255, 211, 206, 235)),
                        ),
                  SizedBox(height: 20),
                  _recognizedLines.isNotEmpty
                      ? Expanded(
                          child: Container(
                            color: Colors.grey[200],
                            child: ListView.builder(
                              itemCount: _recognizedLines.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(_recognizedLines[index]),
                                );
                              },
                            ),
                          ),
                        )
                      : SizedBox(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _takePhoto();
        },
        tooltip: '',
        child: Icon(Icons.camera_alt),
      ),
      persistentFooterButtons: <Widget>[
        FloatingActionButton(
          onPressed: () {
            _copyToClipboard();
          },
          tooltip: 'Copy Text',
          child: Icon(Icons.content_copy),
        ),
      ],
    );
  }
}
