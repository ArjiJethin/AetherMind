import '../models/journal_entry.dart';
import 'journal_parser.dart';

class InsightService {
  const InsightService();

  Map<String, int> getEmotionDistribution(List<JournalEntry> journals) {
    final distribution = <String, int>{};
    for (final journal in journals) {
      final emotion = _resolveEmotion(journal);
      if (emotion.isEmpty) {
        continue;
      }
      distribution.update(emotion, (value) => value + 1, ifAbsent: () => 1);
    }
    return distribution;
  }

  double getAverageSentiment(List<JournalEntry> journals) {
    if (journals.isEmpty) {
      return 0.0;
    }
    final total = journals.fold<double>(
      0.0,
      (sum, journal) => sum + journal.sentimentScore,
    );
    return total / journals.length;
  }

  String getDominantEmotion(List<JournalEntry> journals) {
    if (journals.isEmpty) {
      return 'neutral';
    }

    final distribution = getEmotionDistribution(journals);
    if (distribution.isEmpty) {
      return 'neutral';
    }

    var dominant = 'neutral';
    var maxCount = 0;
    distribution.forEach((emotion, count) {
      if (count > maxCount) {
        maxCount = count;
        dominant = emotion;
      }
    });
    return dominant;
  }

  String _resolveEmotion(JournalEntry journal) {
    final stored = journal.emotion.trim();
    if (stored.isNotEmpty && stored != 'neutral') {
      return stored;
    }
    if (journal.text.trim().isEmpty) {
      return stored.isEmpty ? 'neutral' : stored;
    }
    return JournalParser.getEmotion(journal.text);
  }

  Map<String, int> getTriggerFrequency(List<JournalEntry> journals) {
    final frequency = <String, int>{};
    for (final journal in journals) {
      for (final trigger in journal.triggers) {
        if (trigger.isEmpty) {
          continue;
        }
        frequency.update(trigger, (value) => value + 1, ifAbsent: () => 1);
      }
    }
    return frequency;
  }

  bool detectHighStress(List<JournalEntry> journals) {
    if (journals.isEmpty) {
      return false;
    }

    final avgSentiment = getAverageSentiment(journals);
    if (avgSentiment < -0.4) {
      return true;
    }

    final stressCount = journals.fold<int>(
      0,
      (sum, journal) => sum + journal.stressKeywords.length,
    );
    return stressCount > 3;
  }

  String generateSummary(List<JournalEntry> journals) {
    if (journals.isEmpty) {
      return 'No journal data available to summarize.';
    }

    final dominantEmotion = getDominantEmotion(journals);
    final triggerFrequency = getTriggerFrequency(journals);
    final mostCommonTrigger = _getMostCommonKey(triggerFrequency);
    final avgSentiment = getAverageSentiment(journals);
    final sentimentLabel = _sentimentLabel(avgSentiment);

  final triggerText = mostCommonTrigger == 'unknown'
    ? 'general stress'
    : '$mostCommonTrigger stress';

    return 'User shows dominant $dominantEmotion with frequent $triggerText. '
        'Overall sentiment is $sentimentLabel.';
  }

  String _getMostCommonKey(Map<String, int> frequency) {
    if (frequency.isEmpty) {
      return 'unknown';
    }

    var bestKey = 'unknown';
    var bestCount = 0;
    frequency.forEach((key, count) {
      if (count > bestCount) {
        bestCount = count;
        bestKey = key;
      }
    });
    return bestKey;
  }

  String _sentimentLabel(double score) {
    if (score > 0.2) {
      return 'positive';
    }
    if (score < -0.2) {
      return 'negative';
    }
    return 'neutral';
  }
}
