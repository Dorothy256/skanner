import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => const HomeScreen());

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _picker = ImagePicker();

  File _file;
  List _outputs;

  @override
  void initState() {
    super.initState();

    _loadModel();
  }

  @override
  void dispose() async {
    super.dispose();

    await Tflite.close();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Skanner',
            style: TextStyle(
                letterSpacing: 1.2, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
                icon: const Icon(
                  Icons.exit_to_app,
                  size: 28,
                ),
                onPressed: () {})
          ],
        ),
        body: _file != null
            ? RenderPickedImage(
                pickedFile: _file,
                outputs: _outputs,
              )
            : const Center(child: Text('No image selected')),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _getImageFromGallery();
          },
          child: const Icon(Icons.add_a_photo),
        ),
      );

  void _getImageFromGallery() async {
    final imageFile = await _picker.getImage(source: ImageSource.gallery);

    if (imageFile == null) {
      return null;
    }

    final pickedFile = File(imageFile.path);

    final outputs = await Tflite.runModelOnImage(
      path: pickedFile.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );

    if (mounted) {
      setState(() {
        _file = pickedFile;
        _outputs = outputs;
      });
    }
  }

  void _loadModel() async {
    await Tflite.loadModel(
        model: 'assets/model_unquant.tflite', labels: 'assets/labels.txt');
  }
}

class RenderPickedImage extends StatelessWidget {
  final File pickedFile;
  final List outputs;

  const RenderPickedImage(
      {@required this.pickedFile, @required this.outputs, Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Flexible(flex: 2, child: Image.file(pickedFile)),
          Flexible(
              child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${outputs[0]['label']}'.replaceAll(
                    RegExp(r'[0-9]'),
                    '',
                  ),
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text('${outputs[0]['confidence']}%',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w500))
              ],
            ),
          ))
        ],
      );
}
