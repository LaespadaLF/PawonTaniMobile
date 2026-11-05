/// Format representasi respons API standar yang konsisten
/// selaras dengan format JSON ApiResponse dari backend Laravel.
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final Map<String, dynamic>? errors;
  final Map<String, dynamic>? meta;
  final int? statusCode;

  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
    this.meta,
    this.statusCode,
  });

  /// Factory untuk mem-parsing body respons JSON dari backend Laravel:
  /// `{ "success": bool, "message": string, "data": ..., "errors": ... }`
  factory ApiResponse.fromJson(
    Map<String, dynamic> json, {
    T Function(dynamic rawData)? fromJsonT,
    int? statusCode,
  }) {
    T? parsedData;
    if (json['data'] != null && fromJsonT != null) {
      try {
        parsedData = fromJsonT(json['data']);
      } catch (_) {
        parsedData = null;
      }
    } else if (json['data'] != null && json['data'] is T) {
      parsedData = json['data'] as T;
    }

    Map<String, dynamic>? parsedErrors;
    if (json['errors'] != null && json['errors'] is Map) {
      parsedErrors = Map<String, dynamic>.from(json['errors']);
    }

    Map<String, dynamic>? parsedMeta;
    if (json['meta'] != null && json['meta'] is Map) {
      parsedMeta = Map<String, dynamic>.from(json['meta']);
    }

    return ApiResponse<T>(
      success: json['success'] as bool? ?? (statusCode != null && statusCode >= 200 && statusCode < 300),
      message: json['message'] as String? ?? '',
      data: parsedData,
      errors: parsedErrors,
      meta: parsedMeta,
      statusCode: statusCode,
    );
  }

  /// Factory pembantu untuk respons sukses lokal.
  factory ApiResponse.success({
    required T data,
    String message = 'Berhasil memproses data',
    Map<String, dynamic>? meta,
    int? statusCode = 200,
  }) {
    return ApiResponse<T>(
      success: true,
      message: message,
      data: data,
      meta: meta,
      statusCode: statusCode,
    );
  }

  /// Factory pembantu untuk respons kegagalan / error lokal.
  factory ApiResponse.error({
    required String message,
    Map<String, dynamic>? errors,
    int? statusCode,
  }) {
    return ApiResponse<T>(
      success: false,
      message: message,
      errors: errors,
      statusCode: statusCode,
    );
  }

  /// Mendapatkan pesan error pertama jika validasi gagal.
  String? get firstErrorMessage {
    if (errors == null || errors!.isEmpty) return null;
    final firstEntry = errors!.values.first;
    if (firstEntry is List && firstEntry.isNotEmpty) {
      return firstEntry.first.toString();
    }
    return firstEntry.toString();
  }

  @override
  String toString() {
    return 'ApiResponse(success: $success, message: "$message", statusCode: $statusCode, hasData: ${data != null})';
  }
}
