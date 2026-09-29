import 'package:flutter/material.dart';

enum LandStatus {
  aktif,
  istirahat,
  persiapan,
}

class LandItem {
  final String id;
  final String name;
  final String location;
  final double area;
  final String currentCrop;
  final LandStatus status;

  const LandItem({
    required this.id,
    required this.name,
    required this.location,
    required this.area,
    required this.currentCrop,
    required this.status,
  });

  LandItem copyWith({
    String? id,
    String? name,
    String? location,
    double? area,
    String? currentCrop,
    LandStatus? status,
  }) {
    return LandItem(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      area: area ?? this.area,
      currentCrop: currentCrop ?? this.currentCrop,
      status: status ?? this.status,
    );
  }
}
