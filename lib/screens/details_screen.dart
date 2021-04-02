import 'package:flutter/material.dart';
import '../models/image_model.dart';

class DetailsScreen extends StatelessWidget {
  final ImageModel image;

  const DetailsScreen({@required this.image, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: Container(
          margin: const EdgeInsets.all(10),
          color: Colors.black12,
          height: 400,
          child: Column(
            children: [
              Image.asset(
                image.imageUrl,
                width: double.infinity,
              ),
              Text(
                image.result ?? 'Result: Negative',
                style: const TextStyle(fontSize: 20),
              )
            ],
          ),
        ),
      );
}
