import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pawon_mobile/core/storage/pawon_database_service.dart';
import 'package:pawon_mobile/features/aktivitas/services/aktivitas_api_service.dart';
import 'package:pawon_mobile/features/lahan/services/lahan_api_service.dart';
import 'package:pawon_mobile/features/panen/services/panen_api_service.dart';

class SyncSummary {
  final int total;
  final int successCount;
  final int failedCount;
  final List<String> errorMessages;

  const SyncSummary({
    required this.total,
    required this.successCount,
    required this.failedCount,
    this.errorMessages = const [],
  });

  bool get hasFailures => failedCount > 0;
  bool get isAllSuccess => total > 0 && failedCount == 0;
}

/// Service yang mengorkestrasi pengunggahan otomatis data offline ke server Laravel
class PawonSyncService {
  static final PawonSyncService instance = PawonSyncService._init();

  final ValueNotifier<bool> isSyncing = ValueNotifier<bool>(false);

  PawonSyncService._init();

  /// Menjalankan proses sinkronisasi seluruh antrean data offline ke backend
  Future<SyncSummary> syncAllPending() async {
    if (isSyncing.value) {
      return const SyncSummary(total: 0, successCount: 0, failedCount: 0);
    }

    isSyncing.value = true;
    final queue = await PawonDatabaseService.instance.getPendingSyncQueue();

    int success = 0;
    int failed = 0;
    final errors = <String>[];

    final panenService = PanenApiService();
    final lahanService = LahanApiService();
    final aktivitasService = AktivitasApiService();

    for (final item in queue) {
      final id = item['id'] as int;
      final tipe = item['tipe']?.toString() ?? '';
      final payloadJson = item['payload_json']?.toString() ?? '{}';
      final localFilesJson = item['local_files']?.toString();

      Map<String, dynamic> payload = {};
      try {
        payload = jsonDecode(payloadJson) as Map<String, dynamic>;
      } catch (_) {}

      List<String> localFiles = [];
      if (localFilesJson != null && localFilesJson.isNotEmpty) {
        try {
          final decoded = jsonDecode(localFilesJson);
          if (decoded is List) {
            localFiles = decoded.map((e) => e.toString()).toList();
          }
        } catch (_) {}
      }

      await PawonDatabaseService.instance.updateQueueStatus(id, 'syncing');

      try {
        bool opSuccess = false;
        String? opError;

        if (tipe == 'panen') {
          List<MultipartFile> files = [];
          for (final path in localFiles) {
            if (File(path).existsSync()) {
              files.add(await MultipartFile.fromFile(path));
            }
          }
          final res = await panenService.createPanen(
            payload,
            fotoPanenList: files.isNotEmpty ? files : null,
          );
          opSuccess = res.success;
          opError = res.message;
        } else if (tipe == 'lahan') {
          List<MultipartFile> files = [];
          for (final path in localFiles) {
            if (File(path).existsSync()) {
              files.add(await MultipartFile.fromFile(path));
            }
          }
          if (files.isNotEmpty) {
            final res = await lahanService.createLahanWithFoto(
              payload,
              null,
              fotoLahanList: files,
            );
            opSuccess = res.success;
            opError = res.message;
          } else {
            final res = await lahanService.createLahan(payload);
            opSuccess = res.success;
            opError = res.message;
          }
        } else if (tipe == 'aktivitas') {
          List<MultipartFile> files = [];
          for (final path in localFiles) {
            if (File(path).existsSync()) {
              files.add(await MultipartFile.fromFile(path));
            }
          }
          final res = await aktivitasService.createAktivitas(
            payload,
            fotoAktivitasList: files.isNotEmpty ? files : null,
          );
          opSuccess = res.success;
          opError = res.message;
        }

        if (opSuccess) {
          await PawonDatabaseService.instance.removeQueueItem(id);
          success++;
        } else {
          failed++;
          final errMsg = opError ?? 'Gagal menyinkronkan data $tipe';
          errors.add(errMsg);
          await PawonDatabaseService.instance.updateQueueStatus(id, 'failed', errorMessage: errMsg);
        }
      } catch (e) {
        failed++;
        errors.add(e.toString());
        await PawonDatabaseService.instance.updateQueueStatus(id, 'failed', errorMessage: e.toString());
      }
    }

    isSyncing.value = false;

    return SyncSummary(
      total: queue.length,
      successCount: success,
      failedCount: failed,
      errorMessages: errors,
    );
  }
}
