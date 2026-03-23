import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/journal_controller.dart';
import '../services/report_service.dart';
import 'report_screen.dart';

class JournalTestScreen extends StatefulWidget {
  const JournalTestScreen({super.key});

  @override
  State<JournalTestScreen> createState() => _JournalTestScreenState();
}

class _JournalTestScreenState extends State<JournalTestScreen> {
  final TextEditingController _controller = TextEditingController();
  final JournalController _journalController = JournalController();
  final ReportService _reportService = ReportService();
  bool _isLoading = false;
  DateTime? _typingStart;
  DateTime? _lastKeyTimestamp;
  int _totalKeystrokes = 0;
  int _backspaceCount = 0;
  final List<double> _pauseDurations = <double>[];

  void _onChanged(String value) {
    final now = DateTime.now();
    _typingStart ??= now;

    if (_lastKeyTimestamp != null) {
      final pauseSeconds = now.difference(_lastKeyTimestamp!).inMilliseconds / 1000;
      if (pauseSeconds > 0) {
        _pauseDurations.add(pauseSeconds);
      }
    }

    final previousLength = _controller.text.length;
    final currentLength = value.length;

    if (currentLength < previousLength) {
      _backspaceCount += (previousLength - currentLength);
    } else if (currentLength > previousLength) {
      _totalKeystrokes += (currentLength - previousLength);
    }

    _lastKeyTimestamp = now;
  }

  Map<String, dynamic> _buildKeystrokeData(String finalText) {
    final start = _typingStart;
    final end = _lastKeyTimestamp ?? DateTime.now();
    final totalTime = start == null
        ? 0.0
        : end.difference(start).inMilliseconds / 1000;

    final keystrokeCount = _totalKeystrokes <= 0 ? finalText.length : _totalKeystrokes;
    final typingSpeed = totalTime > 0 ? keystrokeCount / totalTime : 0.0;
    final avgPause =
        _pauseDurations.isEmpty ? 0.0 : _pauseDurations.reduce((a, b) => a + b) / _pauseDurations.length;
    final maxPause = _pauseDurations.isEmpty
        ? 0.0
        : _pauseDurations.reduce((a, b) => a > b ? a : b);

    return <String, dynamic>{
      'typing_speed': typingSpeed,
      'avg_pause': avgPause,
      'max_pause': maxPause,
      'backspace_count': _backspaceCount,
      'total_time': totalTime,
      'keystroke_count': keystrokeCount,
    };
  }

  void _resetKeystrokeTracking() {
    _typingStart = null;
    _lastKeyTimestamp = null;
    _totalKeystrokes = 0;
    _backspaceCount = 0;
    _pauseDurations.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    print('START: Button pressed');
  final text = _controller.text.trim();
  if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write something first.')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in first.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });
    try {
      final keystrokeData = _buildKeystrokeData(text);
      print('STEP 1: Calling createJournal');
    final entry = await _journalController
      .createJournal(text, keystrokeData: keystrokeData)
          .timeout(const Duration(seconds: 12));

      print('STEP 2: createJournal result = $entry');

      if (!mounted) {
        return;
      }

      if (entry == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save journal')),
        );
        return;
      }

      print('STEP 3: Generating single-entry report');
      final report = _reportService.generateSingleEntryReport(entry);

      print('STEP 4: Report fetched successfully');

      if (!mounted) {
        return;
      }

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ReportScreen(report: report),
        ),
      );
      _controller.clear();
  _resetKeystrokeTracking();
    } on TimeoutException {
      print('STEP ERROR: Request timed out');
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request timed out. Please try again.')),
      );
    } catch (error) {
      print('STEP ERROR: $error');
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Write Journal'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              onChanged: _onChanged,
              minLines: 4,
              maxLines: 8,
              decoration: const InputDecoration(
                hintText: 'Write your thoughts...',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleSubmit,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save & Generate Report'),
            ),
          ],
        ),
      ),
    );
  }
}
