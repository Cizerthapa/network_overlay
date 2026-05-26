import 'package:flutter/material.dart';

import '../api_call_record.dart';
import '../api_inspector_controller.dart';
import 'api_call_detail_screen.dart';

/// Screen that displays a list of captured [ApiCallRecord]s.
///
/// Tapping a row opens [ApiCallDetailScreen]. The app-bar provides a "Clear"
/// action that resets the controller and pops this route.
class ApiCallsListScreen extends StatelessWidget {
  /// Creates an [ApiCallsListScreen].
  const ApiCallsListScreen({
    super.key,
    required this.controller,
    required this.records,
  });

  /// The controller used to reset capture state.
  final ApiInspectorController controller;

  /// The records to display.
  final List<ApiCallRecord> records;

  bool _isErrorStatus(int code) => code == 0 || code >= 400;

  Color _statusColor(int code) {
    if (code == 0 || code >= 500) return Colors.red;
    if (code >= 400 && code < 500) return Colors.orange;
    if (code >= 200 && code < 300) return Colors.green;
    return Colors.blueGrey;
  }

  @override
  Widget build(BuildContext context) {
    final errorCount =
        records.where((r) => _isErrorStatus(r.statusCode)).length;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          errorCount > 0
              ? 'Inspector (${records.length} calls, $errorCount errors)'
              : 'Inspector (${records.length} calls)',
        ),
        backgroundColor: const Color(0xFF1E1E2E),
        foregroundColor: Colors.white,
        actions: [
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            icon: const Icon(Icons.delete, size: 18),
            label: const Text('Clear'),
            onPressed: () {
              controller.reset();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF4F4F8),
      body: records.isEmpty
          ? const Center(
              child: Text(
                'No API calls captured.\nTap the bubble and make requests.',
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              itemCount: records.length,
              itemBuilder: (context, index) {
                final r = records[index];
                final color = _statusColor(r.statusCode);
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: color.withValues(alpha: 0.4)),
                  ),
                  child: ListTile(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ApiCallDetailScreen(record: r),
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    leading: Container(
                      width: 44,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        r.method,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    title: Text(
                      Uri.parse(r.url).path,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      '${r.statusCode} · ${r.duration.inMilliseconds}ms',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isErrorStatus(r.statusCode))
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: Colors.red.withValues(alpha: 0.35),
                              ),
                            ),
                            child: Text(
                              'ERROR',
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.w700,
                                fontSize: 9,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        const Icon(Icons.chevron_right, size: 18),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
