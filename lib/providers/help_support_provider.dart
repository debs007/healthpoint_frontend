import 'package:flutter/foundation.dart';
import '../core/network/api_exception.dart';
import '../models/support_query.dart';
import '../services/help_support_service.dart';

class HelpSupportProvider extends ChangeNotifier {
  HelpSupportProvider(this._service);

  final HelpSupportService _service;

  List<SupportQuery> queries = [];
  bool isLoading = false;
  bool isSubmitting = false;
  String? errorMessage;

  Future<void> loadMyQueries() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      queries = await _service.getMyQueries();
    } on ApiException catch (e) {
      errorMessage = e.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitQuery({required String subject, required String message}) async {
    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      final query = await _service.submitQuery(subject: subject, message: message);
      queries = [query, ...queries];
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}
