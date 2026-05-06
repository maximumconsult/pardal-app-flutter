import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/localization_service.dart';

class LocalizationProvider extends ChangeNotifier {
  final LocalizationService _localizationService = LocalizationService();
  late String _currentLanguage;

  String get currentLanguage => _currentLanguage;
  String get currentLocale => _currentLanguage;

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

  /// Alias para setLanguage, usado no profile_screen
  Future<void> setLocale(String languageCode) async {
    return setLanguage(languageCode);
  }

  String translate(String key) {
    return _localizationService.translate(key);
  }

  /// Traduz uma chave com parâmetros dinâmicos
  /// Ex: translateWithParams('dashboard.urgent_count', {'count': '3'})
  String translateWithParams(String key, Map<String, String> params) {
    return _localizationService.translateWithParams(key, params);
  }

  /// Traduz o role do utilizador (admin, manager, worker)
  String translateRole(String role) {
    switch (role) {
      case 'admin':
        return translate('roles.admin');
      case 'manager':
        return translate('roles.manager');
      case 'worker':
        return translate('roles.worker');
      default:
        return role;
    }
  }

  /// Traduz status (active, completed, pending, etc.)
  String translateStatus(String status) {
    return _localizationService.translate('status.$status');
  }

  /// Traduz urgência (urgent, important, normal)
  String translateUrgency(String urgency) {
    return _localizationService.translate('urgency.$urgency');
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
