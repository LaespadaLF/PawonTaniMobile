import 'package:flutter/material.dart';
import 'package:pawon_mobile/core/theme/warna_aplikasi.dart';
import 'package:pawon_mobile/core/utils/currency_input_formatter.dart';
import 'package:pawon_mobile/core/widgets/pawon_form_header.dart';
import 'package:pawon_mobile/features/penjualan/models/item_produk_saya.dart';
import 'package:pawon_mobile/features/penjualan/services/marketplace_penjualan_api_service.dart';

class RecordSaleScreen extends StatefulWidget {
  final ItemProdukSaya? sourceProduct;

  const RecordSaleScreen({super.key, this.sourceProduct});

  @override
  State<RecordSaleScreen> createState() => _RecordSaleScreenState();
}

class _RecordSaleScreenState extends State<RecordSaleScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _namaProdukController;
  late TextEditingController _volumeController;
  late TextEditingController _hargaSatuanController;
  late TextEditingController _namaPembeliController;
  late TextEditingController _teleponPembeliController;
  late TextEditingController _nominalDpController;
  late TextEditingController _catatanController;

  DateTime _saleDate = DateTime.now();
  String _tipePembayaran = 'lunas'; // 'lunas' | 'dp'
  String _metodePembayaran = 'transfer_bri';
  bool _isLoading = false;

  final _apiService = MarketplacePenjualanApiService();

  @override
  void initState() {
    super.initState();
    final p = widget.sourceProduct;
    _namaProdukController = TextEditingController(text: p?.namaProduk ?? '');
    _volumeController = TextEditingController(text: p != null ? '10' : '100');
    _hargaSatuanController = TextEditingController(
      text: p != null ? CurrencyInputFormatter.format(p.harga) : '15.000',
    );
    _namaPembeliController = TextEditingController(text: 'Pelanggan WhatsApp');
    _teleponPembeliController = TextEditingController();
    _nominalDpController = TextEditingController();
    _catatanController = TextEditingController();
  }

  @override
  void dispose() {
    _namaProdukController.dispose();
    _volumeController.dispose();
    _hargaSatuanController.dispose();
    _namaPembeliController.dispose();
    _teleponPembeliController.dispose();
    _nominalDpController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  double get _volume => double.tryParse(_volumeController.text.trim()) ?? 0;
  double get _hargaSatuan => CurrencyInputFormatter.parse(_hargaSatuanController.text);
  double get _totalHarga => _volume * _hargaSatuan;
  double get _nominalDp => CurrencyInputFormatter.parse(_nominalDpController.text);
  double get _sisaDp => _tipePembayaran == 'dp' ? (_totalHarga - _nominalDp) : 0;

  String _formatRupiah(num val) {
    final s = val.toInt().toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return 'Rp $buf';
  }

  Future<void> _submitPenjualan() async {
    if (!_formKey.currentState!.validate()) return;

    if (widget.sourceProduct != null) {
      if (_volume > widget.sourceProduct!.stokTersedia) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Jumlah penjualan melebihi stok tersedia (${widget.sourceProduct!.stokTersedia} ${widget.sourceProduct!.satuan})!'),
            backgroundColor: WarnaAplikasi.errorRedDark,
          ),
        );
        return;
      }
    }

    if (_tipePembayaran == 'dp') {
      if (_nominalDp <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nominal DP harus lebih dari Rp 0!'),
            backgroundColor: WarnaAplikasi.errorRedDark,
          ),
        );
        return;
      }
      if (_nominalDp >= _totalHarga) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nominal DP mencapai total harga. Silakan pilih status Bayar Lunas!'),
            backgroundColor: WarnaAplikasi.warningOrange,
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final payload = <String, dynamic>{
        if (widget.sourceProduct != null) 'id_produk': widget.sourceProduct!.idProduk,
        if (widget.sourceProduct?.idKomoditas != null) 'id_komoditas': widget.sourceProduct!.idKomoditas,
        'nama_produk': _namaProdukController.text.trim(),
        'nama_pembeli': _namaPembeliController.text.trim(),
        'no_telepon_pembeli': _teleponPembeliController.text.trim().isNotEmpty ? _teleponPembeliController.text.trim() : null,
        'jumlah': _volume,
        'satuan': widget.sourceProduct?.satuan ?? 'kg',
        'harga_satuan': _hargaSatuan,
        'nominal_dibayar': _tipePembayaran == 'lunas' ? _totalHarga : _nominalDp,
        'status_pembayaran': _tipePembayaran == 'lunas' ? 'lunas' : 'dp',
        'tanggal_transaksi': "${_saleDate.year.toString().padLeft(4, '0')}-${_saleDate.month.toString().padLeft(2, '0')}-${_saleDate.day.toString().padLeft(2, '0')}",
        'metode_pembayaran': _metodePembayaran,
        'catatan': _catatanController.text.trim().isNotEmpty ? _catatanController.text.trim() : null,
      };

      final res = await _apiService.catatPenjualan(payload);

      if (res.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_tipePembayaran == 'lunas'
                  ? 'Penjualan Lunas berhasil dicatat! Stok fisik telah diperbarui.'
                  : 'Penjualan DP berhasil dicatat! Stok ditahan untuk komitmen pesanan.'),
              backgroundColor: WarnaAplikasi.primary,
            ),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        throw Exception(res.message);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mencatat penjualan: $e'),
            backgroundColor: WarnaAplikasi.errorRedDark,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WarnaAplikasi.bgPage,
      body: SafeArea(
        child: Column(
          children: [
            PawonFormHeader(
              title: widget.sourceProduct != null ? 'Catat Penjualan Produk' : 'Catat Penjualan',
              subtitle: 'Pembukuan transaksi hasil panen dan pembaruan stok',
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if (widget.sourceProduct != null) _buildProductBanner(),
                      const SizedBox(height: 14),
                      _buildTransactionDetailsCard(),
                      const SizedBox(height: 14),
                      _buildPaymentSectionCard(),
                      const SizedBox(height: 14),
                      _buildBuyerDetailsCard(),
                      const SizedBox(height: 20),
                      _buildSubmitButton(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductBanner() {
    final p = widget.sourceProduct!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: WarnaAplikasi.greenLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: WarnaAplikasi.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: WarnaAplikasi.border),
            ),
            child: const Center(child: Text('🌾', style: TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.namaProduk,
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: WarnaAplikasi.primaryDark),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Stok Tersedia: ${p.stokTersedia} ${p.satuan} &bull; Harga Listing: ${p.hargaFormatted}',
                  style: const TextStyle(fontSize: 11, color: WarnaAplikasi.textMedium, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: WarnaAplikasi.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detail Komoditas & Volume',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: WarnaAplikasi.textDark),
          ),
          const SizedBox(height: 14),

          // Nama Produk / Snapshot
          const Text('Nama Produk / Komoditas *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: WarnaAplikasi.textDark)),
          const SizedBox(height: 6),
          TextFormField(
            controller: _namaProdukController,
            decoration: _inputDecoration(hint: 'Nama produk hasil panen'),
            validator: (v) => v == null || v.trim().isEmpty ? 'Nama produk wajib diisi' : null,
          ),
          const SizedBox(height: 14),

          // Volume & Harga
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Volume (${widget.sourceProduct?.satuan ?? 'Kg'}) *',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: WarnaAplikasi.textDark)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _volumeController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration(hint: '0'),
                      onChanged: (_) => setState(() {}),
                      validator: (v) {
                        final val = double.tryParse(v ?? '');
                        if (val == null || val <= 0) return 'Volume > 0';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Harga Aktual (Rp) *',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: WarnaAplikasi.textDark)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _hargaSatuanController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [CurrencyInputFormatter()],
                      decoration: _inputDecoration(hint: '0', prefixText: 'Rp '),
                      onChanged: (_) => setState(() {}),
                      validator: (v) {
                        final val = CurrencyInputFormatter.parse(v ?? '');
                        if (val <= 0) return 'Harga > 0';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Total Ringkasan Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: WarnaAplikasi.bgPaleGreen,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: WarnaAplikasi.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Nilai Transaksi:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: WarnaAplikasi.textDark),
                ),
                Text(
                  _formatRupiah(_totalHarga),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: WarnaAplikasi.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSectionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: WarnaAplikasi.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Skema Pembayaran',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: WarnaAplikasi.textDark),
          ),
          const SizedBox(height: 12),

          // Toggle Lunas vs DP
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _tipePembayaran = 'lunas'),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _tipePembayaran == 'lunas' ? WarnaAplikasi.statusLunasBg : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _tipePembayaran == 'lunas' ? WarnaAplikasi.statusLunasText : WarnaAplikasi.border,
                      ),
                    ),
                    child: Text(
                      'Bayar Lunas',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: _tipePembayaran == 'lunas' ? FontWeight.w700 : FontWeight.w500,
                        color: _tipePembayaran == 'lunas' ? WarnaAplikasi.statusLunasText : WarnaAplikasi.textGray,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _tipePembayaran = 'dp'),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _tipePembayaran == 'dp' ? WarnaAplikasi.statusUangMukaBg : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _tipePembayaran == 'dp' ? WarnaAplikasi.statusUangMukaText : WarnaAplikasi.border,
                      ),
                    ),
                    child: Text(
                      'Uang Muka (DP)',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: _tipePembayaran == 'dp' ? FontWeight.w700 : FontWeight.w500,
                        color: _tipePembayaran == 'dp' ? WarnaAplikasi.statusUangMukaText : WarnaAplikasi.textGray,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (_tipePembayaran == 'dp') ...[
            const Text('Nominal DP Diterima (Rp) *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: WarnaAplikasi.textDark)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _nominalDpController,
              keyboardType: TextInputType.number,
              inputFormatters: [CurrencyInputFormatter()],
              decoration: _inputDecoration(hint: 'Misal: 500.000', prefixText: 'Rp '),
              onChanged: (_) => setState(() {}),
              validator: (v) {
                if (_tipePembayaran == 'dp') {
                  final val = CurrencyInputFormatter.parse(v ?? '');
                  if (val <= 0) return 'DP harus > 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),

            // Sisa Pembayaran Tag
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: WarnaAplikasi.warningOrangeBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: WarnaAplikasi.warningOrange.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Sisa Tagihan Pelunasan:', style: TextStyle(fontSize: 12, color: WarnaAplikasi.warningOrange, fontWeight: FontWeight.w600)),
                  Text(_formatRupiah(_sisaDp > 0 ? _sisaDp : 0), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: WarnaAplikasi.warningOrange)),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Metode Pembayaran
          const Text('Metode Penerimaan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: WarnaAplikasi.textDark)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _metodePembayaran,
            decoration: _inputDecoration(hint: 'Metode'),
            items: const [
              DropdownMenuItem(value: 'transfer_bri', child: Text('Transfer Bank BRI')),
              DropdownMenuItem(value: 'transfer_bank_lain', child: Text('Transfer Bank Lain')),
              DropdownMenuItem(value: 'tunai', child: Text('Tunai Langsung')),
              DropdownMenuItem(value: 'kas_poktan', child: Text('Melalui Kas Poktan')),
            ],
            onChanged: (val) {
              if (val != null) setState(() => _metodePembayaran = val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBuyerDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: WarnaAplikasi.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi Pembeli & Catatan',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: WarnaAplikasi.textDark),
          ),
          const SizedBox(height: 14),

          const Text('Nama Pembeli / Mitra *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: WarnaAplikasi.textDark)),
          const SizedBox(height: 6),
          TextFormField(
            controller: _namaPembeliController,
            decoration: _inputDecoration(hint: 'Nama pembeli / pedagang / koperasi'),
            validator: (v) => v == null || v.trim().isEmpty ? 'Nama pembeli wajib diisi' : null,
          ),
          const SizedBox(height: 12),

          const Text('No. WhatsApp Pembeli (Opsional)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: WarnaAplikasi.textDark)),
          const SizedBox(height: 6),
          TextFormField(
            controller: _teleponPembeliController,
            keyboardType: TextInputType.phone,
            decoration: _inputDecoration(hint: '0812xxxxxxxx'),
          ),
          const SizedBox(height: 12),

          const Text('Catatan Transaksi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: WarnaAplikasi.textDark)),
          const SizedBox(height: 6),
          TextFormField(
            controller: _catatanController,
            maxLines: 2,
            decoration: _inputDecoration(hint: 'Contoh: Diambil hari Rabu, timbangan petak B...'),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitPenjualan,
        style: ElevatedButton.styleFrom(
          backgroundColor: WarnaAplikasi.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: WarnaAplikasi.primary.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              )
            : const Text(
                'Simpan Catatan Penjualan',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint, String? prefixText}) {
    return InputDecoration(
      hintText: hint,
      prefixText: prefixText,
      hintStyle: const TextStyle(fontSize: 13, color: WarnaAplikasi.textGrayLight),
      filled: true,
      fillColor: WarnaAplikasi.bgInput,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: WarnaAplikasi.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: WarnaAplikasi.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: WarnaAplikasi.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: WarnaAplikasi.errorRedDark),
      ),
    );
  }
}
