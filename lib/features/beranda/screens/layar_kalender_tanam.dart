import 'package:flutter/material.dart';
import 'package:pawon_mobile/core/network/dio_client.dart';
import 'package:pawon_mobile/core/theme/warna_aplikasi.dart';

class LayarKalenderTanam extends StatefulWidget {
  const LayarKalenderTanam({super.key});

  @override
  State<LayarKalenderTanam> createState() => _LayarKalenderTanamState();
}

class _LayarKalenderTanamState extends State<LayarKalenderTanam> {
  final DioClient _client = DioClient();
  bool _isLoading = true;
  String? _errorMessage;
  Map<String, dynamic>? _kalenderData;

  @override
  void initState() {
    super.initState();
    _loadKalenderData();
  }

  Future<void> _loadKalenderData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final res = await _client.get<Map<String, dynamic>>(
        '/komoditas/kalender-tanam',
        fromJson: (data) => Map<String, dynamic>.from(data as Map),
      );

      if (res.success && res.data != null) {
        setState(() {
          _kalenderData = res.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = res.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      // Fallback data sinkron dengan Web Pengurus
      setState(() {
        _kalenderData = {
          'musim_aktif': 'MT-I (Rendeng)',
          'periode': 'Oktober - Februari',
          'komoditas_utama': 'Padi Sawah & Palawija',
          'tahap_siklus': [
            {
              'kode': 'Fase 01',
              'judul': 'Persiapan & Semai',
              'deskripsi': 'Olah tanah, persemaian bibit, dan perbaikan pematang sawah.',
              'status': 'selesai',
            },
            {
              'kode': 'Fase 02',
              'judul': 'Vegetatif & Rawat',
              'deskripsi': 'Pembentukan anakan aktif, penyiangan gulma, dan pemupukan susulan I & II.',
              'status': 'berjalan',
            },
            {
              'kode': 'Fase 03',
              'judul': 'Generatif & Panen',
              'deskripsi': 'Fase bunting, pembungaan, pengisian bulir padi, dan persiapan panen raya.',
              'status': 'mendatang',
            },
          ],
          'rekomendasi_pekan_ini': [
            {
              'judul': 'Pengairan Berselang (Intermittent)',
              'deskripsi': 'Keringkan lahan 2-3 hari untuk merangsang oksigenasi perakaran.',
              'kategori': 'Pengairan',
            },
            {
              'judul': 'Monitoring Penggerek Batang & Wereng Coklat',
              'deskripsi': 'Amati rumpun padi bagian bawah pada pagi hari.',
              'kategori': 'Pencegahan Hama',
            },
            {
              'judul': 'Pemupukan Susulan Lanjutan',
              'deskripsi': 'Gunakan kombinasi NPK dan Urea berimbang sesuai dosis e-RDKK.',
              'kategori': 'Nutrisi & Pupuk',
            },
          ],
        };
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgCol = WarnaAplikasi.getBackgroundColor(context);
    final cardCol = WarnaAplikasi.getCardColor(context);
    final borderCol = isDark ? const Color(0xFF28332C) : const Color(0xFFE4F0D6);
    final textDark = isDark ? Colors.white : const Color(0xFF1A2D10);
    final textSub = isDark ? const Color(0xFFA0B3A6) : const Color(0xFF6B7F5B);

    return Scaffold(
      backgroundColor: bgCol,
      appBar: AppBar(
        title: const Text(
          'Kalender Musim Tanam',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        backgroundColor: isDark ? const Color(0xFF1D2420) : WarnaAplikasi.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: WarnaAplikasi.primary))
          : RefreshIndicator(
              onRefresh: _loadKalenderData,
              color: WarnaAplikasi.primary,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Banner Musim Aktif
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF233027) : const Color(0xFFEBF6E0),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? const Color(0xFF2E4034) : const Color(0xFFD1DFC4),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF4D9830),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Musim Tanam Aktif',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isDark ? const Color(0xFFBBE59E) : const Color(0xFF2E5A1C),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _kalenderData?['musim_aktif'] ?? 'MT-I (Rendeng)',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Periode: ${_kalenderData?['periode'] ?? 'Oktober - Februari'} • Komoditas: ${_kalenderData?['komoditas_utama'] ?? 'Padi Sawah'}',
                          style: TextStyle(fontSize: 12, color: textSub),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Header Siklus Tanam
                  Text(
                    'Siklus Fase Budidaya',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Cards Fase Budidaya
                  ...((_kalenderData?['tahap_siklus'] as List<dynamic>? ?? []).map((fase) {
                    final status = fase['status'] as String? ?? 'mendatang';
                    final isDone = status == 'selesai';
                    final isCurrent = status == 'berjalan';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? (isDark ? const Color(0xFF223528) : const Color(0xFFEBF6E0).withOpacity(0.6))
                            : cardCol,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isCurrent ? const Color(0xFF4D9830) : borderCol,
                          width: isCurrent ? 1.5 : 1.0,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            isDone
                                ? Icons.check_circle_rounded
                                : (isCurrent ? Icons.play_circle_fill_rounded : Icons.schedule_rounded),
                            color: isDone
                                ? const Color(0xFF4D9830)
                                : (isCurrent ? const Color(0xFF4D9830) : Colors.grey),
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      fase['kode'] ?? '',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isCurrent
                                            ? (isDark ? const Color(0xFFBBE59E) : const Color(0xFF2E5A1C))
                                            : textSub,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isDone
                                            ? Colors.green.withOpacity(0.15)
                                            : (isCurrent
                                                ? Colors.green.withOpacity(0.2)
                                                : Colors.grey.withOpacity(0.15)),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        status.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: isDone || isCurrent
                                              ? const Color(0xFF4D9830)
                                              : Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  fase['judul'] ?? '',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: textDark,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  fase['deskripsi'] ?? '',
                                  style: TextStyle(fontSize: 11.5, color: textSub),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  })),

                  const SizedBox(height: 16),

                  // Header Rekomendasi Pekan Ini
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Color(0xFF4D9830), size: 18),
                      const SizedBox(width: 6),
                      Text(
                        'Rekomendasi Tindakan Pekan Ini',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  ...((_kalenderData?['rekomendasi_pekan_ini'] as List<dynamic>? ?? []).map((rek) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cardCol,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderCol),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4D9830).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              rek['kategori'] ?? 'Agronomi',
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4D9830),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            rek['judul'] ?? '',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: textDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            rek['deskripsi'] ?? '',
                            style: TextStyle(fontSize: 11.5, color: textSub),
                          ),
                        ],
                      ),
                    );
                  })),
                ],
              ),
            ),
    );
  }
}
