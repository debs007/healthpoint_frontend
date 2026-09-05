import 'package:flutter/material.dart';
import '../core/network/api_exception.dart';
import '../models/health_article.dart';
import '../services/health_article_service.dart';

class HealthArticleProvider extends ChangeNotifier {
  HealthArticleProvider(this._service);

  final HealthArticleService _service;

  List<HealthArticle> articles = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadArticles() async {
    if (articles.isNotEmpty) return; // loaded once per session, same pattern as HomeBannerProvider
    isLoading = true;
    notifyListeners();

    try {
      articles = await _service.getArticles();
      errorMessage = null;
    } on ApiException catch (e) {
      errorMessage = e.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
