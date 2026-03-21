import 'package:firebase_auth/firebase_auth.dart';

import '../models/journal_entry.dart';
import '../services/journal_controller.dart';
import '../services/report_service.dart';

class ReportController {
  ReportController({JournalController? journalController, ReportService? reportService})
      : _journalController = journalController ?? JournalController(),
        _reportService = reportService ?? ReportService();

  final JournalController _journalController;
  final ReportService _reportService;

  Future<MentalHealthReport> getUserReport() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('REPORT: No authenticated user');
  return _reportService.generateReport(<JournalEntry>[]);
    }
    print('Current UID: ${user.uid}');
    print('REPORT: Fetching journals');
    final journals = await _journalController.fetchUserJournals();
    print('REPORT: Journals fetched count = ${journals.length}');
    print('REPORT: Generating report');
    final report = _reportService.generateReport(journals);
    print('REPORT: Report generated');
    return report;
  }

  Future<MentalHealthReport> getWeeklyReport() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('REPORT: No authenticated user');
  return _reportService.generateWeeklyReport(<JournalEntry>[]);
    }
    print('Current UID: ${user.uid}');
    final journals = await _journalController.fetchUserJournals();
    return _reportService.generateWeeklyReport(journals);
  }

  Future<MentalHealthReport> getMonthlyReport() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('REPORT: No authenticated user');
  return _reportService.generateMonthlyReport(<JournalEntry>[]);
    }
    print('Current UID: ${user.uid}');
    final journals = await _journalController.fetchUserJournals();
    return _reportService.generateMonthlyReport(journals);
  }
}
