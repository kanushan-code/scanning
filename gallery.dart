import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:clipboard/clipboard.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

void main() {
  runApp(GalleryApp());
}

class GalleryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: TextRecognitionScreen(),
    );
  }
}

class TextRecognitionScreen extends StatefulWidget {
  @override
  _TextRecognitionScreenState createState() => _TextRecognitionScreenState();
}

class _TextRecognitionScreenState extends State<TextRecognitionScreen> {
  File? _image;
  List<String> _recognizedLines = [];
  late BannerAd _bannerAd;

  @override
  void initState() {
    super.initState();
    _bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: 'Add Your unit id here',
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {});
        },
        onAdFailedToLoad: (ad, error) {
          print('Ad failed to load: $error');
        },
      ),
    );
    _bannerAd.load();
  }

  Future<void> recognizeText(File imageFile) async {
    final InputImage inputImage = InputImage.fromFilePath(imageFile.path);
    final TextRecognizer textRecognizer = TextRecognizer();
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
    setState(() {
      _recognizedLines = recognizedText.text.split('\n');
    });
    textRecognizer.close();
  }

  Future<void> getImageFromGallery() async {
    final XFile? pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      final File pickedFile = File(pickedImage.path);
      setState(() {
        _image = pickedFile;
      });
      await recognizeText(pickedFile);
    }
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
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _image == null
                      ? Text('No image selected.')
                      : Image.file(
                          File(_image!.path),
                          height: 100,
                        ),
                  SizedBox(height: 20),
                  Expanded(
                    child: Container(
                      color: Colors.grey[200],
                      child: ListView.builder(
                        itemCount: _recognizedLines.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                              _recognizedLines[index],
                              style: TextStyle(
                                color: Colors.black, // Set text color to black
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ElevatedButton(
  onPressed: getImageFromGallery,
  child: Text('Select Image'),
  style: ButtonStyle(
    backgroundColor: MaterialStateProperty.all<Color>(Colors.orange),
  ),
),

          if (_image != null)
            ElevatedButton(
              onPressed: () {
                final String recognizedText = _recognizedLines.join('\n');
                FlutterClipboard.copy(recognizedText).then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Text copied to clipboard')),
                  );
                });
              },
              child: Text('Copy Text'),
              style: ButtonStyle(
    backgroundColor: MaterialStateProperty.all<Color>(Colors.orange),
  ),
            ),
          if (_bannerAd != null && _bannerAd.size != null)
            Container(
              width: MediaQuery.of(context).size.width,
              height: _bannerAd.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd),
            ),
        ],
      ),
    );
  }
}
