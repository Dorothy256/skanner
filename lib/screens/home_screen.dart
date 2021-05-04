import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'package:url_launcher/url_launcher.dart';

import '../blocs/authentication/authentication_bloc.dart';
import 'log_in_screen.dart';

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
          backgroundColor: Colors.white,
          centerTitle: true,
          title: const Text(
            'Skin Skanner',
            style: TextStyle(
                letterSpacing: 1.2,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black),
          ),
          actions: [
            IconButton(
                icon: const Icon(
                  Icons.exit_to_app,
                  size: 28,
                  color: Colors.black,
                ),
                onPressed: () {
                  context.read<AuthenticationBloc>().add(LogOut());
                  Navigator.of(context).pushAndRemoveUntil(
                      LogInScreen.route(), (route) => false);
                })
          ],
        ),
        body: _file != null
            ? RenderPickedImage(
                pickedFile: _file,
                outputs: _outputs,
              )
            : const Center(child: Text('No image selected')),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.orangeAccent,
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
  Widget build(BuildContext context) {
    var confidence = (outputs[0]['confidence'] * 100).toString();
    confidence = double.parse(confidence).toStringAsFixed(2);

    return Column(
      children: [
        Flexible(flex: 2, child: Image.file(pickedFile)),
        Flexible(
            child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (outputs[0]['label'] == '1 positive')
                        Expanded(
                          child: Column(
                            children: [
                              Text('$confidence%',
                                  style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(
                                height: 20,
                              ),
                              const Text(
                                'Positive, you have eczema',
                                style: TextStyle(
                                    fontSize: 28, fontWeight: FontWeight.bold),
                              ),
                              const Text(
                                'Please consult a dermatologist',
                                style: TextStyle(fontSize: 20),
                              ),
                              TextButton(
                                  onPressed: () => _launchUrl(
                                      'https://www.unityskinclinic.com/'),
                                  child: const Text('Unity Skin Clinic',
                                      style: TextStyle(
                                        fontSize: 22,
                                      ))),
                            ],
                          ),
                        ),
                      if (outputs[0]['label'] != '1 positive')
                        Expanded(
                            child: Column(
                          children: [
                            Text('$confidence%',
                                style: const TextStyle(
                                    fontSize: 28, fontWeight: FontWeight.w500)),
                            const Text(
                              "Negative, you don't have eczema",
                              style: TextStyle(
                                  fontSize: 28, fontWeight: FontWeight.bold),
                            ),
                            TextButton(
                                onPressed: () => _launchUrl(
                                    'https://my.clevelandclinic.org/health/diseases/9998-eczema'),
                                child: const Text('How to prevent Eczema',
                                    style: TextStyle(
                                      fontSize: 20,
                                    )))
                          ],
                        )),
                    ])))
      ],
    );
  }

  void _launchUrl(String url) async =>
      await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';
}
