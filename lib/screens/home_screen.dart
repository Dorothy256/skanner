import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key key}) : super(key: key);

  static Route<Widget> router() =>
      MaterialPageRoute<Widget>(builder: (_) => const HomeScreen());

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Skanner'),
        ),
      );
}
