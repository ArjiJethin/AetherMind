import '../models/journal_entry.dart';
import 'insight_service.dart';

class MentalHealthReport {
  const MentalHealthReport({
    required this.totalEntries,
    required this.averageSentiment,
    required this.dominantEmotion,
    required this.emotionDistribution,
    required this.triggerFrequency,
    required this.highStressDetected,
    required this.summary,
  });

  final int totalEntries;
  final double averageSentiment;
  final String dominantEmotion;
  final Map<String, int> emotionDistribution;
  final Map<String, int> triggerFrequency;
  final bool highStressDetected;
  final String summary;
}

class ReportService {
  ReportService({InsightService? insightService})
      : _insightService = insightService ?? const InsightService();

  final InsightService _insightService;

  MentalHealthReport generateReport(List<JournalEntry> journals) {
    if (journals.isEmpty) {
      return const MentalHealthReport(
        totalEntries: 0,
        averageSentiment: 0.0,
        dominantEmotion: 'neutral',
        emotionDistribution: <String, int>{},
        triggerFrequency: <String, int>{},
        highStressDetected: false,
        summary: 'No data available for this period.',
      );
    }

    final totalEntries = journals.length;
    final averageSentiment = _insightService.getAverageSentiment(journals);
    final dominantEmotion = _insightService.getDominantEmotion(journals);
    final emotionDistribution =
        _insightService.getEmotionDistribution(journals);
    final triggerFrequency = _insightService.getTriggerFrequency(journals);
    final highStressDetected = _insightService.detectHighStress(journals);
    final summary = _buildSummary(
      dominantEmotion: dominantEmotion,
      averageSentiment: averageSentiment,
      highStressDetected: highStressDetected,
    );

    return MentalHealthReport(
      totalEntries: totalEntries,
      averageSentiment: averageSentiment,
      dominantEmotion: dominantEmotion,
      emotionDistribution: emotionDistribution,
      triggerFrequency: triggerFrequency,
      highStressDetected: highStressDetected,
      summary: summary,
    );
  }

  MentalHealthReport generateWeeklyReport(List<JournalEntry> journals) {
    final recent = _filterByDays(_sorted(journals), 7);
    return generateReport(recent);
  }

  MentalHealthReport generateMonthlyReport(List<JournalEntry> journals) {
    final recent = _filterByDays(_sorted(journals), 30);
    return generateReport(recent);
  }

  List<JournalEntry> _filterByDays(List<JournalEntry> journals, int days) {
    if (journals.isEmpty) {
      return <JournalEntry>[];
    }
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return journals
        .where((journal) => journal.timestamp.isAfter(cutoff))
        .toList();
  }

  List<JournalEntry> _sorted(List<JournalEntry> journals) {
    final sorted = List<JournalEntry>.from(journals);
    sorted.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sorted;
  }

  String _buildSummary({
    required String dominantEmotion,
    required double averageSentiment,
    required bool highStressDetected,
  }) {
    final sentences = <String>[];

    if (dominantEmotion != 'neutral') {
      sentences.add('Dominant emotion is $dominantEmotion.');
    }
    if (highStressDetected) {
      sentences.add('User shows signs of elevated stress.');
    }
    if (averageSentiment < -0.3) {
      sentences.add('Overall emotional trend is negative.');
    }

    if (sentences.isEmpty) {
      return 'Overall emotional state appears stable for this period.';
    }

    return sentences.join(' ');
  }
}
