import '../services/journal_controller.dart';
import '../services/report_service.dart';

class ReportController {
  ReportController({JournalController? journalController, ReportService? reportService})
      : _journalController = journalController ?? JournalController(),
        _reportService = reportService ?? ReportService();

  final JournalController _journalController;
  final ReportService _reportService;

  Future<MentalHealthReport> getUserReport(String userId) async {
    print('REPORT: Fetching journals');
    final journals = await _journalController.fetchUserJournals(userId);
    print('REPORT: Journals fetched count = ${journals.length}');
    print('REPORT: Generating report');
    final report = _reportService.generateReport(journals);
    print('REPORT: Report generated');
    return report;
  }

  Future<MentalHealthReport> getWeeklyReport(String userId) async {
    final journals = await _journalController.fetchUserJournals(userId);
    return _reportService.generateWeeklyReport(journals);
  }

  Future<MentalHealthReport> getMonthlyReport(String userId) async {
    final journals = await _journalController.fetchUserJournals(userId);
    return _reportService.generateMonthlyReport(journals);
  }
}
