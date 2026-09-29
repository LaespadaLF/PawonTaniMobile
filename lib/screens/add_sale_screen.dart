import 'package:flutter/material.dart';
import 'record_sale_screen.dart';

class AddSaleScreen extends StatefulWidget {
  const AddSaleScreen({super.key});

  @override
  State<AddSaleScreen> createState() => _AddSaleScreenState();
}

class _AddSaleScreenState extends State<AddSaleScreen> {
  static const Color _primaryGreen = Color(0xFF285438);
  static const Color _textDark = Color(0xFF0F2018);
  static const Color _textMedium = Color(0xFF3D5C49);
  static const Color _textLight = Color(0xFF6B8572);
  static const Color _bgPage = Color(0xFFF4F7F5);
  static const Color _cardBg = Colors.white;
  static const Color _borderColor = Color(0xFFE2EDE5);
  static const Color _lightGreenBg = Color(0xFFEDF7F0);

  // Form fields
  String? _selectedCommodity;
  DateTime? _selectedDate;
  final TextEditingController _weightController = TextEditingController(text: '2500');
  final TextEditingController _priceController = TextEditingController(text: '6.900');
  int _selectedBuyerIndex = 0; // 0: Koperasi, 1: Pengepul, 2: Langsung
  int _selectedPaymentIndex = 0; // 0: Transfer BRI, 1: Tunai, 2: Tempo

  final List<String> _commodities = [
    'Gabah Kering Panen (Ciherang) - 4.850 Kg',
    'Jagung Manis Hibrida Super - 3.200 Kg',
    'Gabah Kering Giling - 2.000 Kg',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime(2024, 11, 15);
    _selectedCommodity = _commodities[0];
  }

  @override
  void dispose() {
    _weightController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  double get _estimatedTotal {
    final weight = double.tryParse(_weightController.text.replaceAll('.', '')) ?? 0;
    final price = double.tryParse(_priceController.text.replaceAll('.', '').replaceAll(',', '')) ?? 0;
    return weight * price;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgPage,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildInfoBanner(),
                    const SizedBox(height: 12),
                    _buildCommodityPicker(),
                    const SizedBox(height: 12),
                    _buildTransactionDetails(),
                    const SizedBox(height: 12),
                    _buildEstimationCard(),
                    const SizedBox(height: 12),
                    _buildBuyerSection(),
                    const SizedBox(height: 12),
                    _buildPaymentSection(),
                    const SizedBox(height: 12),
                    _buildReceiptSection(),
                    const SizedBox(height: 12),
                    _buildNotesSection(),
                    const SizedBox(height: 12),
                    _buildActionButtons(context),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
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
              width: 36,
              height: 36,
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

  Widget _buildInfoBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [const Color(0xFFE8F5E9), const Color(0xFFEDF7F0)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD6EADB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.celebration_rounded, color: _primaryGreen, size: 16),
              SizedBox(width: 8),
              Text('Alhamdulillah Panen Laku!',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _textDark)),
            ],
          ),
          const SizedBox(height: 6),
          const Text('Yuk, catat pembukuan penjualan anda. Pak Achroni tipis-tipis bisa difoto transaksi yang tertera.',
              style: TextStyle(fontSize: 11, color: _textLight, height: 1.4)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD6EADB)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFF9A825), size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tips Santai: tepukan-pelan langsung masalah, klik lebih lanjut untuk tahu cara selengkapnya.',
                    style: TextStyle(fontSize: 11, color: _textMedium, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommodityPicker() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: _borderColor)),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                const Icon(Icons.inventory_2_outlined, size: 15, color: _primaryGreen),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Padi / Hasil Pemanenan Dijual    Siap Angkut',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: _textDark)),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFFEDF2EF), height: 1),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Commodity Selection with checkmark
                ..._commodities.asMap().entries.map((e) {
                  final commodity = e.value;
                  final isSelected = _selectedCommodity == commodity;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCommodity = commodity),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? _lightGreenBg : const Color(0xFFF7FAF8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: isSelected ? _primaryGreen : _borderColor,
                            width: isSelected ? 1.5 : 1),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32, height: 32,
                            decoration: BoxDecoration(
                                color: isSelected ? _primaryGreen : _borderColor,
                                borderRadius: BorderRadius.circular(8)),
                            child: Icon(
                                isSelected ? Icons.check_rounded : Icons.grain_rounded,
                                color: Colors.white, size: 16),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(commodity,
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected ? _primaryGreen : _textMedium)),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                // Harvest reference info
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFFF7FAF8), borderRadius: BorderRadius.circular(10)),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline_rounded, size: 13, color: _textLight),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Stok Lumbung saat ini: 4.850 Kg',
                          style: TextStyle(fontSize: 11, color: _textLight),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionDetails() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: _borderColor)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date
            const Text('Hari / Tanggal Transaksi',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _textDark)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? DateTime.now(),
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
                if (date != null) setState(() => _selectedDate = date);
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
                    Text(
                        _selectedDate != null ? _formatDate(_selectedDate!) : 'Pilih Tanggal',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textDark)),
                    const Spacer(),
                    const Icon(Icons.chevron_right_rounded, color: _textLight, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Weight
            const Text('Berapa Banyak yang Ditimbang?',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _textDark)),
            const SizedBox(height: 6),
            const Text('Stok Lumbung saat ini: 2.350 Kg',
                style: TextStyle(fontSize: 11, color: _textLight)),
            const SizedBox(height: 8),
            // Quick amount buttons
            Row(
              children: ['25%', '50%', '75%', 'Borong Semua'].map((label) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      final stock = 4850.0;
                      double val = 0;
                      if (label == '25%') { val = stock * 0.25; }
                      else if (label == '50%') { val = stock * 0.5; }
                      else if (label == '75%') { val = stock * 0.75; }
                      else { val = stock; }
                      _weightController.text = val.toInt().toString();
                      setState(() {});
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: label == 'Borong Semua' ? _primaryGreen : const Color(0xFFF7FAF8),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: label == 'Borong Semua' ? _primaryGreen : _borderColor),
                      ),
                      child: Text(label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: label == 'Borong Semua' ? Colors.white : _textMedium)),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            // Weight input
            _buildInput('Berat (Kg)', _weightController, suffix: 'Kg', keyboardType: TextInputType.number),
            const SizedBox(height: 14),
            // Price
            const Text('Kesepakatan Hargaper Kg',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _textDark)),
            const SizedBox(height: 8),
            // HPP reference
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFFFFF8E1), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFFFE082))),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, size: 13, color: Color(0xFFF9A825)),
                  SizedBox(width: 6),
                  Text('Harga mayoritas: Di atas patok HPP paling yg penting (+18% dari harga dasar) \u{1F44D}',
                      style: TextStyle(fontSize: 10.5, color: Color(0xFF7B5800))),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _buildInput('Harga per Kg', _priceController, prefix: 'Rp', keyboardType: TextInputType.number),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String hint, TextEditingController controller, {String? suffix, String? prefix, TextInputType? keyboardType}) {
    return Container(
      decoration: BoxDecoration(
          color: const Color(0xFFF7FAF8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _borderColor)),
      child: Row(
        children: [
          if (prefix != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                  border: Border(right: BorderSide(color: _borderColor))),
              child: Text(prefix, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _primaryGreen)),
            ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: _textLight, fontSize: 13),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              ),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _textDark),
            ),
          ),
          if (suffix != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(suffix, style: const TextStyle(fontSize: 13, color: _textLight)),
            ),
        ],
      ),
    );
  }

  Widget _buildEstimationCard() {
    final total = _estimatedTotal;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A3828), Color(0xFF285438)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: const Color(0xFF285438).withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                child: const Text('ESTIMASI UANG DITERIMA',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white70, letterSpacing: 0.5)),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFF81C784).withValues(alpha: 0.25), borderRadius: BorderRadius.circular(8)),
                child: const Text('Otomatis Dihitung',
                    style: TextStyle(fontSize: 10, color: Color(0xFF81C784), fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('Rp ${_formatNum(total.toInt())}',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1)),
          const SizedBox(height: 6),
          const Text('\u2728 Harga musim ini tambah baiknya!',
              style: TextStyle(fontSize: 11, color: Colors.white60)),
        ],
      ),
    );
  }

  Widget _buildBuyerSection() {
    final buyers = [
      _BuyerOption(
        type: 'Koperasi Poktan Sun',
        label: 'Langganan Desa',
        labelColor: _primaryGreen,
        labelBg: _lightGreenBg,
        subtitle: 'Dikirim pengurus: harga lumbung desa \u2022 Kode PKK-554',
        icon: Icons.account_balance_rounded,
      ),
      _BuyerOption(
        type: 'Pengepul Pasar Induk (Pak. H. Sukirman)',
        label: '',
        labelColor: _textLight,
        labelBg: Colors.transparent,
        subtitle: 'Penjualan langsung pengepul tanpa sarat masuk',
        icon: Icons.store_rounded,
      ),
      _BuyerOption(
        type: 'Warga / Konsumen Eceran Langsung',
        label: '',
        labelColor: _textLight,
        labelBg: Colors.transparent,
        subtitle: 'Dijual-eceran, petani kurang catatan surat mandiri warga',
        icon: Icons.person_rounded,
      ),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: _borderColor)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Siapa yang Membeli?',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _textDark)),
            const SizedBox(height: 4),
            const Text('Pilih golongan pembeli atau mitra yang mau memyai panen',
                style: TextStyle(fontSize: 11, color: _textLight)),
            const SizedBox(height: 12),
            ...buyers.asMap().entries.map((e) {
              final i = e.key;
              final buyer = e.value;
              final selected = _selectedBuyerIndex == i;
              return GestureDetector(
                onTap: () => setState(() => _selectedBuyerIndex = i),
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
                      // Radio dot
                      Container(
                        width: 18, height: 18,
                        margin: const EdgeInsets.only(top: 2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: selected ? _primaryGreen : _borderColor, width: 2),
                          color: selected ? _primaryGreen : Colors.transparent,
                        ),
                        child: selected
                            ? const Icon(Icons.check, color: Colors.white, size: 10)
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(buyer.type,
                                      style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                                          color: _textDark)),
                                ),
                                if (buyer.label.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                    decoration: BoxDecoration(color: buyer.labelBg, borderRadius: BorderRadius.circular(8)),
                                    child: Text(buyer.label,
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: buyer.labelColor)),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(buyer.subtitle,
                                style: const TextStyle(fontSize: 10.5, color: _textLight, height: 1.3)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
            // Buyer name
            const Text('Nama Kontak yang Dikenal',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _textDark)),
            const SizedBox(height: 8),
            _buildInputStatic('Bpk. H. Sukirman (Pengurus Koperasi)'),
            const SizedBox(height: 10),
            // Phone
            const Text('No. HP / Whatsapp (jika ada Kontak / Koordinasi)',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _textDark)),
            const SizedBox(height: 8),
            _buildInputStatic('0812 8899 7711'),
          ],
        ),
      ),
    );
  }

  Widget _buildInputStatic(String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: const Color(0xFFF7FAF8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _borderColor)),
      child: Row(
        children: [
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _textDark))),
          const Icon(Icons.chevron_right_rounded, color: _textLight, size: 18),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: _cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: _borderColor)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Cara Pembayaran    Sudah Dipilih',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _textDark)),
            const SizedBox(height: 12),
            // Payment options
            _buildPaymentOption(0, Icons.account_balance_rounded, 'Transfer Bank BRI (Langsung Poktan)',
                'Dana diterima langsung di Rekening Poktan BRI', const Color(0xFF0077B6)),
            const SizedBox(height: 8),
            _buildPaymentOption(1, Icons.payments_rounded, 'Tunai / Uang Kontan di Tempat',
                'Diterima langsung di area Lumbung', const Color(0xFF6D4C41)),
            const SizedBox(height: 8),
            _buildPaymentOption(2, Icons.schedule_rounded, 'Tempo / Bayar DP (50% Pelunasan) 1 Minggu',
                'Sisa dilunaskan setelah batas toleransi', const Color(0xFFE65100)),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(int index, IconData icon, String title, String subtitle, Color color) {
    final selected = _selectedPaymentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedPaymentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
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
                  color: selected ? _primaryGreen : Colors.transparent),
              child: selected ? const Icon(Icons.check, color: Colors.white, size: 10) : null,
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 12, fontWeight: selected ? FontWeight.w800 : FontWeight.w600, color: _textDark)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 10.5, color: _textLight, height: 1.3)),
                ],
              ),
            ),
          ],
        ),
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
            const Text('Foto Timbangan / Nota    Bolehkosongkan bila tidak ada',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _textDark)),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {},
              child: Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFF7FAF8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _borderColor, style: BorderStyle.solid, width: 1.5),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: _lightGreenBg, shape: BoxShape.circle),
                      child: const Icon(Icons.add_a_photo_rounded, color: _primaryGreen, size: 22),
                    ),
                    const SizedBox(height: 6),
                    const Text('Jepret Nota Baru\nKamera HP saja',
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
            const Text('Catatan Tambahan (Opsional)',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _textDark)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                  color: const Color(0xFFF7FAF8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _borderColor)),
              child: const TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Berasal dari Kebun Sosial, kadar air antam 16%, langsung dianglur armada trk.',
                  hintStyle: TextStyle(color: _textLight, fontSize: 12),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12),
                ),
                style: TextStyle(fontSize: 13, color: _textDark, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Main save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const RecordSaleScreen()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save_rounded, size: 18),
                  SizedBox(width: 8),
                  Text('Berikut, Simpan Penjualan \u203a',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Nanti Dulu / Kembali',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: _textLight)),
          ),
        ],
      ),
    );
  }
}

class _BuyerOption {
  final String type;
  final String label;
  final Color labelColor;
  final Color labelBg;
  final String subtitle;
  final IconData icon;

  const _BuyerOption({
    required this.type,
    required this.label,
    required this.labelColor,
    required this.labelBg,
    required this.subtitle,
    required this.icon,
  });
}
