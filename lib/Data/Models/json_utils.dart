/// Defensive JSON coercion helpers shared by every model.
///
/// **Why these exist:** the live Swagger spec declares **no response schema**
/// for almost every GET endpoint (see `api_gap_analysis.md` §2.2). Field types
/// therefore cannot be trusted — a number may arrive as a string, a date may be
/// null, a list may be missing. These helpers make every model tolerant of that
/// without sprinkling `try/catch` through the parsing code.
class JsonUtils {
  JsonUtils._();

  /// Reads a value as a `double`, defaulting to [fallback].
  static double toDouble(dynamic value, {double fallback = 0}) {
    if (value == null) return fallback;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? fallback;
  }

  /// Reads a value as an `int`, defaulting to [fallback].
  static int toInt(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? fallback;
  }

  /// Reads a value as a nullable `int`.
  static int? toIntOrNull(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  /// Reads a value as a nullable `double`.
  static double? toDoubleOrNull(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  /// Reads a value as a `bool`, accepting common string spellings.
  static bool toBool(dynamic value, {bool fallback = false}) {
    if (value == null) return fallback;
    if (value is bool) return value;
    final raw = value.toString().toLowerCase().trim();
    if (raw == 'true' || raw == '1' || raw == 'yes') return true;
    if (raw == 'false' || raw == '0' || raw == 'no') return false;
    return fallback;
  }

  /// Reads a value as a `String`, defaulting to [fallback].
  static String toStringValue(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    return value.toString();
  }

  /// Reads a value as a nullable `String`, treating blank as null.
  static String? toStringOrNull(dynamic value) {
    if (value == null) return null;
    final s = value.toString();
    return s.isEmpty ? null : s;
  }

  /// Parses an ISO-8601 date.
  ///
  /// **Timezone policy (User Manual):** every timestamp in the system is
  /// Bangladesh local time and there is **no** conversion anywhere. The parsed
  /// value is therefore treated as a wall-clock instant and never shifted into
  /// the device timezone.
  static DateTime? toDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    final raw = value.toString();
    if (raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  /// Maps a JSON list of objects into a typed list.
  static List<T> toList<T>(dynamic value, T Function(Map<String, dynamic>) fromJson) {
    if (value is! List) return <T>[];
    return value
        .whereType<Map>()
        .map((e) => fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Unwraps the common `{ "data": ... }` envelope the API uses.
  ///
  /// Some endpoints return the payload at the root and some wrap it. This
  /// helper tries `data` first and falls back to the root map.
  static Map<String, dynamic> unwrapMap(dynamic responseData) {
    if (responseData is Map) {
      final data = responseData['data'];
      if (data is Map) return Map<String, dynamic>.from(data);
      return Map<String, dynamic>.from(responseData);
    }
    return <String, dynamic>{};
  }

  /// Unwraps a list from either `{ "data": [...] }` or a bare list.
  static List<dynamic> unwrapList(dynamic responseData) {
    if (responseData is List) return responseData;
    if (responseData is Map) {
      final data = responseData['data'] ?? responseData['items'];
      if (data is List) return data;
    }
    return const [];
  }
}