/// Utility pemformatan waktu relatif untuk PawonTani Mobile
/// Menerjemahkan objek DateTime ke dalam frasa waktu ramah pengguna:
/// - "Baru saja" (< 1 menit)
/// - "X menit lalu" (< 1 jam)
/// - "X jam lalu" (< 24 jam)
/// - "Kemarin" (1 hari)
/// - "X hari lalu" (< 30 hari)
/// - "DD MMM YYYY" (> 30 hari)
class WaktuRelatifUtil {
  WaktuRelatifUtil._();

  static String format(DateTime? dateTime) {
    if (dateTime == null) {
      return '-';
    }

    final localTime = dateTime.isUtc ? dateTime.toLocal() : dateTime;
    final now = DateTime.now();
    final difference = now.difference(localTime);

    // Tangani kemungkinan waktu di masa depan sedikit karena deviasi jam
    if (difference.isNegative || difference.inSeconds < 60) {
      return 'Baru saja';
    }

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit lalu';
    }

    if (difference.inHours < 24) {
      return '${difference.inHours} jam lalu';
    }

    if (difference.inDays == 1) {
      return 'Kemarin';
    }

    if (difference.inDays < 30) {
      return '${difference.inDays} hari lalu';
    }

    // Jika lebih dari 30 hari, tampilkan tanggal baku Indonesia
    const namaBulan = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    final tgl = localTime.day;
    final bln = namaBulan[localTime.month];
    final thn = localTime.year;
    return '$tgl $bln $thn';
  }
}
