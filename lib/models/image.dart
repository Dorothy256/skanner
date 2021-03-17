import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Image extends Equatable {
  final String id;
  final String userId;
  final String imageUrl;
  final String result;
  final Timestamp timestamp;

  const Image({
    @required this.id,
    @required this.userId,
    @required this.imageUrl,
    @required this.timestamp,
    this.result,
  });

  @override
  List<Object> get props => [id, userId, imageUrl, result, timestamp];
}
