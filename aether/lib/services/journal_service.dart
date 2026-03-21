import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/journal_entry.dart';

class JournalService {
  JournalService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('journals');

  Future<void> saveJournal(JournalEntry entry) async {
    try {
      print('SERVICE: Writing to Firestore...');
      final data = entry.toMap();
      data['timestamp'] = FieldValue.serverTimestamp();
      await _collection.doc(entry.id).set(data);
      print('SERVICE: Write successful');
    } catch (error) {
      print('SERVICE ERROR: $error');
    }
  }

  Future<List<JournalEntry>> getUserJournals(String userId) async {
    try {
      // Note: Firestore may require a composite index for (user_id, timestamp).
      // If this query fails, the error message includes a link to create it.
      final snapshot = await _collection
          .where('user_id', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      return snapshot.docs
          .map((doc) => JournalEntry.fromMap(doc.data()))
          .toList();
    } catch (error) {
      print('JournalService.getUserJournals error: $error');
      return <JournalEntry>[];
    }
  }

  Future<List<JournalEntry>> getRecentJournals(String userId, int days) async {
    try {
      final cutoff = Timestamp.fromDate(
        DateTime.now().subtract(Duration(days: days)),
      );

      final snapshot = await _collection
          .where('user_id', isEqualTo: userId)
          .where('timestamp', isGreaterThanOrEqualTo: cutoff)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => JournalEntry.fromMap(doc.data()))
          .toList();
    } catch (error) {
      print('JournalService.getRecentJournals error: $error');
      return <JournalEntry>[];
    }
  }

  Future<void> deleteJournal(String id) async {
    try {
      await _collection.doc(id).delete();
    } catch (error) {
      print('JournalService.deleteJournal error: $error');
    }
  }
}
