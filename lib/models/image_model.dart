import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ImageModel extends Equatable {
  final String id;
  final String userId;
  final String imageUrl;
  final String result;
  final Timestamp timestamp;

  const ImageModel({
    @required this.id,
    @required this.userId,
    @required this.imageUrl,
    @required this.timestamp,
    this.result,
  });

  factory ImageModel.fromSnapshot(DocumentSnapshot doc) => ImageModel(
      id: doc.id,
      userId: doc.data()['userId'] as String,
      imageUrl: doc.data()['imageUrl'] as String,
      timestamp: doc.data()['timestamp'] as Timestamp);

  Map<String, dynamic> toDoc() => {
        'id': id,
        'userId': userId,
        'imageUrl': imageUrl,
        'timestamp': timestamp
      };

  @override
  List<Object> get props => [id, userId, imageUrl, result, timestamp];
}
