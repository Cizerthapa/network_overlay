import 'dart:convert';

import 'package:dio/dio.dart';

/// Generates a cURL command string from the given Dio [RequestOptions].
String generateCurl(RequestOptions options) {
  final method = options.method.toUpperCase();
  final uri = options.uri.toString();

  final parts = <String>['curl', '-X', _shellQuote(method)];

  // Headers
  options.headers.forEach((key, value) {
    if (value == null) return;
    parts.addAll(['-H', _shellQuote('$key: $value')]);
  });

  // Body
  final data = options.data;
  final body = _stringifyBody(data);
  if (body != null && body.isNotEmpty) {
    parts.addAll(['--data', _shellQuote(body)]);
  }

  parts.add(_shellQuote(uri));
  return parts.join(' ');
}

String _shellQuote(String value) {
  // POSIX-ish single-quote escaping: ' -> '\''.
  return "'${value.replaceAll("'", r"'\''")}'";
}

String? _stringifyBody(dynamic data) {
  if (data == null) return null;
  if (data is String) return data;
  if (data is FormData) {
    // Best-effort; avoid trying to dump files.
    return jsonEncode(<String, dynamic>{
      'fields': {for (final f in data.fields) f.key: f.value},
      'files': data.files.map((e) => e.key).toList(),
    });
  }
  try {
    return jsonEncode(data);
  } catch (_) {
    return data.toString();
  }
}
