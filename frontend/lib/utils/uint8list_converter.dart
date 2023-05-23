

import 'dart:typed_data';

import 'package:json_annotation/json_annotation.dart';

class Uint8ListConverter implements JsonConverter<Uint8List, List<int>> {
  const Uint8ListConverter();

  @override
  Uint8List fromJson(List<int> ints) {
    return Uint8List.fromList(ints);
  }

  @override
  List<int> toJson(Uint8List uint8List) {
    return uint8List.toList();
  }
}