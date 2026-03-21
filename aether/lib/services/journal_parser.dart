class JournalParser {
  static const List<String> _positiveWords = [
    'happy',
    'joy',
    'grateful',
    'calm',
    'hopeful',
    'good',
    'great',
    'positive',
    'relaxed',
    'peaceful',
    'excited',
    'love',
    'proud',
    'confident',
  ];

  static const List<String> _negativeWords = [
    'sad',
    'angry',
    'upset',
    'anxious',
    'stress',
    'stressed',
    'depressed',
    'hopeless',
    'tired',
    'exhausted',
    'overwhelmed',
    'burnout',
    'burned',
    'lonely',
    'fear',
    'bad',
    'terrible',
  ];

  static const Map<String, List<String>> _triggerKeywords = {
    'academic': ['exam', 'school', 'class', 'grades', 'homework', 'college'],
    'work': ['job', 'boss', 'deadline', 'meeting', 'office', 'work'],
    'social': ['friends', 'family', 'relationship', 'party', 'social'],
    'health': ['sick', 'ill', 'doctor', 'pain', 'health', 'sleep'],
  };

  static const Map<String, List<String>> _stressKeywords = {
    'overwhelmed': ['overwhelmed', 'too much', 'overloaded'],
    'burnout': ['burnout', 'burned out', 'burnt out'],
    'exhausted': ['exhausted', 'drained', 'fatigued'],
    'hopeless': ['hopeless', 'helpless', 'no way out'],
  };

  static const List<String> _overgeneralizationWords = ['always', 'never'];
  static const List<String> _catastrophizingWords = ['everything'];
  static const List<String> _negationWords = [
    'not',
    'no',
    'never',
    'hardly',
    'barely',
  ];

  static double getSentiment(String text) {
    final normalized = _normalize(text);
    if (normalized.isEmpty) {
      return 0.0;
    }

    const strongNegative = {
      'overwhelmed': -2,
      'hopeless': -2,
      'exhausted': -2,
    };
    const mildNegative = {
      'sad': -1,
      'bad': -1,
      'tired': -1,
    };
    const strongPositive = {
      'amazing': 2,
      'great': 2,
      'happy': 2,
    };
    const mildPositive = {
      'okay': 1,
      'fine': 1,
    };
    const phraseNegative = [
      'burnt out',
      'fed up',
      'worn out',
      'under pressure',
    ];

    final matches = <String, int>{};
    final tokens = _tokenize(normalized);
    for (final phrase in phraseNegative) {
      final phraseTokens = _tokenize(phrase);
      final starts = _findPhraseStarts(tokens, phraseTokens);
      if (starts.isEmpty) {
        continue;
      }
      final negated = starts.any((start) => _isNegatedWindow(start, tokens));
      if (!negated) {
        matches[phrase] = -2;
      }
    }
    for (var i = 0; i < tokens.length; i++) {
      final token = tokens[i];
      if (matches.containsKey(token)) {
        continue;
      }
      final weight = strongNegative[token] ??
          mildNegative[token] ??
          strongPositive[token] ??
          mildPositive[token];
      if (weight == null) {
        continue;
      }
      if (_isNegatedWindow(i, tokens)) {
        continue;
      }
      matches[token] = weight;
    }

    if (matches.isEmpty) {
      return 0.0;
    }

    final totalScore = matches.values.fold<int>(0, (sum, value) => sum + value);
    final score = totalScore / matches.length;
    return score.clamp(-1.0, 1.0);
  }

  static String getEmotion(String text) {
    final normalized = _normalize(text);
    if (normalized.isEmpty) {
      return 'neutral';
    }

    const emotionGroups = <String, List<String>>{
      'anxiety': ['stress', 'stressed', 'overwhelmed', 'nervous', 'anxious'],
      'sadness': ['sad', 'down', 'hopeless'],
      'joy': ['happy', 'great', 'good', 'relaxed'],
    };

    final tokens = _tokenize(normalized);
    var bestEmotion = 'neutral';
    var bestScore = 0;

    emotionGroups.forEach((emotion, keywords) {
      var count = 0;
      for (var i = 0; i < tokens.length; i++) {
        final token = tokens[i];
        if (!keywords.contains(token)) {
          continue;
        }
        if (_isNegatedWindow(i, tokens)) {
          continue;
        }
        count += 1;
      }
      if (count > bestScore) {
        bestScore = count;
        bestEmotion = emotion;
      }
    });

    return bestScore == 0 ? 'neutral' : bestEmotion;
  }

  static List<String> getTriggers(String text) {
    final normalized = _normalize(text);
    if (normalized.isEmpty) {
      return <String>['unknown'];
    }

    const academicKeywords = [
      'exam',
      'exams',
      'test',
      'assignment',
      'study',
      'deadline',
    ];
    const workKeywords = ['work', 'job', 'boss', 'office', 'meeting'];
    const socialKeywords = ['family', 'friends', 'relationship'];

    final triggers = <String>[];
    if (academicKeywords.any(normalized.contains)) {
      triggers.add('academic');
    }
    if (workKeywords.any(normalized.contains)) {
      triggers.add('work');
    }
    if (socialKeywords.any(normalized.contains)) {
      triggers.add('social');
    }

    return triggers.isEmpty ? <String>['unknown'] : triggers;
  }

  static List<String> getStressKeywords(String text) {
    final normalized = _normalize(text);
    if (normalized.isEmpty) {
      return <String>[];
    }

    final tokens = _tokenize(normalized);
    final results = <String>[];
    _stressKeywords.forEach((label, keywords) {
      var matched = false;
      for (final keyword in keywords) {
        final keywordTokens = _tokenize(keyword);
        final starts = _findPhraseStarts(tokens, keywordTokens);
        if (starts.isEmpty) {
          continue;
        }
        final negated = starts.any((start) => _isNegatedWindow(start, tokens));
        if (!negated) {
          matched = true;
          break;
        }
      }
      if (matched) {
        results.add(label);
      }
    });
    return results;
  }

  static List<String> extractKeywords(String text) {
    const stopwords = <String>{
      'the',
      'and',
      'is',
      'was',
      'very',
      'i',
      'am',
      'to',
      'of',
      'in',
      'it',
    };

    final tokens = _tokenize(text);
    return tokens
        .where((word) => word.length > 4)
        .where((word) => !stopwords.contains(word))
        .toSet()
        .toList();
  }

  static List<String> getCognitivePatterns(String text) {
    final tokens = _tokenize(text);
    final patterns = <String>[];

    if (_overgeneralizationWords.any(tokens.contains)) {
      patterns.add('overgeneralization');
    }
    if (_catastrophizingWords.any(tokens.contains)) {
      patterns.add('catastrophizing');
    }

    return patterns;
  }

  static int getIntensity(double sentiment) {
    if (sentiment == 0) {
      return 3;
    }

    final scaled = (sentiment.abs() * 10).round();
    return scaled.clamp(1, 10);
  }

  static String getSentimentLabel(double score) {
    if (score > 0.2) {
      return 'positive';
    }
    if (score < -0.2) {
      return 'negative';
    }
    return 'neutral';
  }

  static List<String> _tokenize(String text) {
    final normalized = _normalize(text);
    return normalized
        .split(RegExp(r'\s+'))
        .map((word) => word.trim())
        .where((word) => word.isNotEmpty)
        .toList();
  }

  static String _normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .trim();
  }

  static bool _isNegatedWindow(int index, List<String> tokens) {
    if (index <= 0) {
      return false;
    }
    final start = index - 3 < 0 ? 0 : index - 3;
    for (var i = start; i < index; i++) {
      if (_negationWords.contains(tokens[i])) {
        return true;
      }
    }
    return false;
  }

  static List<int> _findPhraseStarts(
    List<String> tokens,
    List<String> phraseTokens,
  ) {
    if (phraseTokens.isEmpty || tokens.length < phraseTokens.length) {
      return <int>[];
    }
    final starts = <int>[];
    for (var i = 0; i <= tokens.length - phraseTokens.length; i++) {
      var match = true;
      for (var j = 0; j < phraseTokens.length; j++) {
        if (tokens[i + j] != phraseTokens[j]) {
          match = false;
          break;
        }
      }
      if (match) {
        starts.add(i);
      }
    }
    return starts;
  }
}
