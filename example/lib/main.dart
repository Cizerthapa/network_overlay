import 'package:assistive_touch_overlay/api_inspector.dart';
import 'package:assistive_touch_overlay/assistive_touch_overlay.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatefulWidget {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  late final ApiInspectorService _inspectorService;
  late final ApiInspectorController _inspectorController;
  late final Dio _dio;

  @override
  void initState() {
    super.initState();
    _inspectorService = ApiInspectorService();
    _inspectorController = ApiInspectorController(
      service: _inspectorService,
      overlayVisible: true,
    );

    _dio = Dio()..interceptors.add(ApiInspectorInterceptor(_inspectorService));
  }

  @override
  void dispose() {
    _inspectorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _Home(dio: _dio, inspector: _inspectorController),
      builder: (context, child) {
        return Stack(
          children: [
            child ?? const SizedBox.shrink(),
            ApiInspectorOverlay(
              controller: _inspectorController,
              showRecordingBadge: true,
              badgeDiameter: 16,
            ),
          ],
        );
      },
    );
  }
}

class _Home extends StatefulWidget {
  const _Home({required this.dio, required this.inspector});

  final Dio dio;
  final ApiInspectorController inspector;

  @override
  State<_Home> createState() => _HomeState();
}

class _HomeState extends State<_Home> {
  bool _showOverlayDemoBubble = true;
  String _status = 'Ready';

  Future<void> _getOk() async {
    setState(() => _status = 'Requesting /todos/1 ...');
    try {
      final res = await widget.dio.get(
        'https://jsonplaceholder.typicode.com/todos/1',
      );
      setState(() => _status = 'OK (${res.statusCode})');
    } catch (e) {
      setState(() => _status = 'Error: $e');
    }
  }

  Future<void> _getError() async {
    setState(() => _status = 'Requesting /invalid ...');
    try {
      await widget.dio.get('https://jsonplaceholder.typicode.com/invalid');
      setState(() => _status = 'Unexpected success');
    } catch (e) {
      setState(() => _status = 'Expected error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('assistive_touch_overlay example'),
        actions: [
          IconButton(
            tooltip: 'Toggle Inspector Bubble',
            onPressed: widget.inspector.toggleOverlayVisible,
            icon: const Icon(Icons.bubble_chart_outlined),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Api Inspector',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              const Text(
                'Tap the floating inspector bubble to start/stop capture and '
                'open the call list when done.',
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  FilledButton(
                    onPressed: _getOk,
                    child: const Text('GET /todos/1'),
                  ),
                  FilledButton.tonal(
                    onPressed: _getError,
                    child: const Text('GET /invalid (error)'),
                  ),
                  OutlinedButton(
                    onPressed: widget.inspector.reset,
                    child: const Text('Reset capture'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Status: $_status'),
              const SizedBox(height: 28),
              Text(
                'AssistiveTouchOverlay',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Show demo bubble'),
                value: _showOverlayDemoBubble,
                onChanged: (v) => setState(() => _showOverlayDemoBubble = v),
              ),
              const Text(
                'This bubble is the reusable draggable + snap-to-edge '
                'primitive (unrelated to the API inspector).',
              ),
            ],
          ),
          if (_showOverlayDemoBubble)
            AssistiveTouchOverlay(
              isPulsing: true,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Overlay bubble tapped')),
                );
              },
              builder: (context, pulseAnimation) {
                return ScaleTransition(
                  scale: pulseAnimation,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Demo',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
