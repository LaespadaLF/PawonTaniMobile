import 'package:flutter/material.dart';
import 'package:pawon_mobile/core/theme/warna_aplikasi.dart';
import 'package:pawon_mobile/features/lahan/models/item_komoditas.dart';

/// Menampilkan pemilih komoditas sebagai bottom sheet (bukan halaman penuh)
/// dengan pencarian nama komoditas.
///
/// Mengembalikan [ItemKomoditas] yang dipilih, atau `null` bila pengguna menutup
/// sheet tanpa memilih.
///
/// Dipakai bersama oleh form Siklus Tanam (lahan) dan form Produk (penjualan)
/// supaya perilakunya konsisten di seluruh aplikasi.
Future<ItemKomoditas?> tampilkanPemilihKomoditas(
  BuildContext context, {
  required List<ItemKomoditas> daftar,
  String? idTerpilih,
  String judul = 'Pilih Komoditas',
}) {
  return showModalBottomSheet<ItemKomoditas>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SheetPemilihKomoditas(
      daftar: daftar,
      idTerpilih: idTerpilih,
      judul: judul,
    ),
  );
}

class _SheetPemilihKomoditas extends StatefulWidget {
  final List<ItemKomoditas> daftar;
  final String? idTerpilih;
  final String judul;

  const _SheetPemilihKomoditas({
    required this.daftar,
    required this.judul,
    this.idTerpilih,
  });

  @override
  State<_SheetPemilihKomoditas> createState() => _SheetPemilihKomoditasState();
}

class _SheetPemilihKomoditasState extends State<_SheetPemilihKomoditas> {
  final TextEditingController _searchController = TextEditingController();
  late List<ItemKomoditas> _hasil;

  @override
  void initState() {
    super.initState();
    _hasil = widget.daftar;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filter(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      _hasil = q.isEmpty
          ? widget.daftar
          : widget.daftar
              .where((k) =>
                  k.namaKomoditas.toLowerCase().contains(q) ||
                  k.kategori.toLowerCase().contains(q))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF161C18) : Colors.white;
    final titleColor = WarnaAplikasi.getTitleColor(context);
    final subtitleColor = WarnaAplikasi.getSubtitleColor(context);
    final borderColor = WarnaAplikasi.getBorderColor(context);
    final inputBg = WarnaAplikasi.getInputColor(context);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: borderColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.judul,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: titleColor,
                          ),
                        ),
                      ),
                      Text(
                        '${widget.daftar.length} komoditas',
                        style: TextStyle(fontSize: 11, color: subtitleColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchController,
                    autofocus: true,
                    onChanged: _filter,
                    style: TextStyle(fontSize: 13, color: titleColor),
                    decoration: InputDecoration(
                      hintText: 'Cari nama komoditas...',
                      hintStyle: TextStyle(fontSize: 13, color: subtitleColor),
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: WarnaAplikasi.primary, size: 20),
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              icon: Icon(Icons.close_rounded,
                                  size: 18, color: subtitleColor),
                              onPressed: () {
                                _searchController.clear();
                                _filter('');
                              },
                            ),
                      filled: true,
                      fillColor: inputBg,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                            color: WarnaAplikasi.primary, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _hasil.isEmpty
                        ? Center(
                            child: Text(
                              'Komoditas tidak ditemukan',
                              style:
                                  TextStyle(fontSize: 13, color: subtitleColor),
                            ),
                          )
                        : ListView.separated(
                            controller: scrollController,
                            itemCount: _hasil.length,
                            separatorBuilder: (_, _) =>
                                Divider(height: 1, color: borderColor),
                            itemBuilder: (_, i) {
                              final k = _hasil[i];
                              final isSelected = k.idKomoditas == widget.idTerpilih;
                              return ListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 2),
                                onTap: () => Navigator.pop(context, k),
                                leading: Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? WarnaAplikasi.primary
                                        : inputBg,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    isSelected
                                        ? Icons.check_rounded
                                        : Icons.eco_rounded,
                                    size: 18,
                                    color: isSelected
                                        ? Colors.white
                                        : WarnaAplikasi.primary,
                                  ),
                                ),
                                title: Text(
                                  k.namaKomoditas,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: titleColor,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    k.umurPanenHari != null
                                        ? '${k.kategori} · ±${k.umurPanenHari} hari'
                                        : k.kategori,
                                    style: TextStyle(
                                        fontSize: 11, color: subtitleColor),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
