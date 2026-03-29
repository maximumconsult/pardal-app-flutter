import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/localization_service.dart';

class LocalizationProvider extends ChangeNotifier {
  final LocalizationService _localizationService = LocalizationService();
  late String _currentLanguage;

  String get currentLanguage => _currentLanguage;

  LocalizationProvider() {
    _currentLanguage = 'pt'; // Idioma padrão
  }

  // Inicializar o provider e carregar o idioma salvo
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString('language') ?? 'pt';
    await _localizationService.loadTranslations(_currentLanguage);
    notifyListeners();
  }

  // Mudar idioma
  Future<void> setLanguage(String languageCode) async {
    if (languageCode == _currentLanguage) return;

    await _localizationService.loadTranslations(languageCode);
    _currentLanguage = languageCode;

    // Guardar preferência
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', languageCode);

    notifyListeners();
  }

  // Obter tradução
  String translate(String key) {
    return _localizationService.translate(key);
  }

  // Obter tradução com parâmetros
  String translateWithParams(String key, Map<String, String> params) {
    return _localizationService.translateWithParams(key, params);
  }

  // Obter lista de idiomas suportados
  List<String> getSupportedLanguages() {
    return _localizationService.getSupportedLanguages();
  }

  // Obter nome do idioma
  String getLanguageName(String languageCode) {
    return _localizationService.getLanguageName(languageCode);
  }
}

// Extension para facilitar o uso
extension LocalizationExtension on BuildContext {
  String tr(String key) {
    return read<LocalizationProvider>().translate(key);
  }

  String trWithParams(String key, Map<String, String> params) {
    return read<LocalizationProvider>().translateWithParams(key, params);
  }

  LocalizationProvider get localization {
    return read<LocalizationProvider>();
  }
}
