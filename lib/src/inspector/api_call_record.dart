/// Lightweight record of a single captured API call.
class ApiCallRecord {
  /// Creates an [ApiCallRecord].
  ApiCallRecord({
    required this.id,
    required this.method,
    required this.url,
    required this.curl,
    required this.statusCode,
    required this.timestamp,
    required this.duration,
    this.requestBody,
    this.responseBody,
    this.errorMessage,
    this.stackTrace,
  });

  /// Unique identifier for this record (microseconds since epoch as a string).
  final String id;

  /// HTTP method (e.g. `GET`, `POST`).
  final String method;

  /// Full request URI as a string.
  final String url;

  /// Reconstructed cURL command for this request.
  final String curl;

  /// HTTP response status code, or `0` when no response was received.
  final int statusCode;

  /// Wall-clock time when the request completed (or errored).
  final DateTime timestamp;

  /// Elapsed time from request dispatch to response/error.
  final Duration duration;

  /// Decoded request body, if any.
  final dynamic requestBody;

  /// Decoded response body, if any.
  final dynamic responseBody;

  /// Best-effort error message when the call failed (timeouts, socket errors,
  /// non-2xx, etc).
  final String? errorMessage;

  /// Best-effort captured stack trace (when available).
  final String? stackTrace;
}
