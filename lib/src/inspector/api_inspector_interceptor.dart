import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_call_record.dart';
import 'api_inspector_service.dart';
import 'util/curl_generator.dart';

/// Dio interceptor that records requests/responses/errors into an
/// [ApiInspectorService].
///
/// Automatically acts as a transparent pass-through in release mode so it adds
/// zero overhead to production builds. Pair this with
/// [ApiInspectorOverlay] + [ApiInspectorController] to get a tap-driven
/// capture UI.
class ApiInspectorInterceptor extends Interceptor {
  /// Creates an [ApiInspectorInterceptor] backed by [inspector].
  ApiInspectorInterceptor(this._inspector);

  static const String _kStopwatchKey = '_inspectorStopwatch';
  static const String _kSessionIdKey = '_inspectorSessionId';
  static const String _kRecordedKey = '_inspectorRecorded';

  final ApiInspectorService _inspector;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kReleaseMode) {
      return super.onRequest(options, handler);
    }
    options.extra[_kStopwatchKey] = Stopwatch()..start();
    options.extra[_kSessionIdKey] = _inspector.activeSessionId;
    super.onRequest(options, handler);
  }

  @override
  void onResponse(
      Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (!kReleaseMode) {
      _recordResponse(response);
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (!kReleaseMode) {
      _recordError(err);
    }
    handler.next(err);
  }

  void _recordResponse(Response<dynamic> response) {
    final options = response.requestOptions;
    if (options.extra[_kRecordedKey] == true) return;

    final stopwatch = options.extra[_kStopwatchKey] as Stopwatch?;
    final int? sessionId = options.extra[_kSessionIdKey] as int?;
    if (stopwatch == null) return;
    stopwatch.stop();

    final now = DateTime.now();
    _inspector.record(
      ApiCallRecord(
        id: '${now.microsecondsSinceEpoch}',
        method: options.method,
        url: options.uri.toString(),
        curl: generateCurl(options),
        statusCode: response.statusCode ?? 0,
        timestamp: now,
        duration: stopwatch.elapsed,
        requestBody: options.data,
        responseBody: response.data,
      ),
      sessionId: sessionId,
    );

    options.extra[_kRecordedKey] = true;
  }

  void _recordError(DioException err) {
    final options = err.requestOptions;
    if (options.extra[_kRecordedKey] == true) return;

    final stopwatch = options.extra[_kStopwatchKey] as Stopwatch?;
    final int? sessionId = options.extra[_kSessionIdKey] as int?;
    if (stopwatch == null) return;
    stopwatch.stop();

    final now = DateTime.now();
    _inspector.record(
      ApiCallRecord(
        id: '${now.microsecondsSinceEpoch}',
        method: options.method,
        url: options.uri.toString(),
        curl: generateCurl(options),
        statusCode: err.response?.statusCode ?? 0,
        timestamp: now,
        duration: stopwatch.elapsed,
        requestBody: options.data,
        responseBody: err.response?.data ??
            (err.message != null
                ? <String, dynamic>{'message': err.message}
                : null),
        errorMessage: err.error?.toString() ?? err.message,
        stackTrace: err.stackTrace.toString(),
      ),
      sessionId: sessionId,
    );

    options.extra[_kRecordedKey] = true;
  }
}
