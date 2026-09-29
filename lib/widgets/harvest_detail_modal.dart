import 'package:flutter/material.dart';
import '../models/harvest_item.dart';
import 'custom_crop_icons.dart';

class HarvestDetailModal extends StatelessWidget {
  final HarvestItem item;
  final VoidCallback? onDelete;

  const HarvestDetailModal({
    super.key,
    required this.item,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CropIconWidget(cropType: item.cropType, size: 50),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF142419),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B8072),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: Color(0xFFE8EFEA)),
          const SizedBox(height: 16),
          _buildInfoRow('Status Verifikasi', _getStatusLabel(item.status), _getStatusColor(item.status)),
          _buildInfoRow('Lokasi & Lahan', '${item.location} (${item.blockArea})'),
          _buildInfoRow('Waktu Panen', '${item.date} • ${item.season}'),
          _buildInfoRow('Total Bobot', '${item.weightKg.toStringAsFixed(0)} Kg (${item.weightTon.toStringAsFixed(2)} Ton)'),
          _buildInfoRow('Kualitas & Mutu', '${item.qualityGrade} • ${item.moistureOrNotes}'),
          _buildInfoRow('Mitra Penyerapan', 'Bulog & Pupuk Indonesia'),
          const SizedBox(height: 24),
          Row(
            children: [
              if (onDelete != null)
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onDelete!();
                  },
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: 'Hapus',
                ),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Tutup Detail'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF285438),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF708577)),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: valueColor ?? const Color(0xFF162A1D),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusLabel(HarvestStatus status) {
    switch (status) {
      case HarvestStatus.menunggu:
        return 'Menunggu Verifikasi';
      case HarvestStatus.disetujui:
        return 'Disetujui Bulog';
      case HarvestStatus.ditolak:
        return 'Ditolak (Kadar air tinggi)';
    }
  }

  Color _getStatusColor(HarvestStatus status) {
    switch (status) {
      case HarvestStatus.menunggu:
        return const Color(0xFFD97706);
      case HarvestStatus.disetujui:
        return const Color(0xFF1E824C);
      case HarvestStatus.ditolak:
        return const Color(0xFFDC2626);
    }
  }
}
