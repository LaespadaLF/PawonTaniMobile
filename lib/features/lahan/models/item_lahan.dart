import 'package:flutter/material.dart';

enum StatusLahan {
  aktif,
  istirahat,
  persiapan,
}

class ItemLahan {
  final String id;
  final String nama;
  final String lokasi;
  final double luas;
  final String komoditas;
  final StatusLahan status;

  const ItemLahan({
    required this.id,
    required this.nama,
    required this.lokasi,
    required this.luas,
    required this.komoditas,
    required this.status,
  });

  ItemLahan copyWith({
    String? id,
    String? nama,
    String? lokasi,
    double? luas,
    String? komoditas,
    StatusLahan? status,
  }) {
    return ItemLahan(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      lokasi: lokasi ?? this.lokasi,
      luas: luas ?? this.luas,
      komoditas: komoditas ?? this.komoditas,
      status: status ?? this.status,
    );
  }
}
