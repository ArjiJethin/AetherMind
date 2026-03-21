import 'package:flutter/material.dart';

import '../services/report_service.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key, required this.report});

  final MentalHealthReport report;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mental Health Report'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildOverviewCard(context),
            const SizedBox(height: 16),
            _buildListCard(
              title: 'Emotion Distribution',
              data: report.emotionDistribution,
              emptyMessage: 'No emotion data available.',
            ),
            const SizedBox(height: 16),
            _buildListCard(
              title: 'Trigger Frequency',
              data: report.triggerFrequency,
              emptyMessage: 'No trigger data available.',
            ),
            const SizedBox(height: 16),
            _buildStressCard(context),
            const SizedBox(height: 16),
            _buildSummaryCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overview',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _buildMetricRow('Total Entries', report.totalEntries.toString()),
            _buildMetricRow(
              'Average Sentiment',
              report.averageSentiment.toStringAsFixed(2),
            ),
            _buildMetricRow('Dominant Emotion', report.dominantEmotion),
          ],
        ),
      ),
    );
  }

  Widget _buildListCard({
    required String title,
    required Map<String, int> data,
    required String emptyMessage,
  }) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            if (data.isEmpty)
              Text(emptyMessage)
            else
              ...data.entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(child: Text(_titleCase(entry.key))),
                      Text(entry.value.toString()),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStressCard(BuildContext context) {
    final color = report.highStressDetected ? Colors.red : Colors.green;
    final message = report.highStressDetected
        ? 'High stress detected'
        : 'No significant stress detected';

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.info, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: color, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Summary',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Text(
              report.summary.isEmpty
                  ? 'No data available for this period.'
                  : report.summary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  String _titleCase(String value) {
    if (value.isEmpty) {
      return value;
    }
    return value[0].toUpperCase() + value.substring(1);
  }
}
