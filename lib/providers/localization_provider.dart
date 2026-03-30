import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/localization_service.dart';

class LocalizationProvider extends ChangeNotifier {
  final LocalizationService _localizationService = LocalizationService();
  late String _currentLanguage;

  String get currentLanguage => _currentLanguage;

  LocalizationProvider() {
    _currentLanguage = 'pt';
  }

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString('language') ?? 'pt';
    await _localizationService.loadTranslations(_currentLanguage);
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    if (languageCode == _currentLanguage) return;
    await _localizationService.loadTranslations(languageCode);
    _currentLanguage = languageCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', languageCode);
    notifyListeners();
  }

  String translate(String key) {
    return _localizationService.translate(key);
  }

  List<String> getSupportedLanguages() {
    return ['pt', 'en'];
  }

  String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'pt':
        return 'Português';
      case 'en':
        return 'English';
      default:
        return languageCode;
    }
  }
}
