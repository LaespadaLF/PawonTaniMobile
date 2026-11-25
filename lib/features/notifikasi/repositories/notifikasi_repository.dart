import 'package:flutter/foundation.dart';
import 'package:pawon_mobile/features/notifikasi/models/item_notifikasi.dart';
import 'package:pawon_mobile/features/notifikasi/services/notifikasi_api_service.dart';

/// Status pemuatan data notifikasi
enum NotifikasiLoadStatus {
  initial,
  loading,
  loaded,
  error,
}

/// Repository dan State Manager terpusat untuk fitur Notifikasi PawonTani Mobile.
/// Bertindak sebagai Single Source of Truth status unread count dan daftar notifikasi.
class NotifikasiRepository extends ChangeNotifier {
  static final NotifikasiRepository instance = NotifikasiRepository._internal();
  factory NotifikasiRepository({NotifikasiApiService? apiService}) {
    if (apiService != null) {
      instance._apiService = apiService;
    }
    return instance;
  }

  NotifikasiApiService _apiService;

  NotifikasiRepository._internal({NotifikasiApiService? apiService})
      : _apiService = apiService ?? NotifikasiApiService();

  // ==================== STATE ====================

  /// Unread count listenable untuk reaktivitas badge bell di mana saja
  final ValueNotifier<int> _unreadCount = ValueNotifier<int>(0);
  ValueListenable<int> get unreadCountListenable => _unreadCount;
  int get unreadCount => _unreadCount.value;

  /// Daftar notifikasi saat ini
  List<ItemNotifikasi> _items = [];
  List<ItemNotifikasi> get items => List.unmodifiable(_items);

  /// Status loading daftar
  NotifikasiLoadStatus _status = NotifikasiLoadStatus.initial;
  NotifikasiLoadStatus get status => _status;

  /// Pesan error terakhir
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Filter aktif ('semua' | 'belum_dibaca')
  String _activeFilter = 'semua';
  String get activeFilter => _activeFilter;

  /// Metadata Pagination
  NotifikasiPaginationMeta _paginationMeta = const NotifikasiPaginationMeta();
  NotifikasiPaginationMeta get paginationMeta => _paginationMeta;
  bool get hasMore => _paginationMeta.hasMore;

  /// Status pagination loading
  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  /// Status pull-to-refresh
  bool _isRefreshing = false;
  bool get isRefreshing => _isRefreshing;

  /// Mencegah multiple concurrent fetch count
  bool _isFetchingCount = false;

  // ==================== ACTIONS ====================

  /// Mengambil jumlah unread count aktual dari server.
  /// Aman dipanggil dari mana saja (Home, Navbar, Lifecycle resume).
  Future<void> fetchUnreadCount() async {
    if (_isFetchingCount) return;
    _isFetchingCount = true;

    try {
      final res = await _apiService.getUnreadCount();
      if (res.success && res.data != null) {
        _unreadCount.value = res.data!;
      }
    } catch (_) {
      // Abaikan kegagalan diam-diam agar tidak mengganggu antarmuka utama
    } finally {
      _isFetchingCount = false;
    }
  }

  /// Memuat daftar notifikasi halaman pertama.
  /// Parameter [filter] opsional; jika diberikan, mengganti filter aktif.
  Future<void> loadInitial({String? filter}) async {
    if (filter != null) {
      _activeFilter = filter;
    }

    _status = NotifikasiLoadStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiService.getNotifikasiList(
        filter: _activeFilter,
        page: 1,
      );

      if (res.success && res.data != null) {
        _items = res.data!;
        _paginationMeta = NotifikasiPaginationMeta.fromJson(res.meta);
        _status = NotifikasiLoadStatus.loaded;

        // Sekaligus sinkronkan unread count
        fetchUnreadCount();
      } else {
        _errorMessage = res.message.isNotEmpty ? res.message : 'Gagal memuat notifikasi';
        _status = NotifikasiLoadStatus.error;
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan jaringan: $e';
      _status = NotifikasiLoadStatus.error;
    }

    notifyListeners();
  }

  /// Memuat halaman berikutnya (Infinite Scroll / Pagination).
  Future<void> loadNextPage() async {
    if (_isLoadingMore || !hasMore || _status == NotifikasiLoadStatus.loading) {
      return;
    }

    _isLoadingMore = true;
    notifyListeners();

    final nextPage = _paginationMeta.currentPage + 1;

    try {
      final res = await _apiService.getNotifikasiList(
        filter: _activeFilter,
        page: nextPage,
      );

      if (res.success && res.data != null) {
        // Gabungkan dan hindari duplikat ID
        final existingIds = _items.map((e) => e.id).toSet();
        final newItems = res.data!.where((item) => !existingIds.contains(item.id)).toList();

        _items = [..._items, ...newItems];
        _paginationMeta = NotifikasiPaginationMeta.fromJson(res.meta);
      }
    } catch (_) {
      // Pertahankan item yang sudah ada jika next page gagal
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Menyegarkan daftar notifikasi tanpa mengosongkan list existing (Pull-to-refresh).
  Future<void> refresh() async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    notifyListeners();

    try {
      final res = await _apiService.getNotifikasiList(
        filter: _activeFilter,
        page: 1,
      );

      if (res.success && res.data != null) {
        _items = res.data!;
        _paginationMeta = NotifikasiPaginationMeta.fromJson(res.meta);
        _status = NotifikasiLoadStatus.loaded;
        _errorMessage = null;

        fetchUnreadCount();
      }
    } catch (_) {
      // Pertahankan data yang ada saat refresh gagal
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  /// Mengganti filter ('semua' | 'belum_dibaca') dan memuat ulang list.
  Future<void> switchFilter(String newFilter) async {
    if (_activeFilter == newFilter && _status == NotifikasiLoadStatus.loaded) {
      return;
    }
    _activeFilter = newFilter;
    await loadInitial();
  }

  /// Menandai satu notifikasi sebagai sudah dibaca (Optimistic Update dengan Rollback).
  Future<bool> markAsRead(ItemNotifikasi item) async {
    if (item.sudahDibaca) return true;

    final index = _items.indexWhere((e) => e.id == item.id);
    final previousItem = index != -1 ? _items[index] : null;
    final previousUnread = _unreadCount.value;

    // 1. Optimistic Update
    if (previousItem != null) {
      final updatedItem = previousItem.copyWith(
        sudahDibaca: true,
        dibacaPada: DateTime.now(),
      );

      if (_activeFilter == 'belum_dibaca') {
        _items.removeAt(index);
      } else {
        _items[index] = updatedItem;
      }
    }

    if (_unreadCount.value > 0) {
      _unreadCount.value = _unreadCount.value - 1;
    }
    notifyListeners();

    // 2. Kirim ke API
    try {
      final res = await _apiService.markAsRead(item.id);
      if (!res.success) {
        // Rollback jika server menolak
        if (previousItem != null) {
          _rollbackItem(index, previousItem, previousUnread);
        } else {
          _unreadCount.value = previousUnread;
          notifyListeners();
        }
        return false;
      }
      return true;
    } catch (_) {
      // Rollback jika terjadi gangguan jaringan
      if (previousItem != null) {
        _rollbackItem(index, previousItem, previousUnread);
      } else {
        _unreadCount.value = previousUnread;
        notifyListeners();
      }
      return false;
    }
  }

  void _rollbackItem(int index, ItemNotifikasi item, int unreadCountVal) {
    if (_activeFilter == 'belum_dibaca') {
      if (index <= _items.length) {
        _items.insert(index, item);
      } else {
        _items.add(item);
      }
    } else if (index < _items.length) {
      _items[index] = item;
    }
    _unreadCount.value = unreadCountVal;
    notifyListeners();
  }

  /// Menandai semua notifikasi belum dibaca sebagai sudah dibaca.
  Future<bool> markAllAsRead() async {
    if (_unreadCount.value == 0) return true;

    final previousItems = List<ItemNotifikasi>.from(_items);
    final previousUnread = _unreadCount.value;

    // 1. Optimistic Update
    if (_activeFilter == 'belum_dibaca') {
      _items.clear();
    } else {
      _items = _items.map((e) => e.copyWith(sudahDibaca: true, dibacaPada: DateTime.now())).toList();
    }
    _unreadCount.value = 0;
    notifyListeners();

    // 2. Kirim ke API
    try {
      final res = await _apiService.markAllAsRead();
      if (!res.success) {
        // Rollback
        _items = previousItems;
        _unreadCount.value = previousUnread;
        notifyListeners();
        return false;
      }
      return true;
    } catch (_) {
      // Rollback
      _items = previousItems;
      _unreadCount.value = previousUnread;
      notifyListeners();
      return false;
    }
  }

  /// Helper untuk pengujian unit terisolasi.
  @visibleForTesting
  void resetForTesting({
    List<ItemNotifikasi>? items,
    int unreadCount = 0,
    NotifikasiLoadStatus status = NotifikasiLoadStatus.initial,
    String? errorMessage,
  }) {
    _items = items ?? [];
    _unreadCount.value = unreadCount;
    _status = status;
    _errorMessage = errorMessage;
    _activeFilter = 'semua';
    _paginationMeta = const NotifikasiPaginationMeta();
    _isLoadingMore = false;
    _isRefreshing = false;
  }
}
