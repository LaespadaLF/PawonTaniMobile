import 'package:flutter/material.dart';

class RecordSaleScreen extends StatefulWidget {
  const RecordSaleScreen({super.key});

  @override
  State<RecordSaleScreen> createState() => _RecordSaleScreenState();
}

class _RecordSaleScreenState extends State<RecordSaleScreen> {
  static const Color _primaryGreen = Color(0xFF285438);
  static const Color _textDark = Color(0xFF0F2018);
  static const Color _textMedium = Color(0xFF3D5C49);
  static const Color _textLight = Color(0xFF6B8572);
  static const Color _bgPage = Color(0xFFF4F7F5);
  static const Color _cardBg = Colors.white;
  static const Color _borderColor = Color(0xFFE2EDE5);
  static const Color _lightGreenBg = Color(0xFFEDF7F0);

  String? _selectedStock;
  DateTime? _saleDate;
  double _volumeKg = 2500;
  double _pricePerKg = 6900;
  int _selectedPaymentMethod = 0;
  bool _showSuccessModal = false;

  final List<String> _stocks = [
    'GKP Ciherang - Sisa: 4.850 Kg',
    'Jagung Manis Hibrida - Sisa: 3.200 Kg',
  ];

  @override
  void initState() {
    super.initState();
    _selectedStock = _stocks[0];
    _saleDate = DateTime(2024, 11, 15);
  }

  String _formatNum(int num) {
    final s = num.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  String _formatDate(DateTime date) {
    const months = ['', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    return '${date.day} ${months[date.month]} ${date.year}';
  }

  double get _totalValue => _volumeKg * _pricePerKg;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgPage,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        _buildFinancialTag(),
                        const SizedBox(height: 12),
                        _buildStockPicker(),
                        const SizedBox(height: 12),
                        _buildSaleDateSection(),
                        const SizedBox(height: 12),
                        _buildVolumeSection(),
                        const SizedBox(height: 12),
                        _buildPriceSection(),
                        const SizedBox(height: 12),
                        _buildSummaryCard(),
                        const SizedBox(height: 12),
                        _buildPaymentMethodSection(),
                        const SizedBox(height: 12),
                        _buildReceiptSection(),
                        const SizedBox(height: 12),
                        _buildNotesSection(),
                        const SizedBox(height: 12),
                        _buildSaveButton(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (_showSuccessModal)
              _buildSuccessModal(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 20, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: const Color(0xFFF2F7F4), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: _textMedium),
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('PAWON TANI', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, color: _primaryGreen, letterSpacing: 1.2)),
              Text('Tambah Penjualan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _textDark, letterSpacing: -0.2)),
            ],
          ),
          const Spacer(),
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: const Color(0xFFF2F7F4), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.notifications_outlined, size: 18, color: _textMedium),
          ),
          const SizedBox(width: 8),
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: const Color(0xFFF2F7F4), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.person_outline_rounded, size: 18, color: _textMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialTag() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _lightGreenBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD6EADB)),
      ),
      child: const Row(
        children: [
          Icon(Icons.bookmark_added_rounded, color: _primaryGreen, size: 14),
          SizedBox(width: 8),
          Text('# PENCATATAN FINANSIAL',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: _primaryGreen, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildStockPicker() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: _borderColor)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Catat Penjualan Hasil Panen',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _textDark)),
            const SizedBox(height: 4),
            const Text('Pantauan kas dan penjualan stok lumbung secara transparan.',
                style: TextStyle(fontSize: 11, color: _textLight)),
            const SizedBox(height: 12),
            const Text('Pilih Stok Panen', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _textDark)),
            const SizedBox(height: 6),
            const Row(
              children: [
                Text('Tersedia', style: TextStyle(fontSize: 11, color: _textLight)),
              ],
            ),
            const SizedBox(height: 8),
            // Stock dropdown
            ..._stocks.asMap().entries.map((e) {
              final stock = e.value;
              final selected = _selectedStock == stock;
              return GestureDetector(
                onTap: () => setState(() => _selectedStock = stock),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: selected ? _lightGreenBg : const Color(0xFFF7FAF8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: selected ? _primaryGreen : _borderColor, width: selected ? 1.5 : 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 30, height: 30,
                        decoration: BoxDecoration(
                          color: selected ? _primaryGreen : const Color(0xFFEDF2EF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(selected ? Icons.check_rounded : Icons.grain_rounded,
                            color: selected ? Colors.white : _textLight, size: 15),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(stock,
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                                color: selected ? _primaryGreen : _textDark)),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFF7FAF8), borderRadius: BorderRadius.circular(10)),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 13, color: _textLight),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text('Sumber: Panen 28 Okt 2024 (Petak Sawah Barat, Kadar Air - 14%)',
                        style: TextStyle(fontSize: 10.5, color: _textLight)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaleDateSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: _borderColor)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tanggal Penjualan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _textDark)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _saleDate ?? DateTime.now(),
                  firstDate: DateTime(2024),
                  lastDate: DateTime.now(),
                  builder: (ctx, child) {
                    return Theme(
                      data: Theme.of(ctx).copyWith(
                        colorScheme: const ColorScheme.light(primary: _primaryGreen),
                      ),
                      child: child!,
                    );
                  },
                );
                if (date != null) setState(() => _saleDate = date);
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: const Color(0xFFF7FAF8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _borderColor)),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 16, color: _primaryGreen),
                    const SizedBox(width: 10),
                    Text(_saleDate != null ? _formatDate(_saleDate!) : 'Pilih Tanggal',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _textDark)),
                    const Spacer(),
                    const Icon(Icons.chevron_right_rounded, color: _textLight, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVolumeSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: _borderColor)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Volume yang Dijual', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _textDark)),
            const SizedBox(height: 8),
            // Quick amounts
            Row(
              children: ['25%', '50%', '75%', 'Semua'].map((label) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      final stock = 4850.0;
                      double val;
                      if (label == '25%') { val = stock * 0.25; }
                      else if (label == '50%') { val = stock * 0.5; }
                      else if (label == '75%') { val = stock * 0.75; }
                      else { val = stock; }
                      setState(() => _volumeKg = val);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7FAF8),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _borderColor),
                      ),
                      child: Text(label,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _textMedium)),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            // Slider
            Row(
              children: [
                Text('${_formatNum(_volumeKg.toInt())} Kg',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _textDark)),
                const Spacer(),
                Text('Maks: 4.850 Kg', style: const TextStyle(fontSize: 11, color: _textLight)),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: _primaryGreen,
                inactiveTrackColor: const Color(0xFFE2EDE5),
                thumbColor: _primaryGreen,
                overlayColor: const Color(0xFF285438).withValues(alpha: 0.1),
              ),
              child: Slider(
                value: _volumeKg,
                min: 100,
                max: 4850,
                divisions: 97,
                onChanged: (val) => setState(() => _volumeKg = val),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: _borderColor)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Harga Satuan per Kg', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _textDark)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: const Color(0xFFF7FAF8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _borderColor)),
              child: Row(
                children: [
                  const Text('Rp', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _primaryGreen)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_formatNum(_pricePerKg.toInt()),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _textDark)),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _pricePerKg = (_pricePerKg - 100).clamp(1000, 20000)),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: _lightGreenBg, borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.remove_rounded, color: _primaryGreen, size: 16),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => setState(() => _pricePerKg = (_pricePerKg + 100).clamp(1000, 20000)),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: _primaryGreen, borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.add_rounded, color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFFFFF8E1), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFFFE082))),
              child: const Text('\u25B2 Acuan HPP Poktan hari ini: Rp 6.700 - Rp 7.100 /Kg',
                  style: TextStyle(fontSize: 10.5, color: Color(0xFF7B5800), fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A3828), Color(0xFF285438), Color(0xFF2D6040)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: const Color(0xFF285438).withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text('RINGKASAN NILAI JUAL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white70, letterSpacing: 0.5)),
                Spacer(),
                Text('\u2713 Otomatis', style: TextStyle(fontSize: 10, color: Color(0xFF81C784), fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Rp ${_formatNum(_totalValue.toInt())}',
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1)),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${_formatNum(_volumeKg.toInt())} Kg x Rp ${_formatNum(_pricePerKg.toInt())}',
                        style: const TextStyle(fontSize: 10, color: Colors.white60)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    final methods = [
      _PayMethod(Icons.account_balance_rounded, 'Lunas (Transfer Bank BRI)', 'Rekening Poktan: 0129-01-xxx-55-01', const Color(0xFF0077B6)),
      _PayMethod(Icons.payments_rounded, 'Lunas (Tunai Langsung)', 'Pembayaran kas kontan di area Lumbung', const Color(0xFF6D4C41)),
      _PayMethod(Icons.schedule_rounded, 'Tempo / Berhenti (DP 50%)\nPelunasan H+7 pasca-penyerahan', 'Sisa dilunaskan setelah batas toleransi', const Color(0xFFE65100)),
    ];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: _borderColor)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: Row(
              children: [
                const Icon(Icons.payment_rounded, size: 15, color: _primaryGreen),
                const SizedBox(width: 8),
                const Expanded(child: Text('Metode & Status Bayar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _textDark))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(color: _lightGreenBg, borderRadius: BorderRadius.circular(8)),
                  child: const Text('1 Terpilih', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _primaryGreen)),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFFEDF2EF), height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: methods.asMap().entries.map((e) {
                final i = e.key;
                final m = e.value;
                final selected = _selectedPaymentMethod == i;
                return GestureDetector(
                  onTap: () => setState(() => _selectedPaymentMethod = i),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: selected ? _lightGreenBg : const Color(0xFFF7FAF8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: selected ? _primaryGreen : _borderColor, width: selected ? 1.5 : 1),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 18, height: 18,
                          margin: const EdgeInsets.only(top: 2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: selected ? _primaryGreen : _borderColor, width: 2),
                            color: selected ? _primaryGreen : Colors.transparent,
                          ),
                          child: selected ? const Icon(Icons.check, color: Colors.white, size: 10) : null,
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(color: m.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(7)),
                          child: Icon(m.icon, color: m.color, size: 14),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(m.title,
                                  style: TextStyle(fontSize: 12, fontWeight: selected ? FontWeight.w800 : FontWeight.w600, color: _textDark)),
                              const SizedBox(height: 2),
                              Text(m.subtitle, style: const TextStyle(fontSize: 10.5, color: _textLight, height: 1.3)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: _borderColor)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Lampiran Bukti Nota / Timbangan    Opsional',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _textDark)),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {},
              child: Container(
                width: double.infinity,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7FAF8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _borderColor),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: _lightGreenBg, shape: BoxShape.circle),
                      child: const Icon(Icons.add_a_photo_rounded, color: _primaryGreen, size: 18),
                    ),
                    const SizedBox(height: 5),
                    const Text('Ambil Foto Nota\nKamera HP saja',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, color: _textLight, height: 1.3)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: _borderColor)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Catatan Penjualan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _textDark)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                  color: const Color(0xFFF7FAF8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _borderColor)),
              child: const TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Berasal dari Kebun Sosial, kadar air antam 16%, langsung dianglur armada trk Koperasi...',
                  hintStyle: TextStyle(color: _textLight, fontSize: 11.5),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12),
                ),
                style: TextStyle(fontSize: 12.5, color: _textDark, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => setState(() => _showSuccessModal = true),
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryGreen,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          icon: const Icon(Icons.save_rounded, size: 18),
          label: const Text('Simpan Transaksi Penjualan',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }

  Widget _buildSuccessModal(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _showSuccessModal = false),
      child: Container(
        color: Colors.black.withValues(alpha: 0.65),
        child: Center(
          child: GestureDetector(
            onTap: () {}, // prevent dismiss when tapping modal
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                children: [
                  // Close button
                  Positioned(
                    top: 14,
                    right: 14,
                    child: GestureDetector(
                      onTap: () => setState(() => _showSuccessModal = false),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        child: const Icon(Icons.close_rounded, size: 20, color: _textLight),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Success Icon
                        Container(
                          width: 70,
                          height: 70,
                          decoration: const BoxDecoration(color: Color(0xFFE2F4E7), shape: BoxShape.circle),
                          child: Center(
                            child: Container(
                              width: 46,
                              height: 46,
                              decoration: const BoxDecoration(color: Color(0xFF388E52), shape: BoxShape.circle),
                              child: const Icon(Icons.check_rounded, color: Colors.white, size: 26),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('Transaksi Berhasil Disimpan!',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _textDark, letterSpacing: -0.3),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 8),
                        const Text(
                            'Data penjualan sudah tersimpan di sistem. Saldo dan stok lumbung telah diperbarui sesuai data.',
                            style: TextStyle(fontSize: 12, color: _textLight, height: 1.4),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        // Info Box
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDF7F1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFD6EADB)),
                          ),
                          child: Column(
                            children: [
                              _buildModalRow(Icons.confirmation_number_outlined, 'No. Tiket / ID', 'TRX-PN-20241115-889'),
                              const Divider(color: Color(0xFFDCECE1), height: 16),
                              _buildModalRow(Icons.grain_rounded, 'Komoditas', 'GKP Ciherang'),
                              const Divider(color: Color(0xFFDCECE1), height: 16),
                              _buildModalRow(Icons.scale_rounded, 'Volume & Harga',
                                  '${_formatNum(_volumeKg.toInt())} Kg x Rp ${_formatNum(_pricePerKg.toInt())}'),
                              const Divider(color: Color(0xFFDCECE1), height: 16),
                              _buildModalRow(Icons.groups_2_outlined, 'Mitra Pembeli', 'Poktan Sumber Makmur'),
                              const Divider(color: Color(0xFFDCECE1), height: 16),
                              _buildModalRow(Icons.inventory_rounded, 'Sisa Stok Lumbung', '2.350 Kg (tersisa)'),
                              const Divider(color: Color(0xFFDCECE1), height: 16),
                              Row(
                                children: [
                                  const Icon(Icons.payments_rounded, size: 14, color: Color(0xFF556C5E)),
                                  const SizedBox(width: 8),
                                  const Expanded(child: Text('Total Nilai',
                                      style: TextStyle(fontSize: 11.5, color: Color(0xFF556C5E)))),
                                  Text('Rp ${_formatNum(_totalValue.toInt())}',
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: _primaryGreen)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Primary button
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() => _showSuccessModal = false);
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryGreen,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            ),
                            icon: const Icon(Icons.receipt_long_rounded, size: 16, color: Colors.white),
                            label: const Text('Lihat Rincian & Cetak Nota',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // WhatsApp button
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF25D366),
                              side: const BorderSide(color: Color(0xFF25D366), width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            ),
                            icon: const Icon(Icons.share_rounded, size: 16),
                            label: const Text('Bagikan ke WhatsApp Mitra',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () {
                            setState(() => _showSuccessModal = false);
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: const Text('Kembali ke Riwayat Penjualan',
                              style: TextStyle(fontSize: 12, color: _textLight, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModalRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF556C5E)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 11.5, color: Color(0xFF556C5E))),
        const Spacer(),
        Flexible(
          child: Text(value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF15261B))),
        ),
      ],
    );
  }
}

class _PayMethod {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _PayMethod(this.icon, this.title, this.subtitle, this.color);
}
