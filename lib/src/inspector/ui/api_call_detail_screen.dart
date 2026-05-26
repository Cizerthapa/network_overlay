import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../api_call_record.dart';

/// Detail screen for a single [ApiCallRecord].
///
/// Displays chips for HTTP method, status code, and duration, plus expandable
/// sections for the URL, cURL command, request body, response body, and (if
/// present) the error message and stack trace. App-bar actions allow copying
/// the cURL command and stack trace to the clipboard.
class ApiCallDetailScreen extends StatelessWidget {
  /// Creates an [ApiCallDetailScreen] for [record].
  const ApiCallDetailScreen({super.key, required this.record});

  /// The captured API call to display.
  final ApiCallRecord record;

  bool _isErrorStatus(int code) => code == 0 || code >= 400;

  String _prettyJson(dynamic data) {
    try {
      if (data == null) return 'null';
      if (data is String) {
        try {
          return const JsonEncoder.withIndent('  ').convert(jsonDecode(data));
        } catch (_) {
          return data;
        }
      }
      return const JsonEncoder.withIndent('  ').convert(data);
    } catch (_) {
      return data.toString();
    }
  }

  Color _statusColor(int code) {
    if (code == 0 || code >= 500) return Colors.red;
    if (code >= 400 && code < 500) return Colors.orange;
    if (code >= 200 && code < 300) return Colors.green;
    return Colors.blueGrey;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(record.statusCode);
    final hasStackTrace =
        record.stackTrace != null && record.stackTrace!.trim().isNotEmpty;
    final hasErrorMessage =
        record.errorMessage != null && record.errorMessage!.trim().isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${record.method} ${Uri.parse(record.url).path}',
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: statusColor,
        foregroundColor: Colors.white,
        actions: [
          if (hasStackTrace)
            IconButton(
              icon: const Icon(Icons.bug_report_outlined),
              tooltip: 'Copy stack trace',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: record.stackTrace!));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Stack trace copied')),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.copy_all),
            tooltip: 'Copy cURL',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: record.curl));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('cURL copied')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                label: Text(record.method),
                backgroundColor: statusColor.withValues(alpha: 0.15),
                side: BorderSide(color: statusColor),
              ),
              Chip(
                label: Text('${record.statusCode}'),
                backgroundColor: statusColor.withValues(alpha: 0.15),
                side: BorderSide(color: statusColor),
              ),
              Chip(
                label: Text('${record.duration.inMilliseconds} ms'),
                backgroundColor: Colors.blue.withValues(alpha: 0.1),
              ),
              if (_isErrorStatus(record.statusCode))
                Chip(
                  label: const Text('ERROR'),
                  backgroundColor: Colors.red.withValues(alpha: 0.12),
                  side: BorderSide(color: Colors.red.withValues(alpha: 0.35)),
                  labelStyle: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _infoTile('URL', record.url),
          const SizedBox(height: 12),
          _expandable(context, 'cURL Command', Icons.terminal, record.curl),
          if (hasErrorMessage) ...[
            const SizedBox(height: 8),
            _expandable(
              context,
              'Error Message',
              Icons.error_outline,
              record.errorMessage!,
              initiallyExpanded: true,
            ),
          ],
          if (hasStackTrace) ...[
            const SizedBox(height: 8),
            _expandable(
              context,
              'Stack Trace',
              Icons.bug_report_outlined,
              record.stackTrace!,
            ),
          ],
          const SizedBox(height: 8),
          _expandable(context, 'Request Body', Icons.upload_outlined,
              _prettyJson(record.requestBody)),
          const SizedBox(height: 8),
          _expandable(
            context,
            'Response Body',
            Icons.download_outlined,
            _prettyJson(record.responseBody),
            initiallyExpanded: true,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade600,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        SelectableText(
          value,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 12,
            color: Colors.blueGrey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _expandable(
    BuildContext context,
    String title,
    IconData icon,
    String content, {
    bool initiallyExpanded = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        leading: Icon(icon, size: 20),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            color: Colors.grey.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.copy, size: 14),
                  label: const Text('Copy'),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: content));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied')),
                    );
                  },
                ),
                SizedBox(
                  width: double.infinity,
                  child: SelectableText(
                    content,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
