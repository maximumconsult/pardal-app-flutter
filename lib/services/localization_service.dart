import 'dart:convert';
import 'package:flutter/services.dart';

class LocalizationService {
  static final LocalizationService _instance = LocalizationService._internal();

  factory LocalizationService() {
    return _instance;
  }

  LocalizationService._internal();

  late Map<String, dynamic> _translations;
  late String _currentLanguage;

  String get currentLanguage => _currentLanguage;

  // Carregar traduções para um idioma específico
  Future<void> loadTranslations(String languageCode) async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/i18n/$languageCode.json',
      );
      _translations = jsonDecode(jsonString);
      _currentLanguage = languageCode;
    } catch (e) {
      print('Erro ao carregar traduções para $languageCode: $e');
      // Fallback para português
      if (languageCode != 'pt') {
        await loadTranslations('pt');
      }
    }
  }

  // Obter tradução por chave (suporta chaves aninhadas como "auth.email")
  String translate(String key) {
    try {
      final keys = key.split('.');
      dynamic value = _translations;

      for (final k in keys) {
        if (value is Map) {
          value = value[k];
        } else {
          return key; // Retorna a chave se não encontrar
        }
      }

      return value?.toString() ?? key;
    } catch (e) {
      print('Erro ao traduzir chave "$key": $e');
      return key;
    }
  }

  // Obter tradução com parâmetros (ex: "Hello {name}")
  String translateWithParams(String key, Map<String, String> params) {
    String value = translate(key);
    params.forEach((paramKey, paramValue) {
      value = value.replaceAll('{$paramKey}', paramValue);
    });
    return value;
  }

  // Obter lista de idiomas suportados
  List<String> getSupportedLanguages() {
    return ['pt', 'en'];
  }

  // Obter nome do idioma
  String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'pt':
        return translate('settings.portuguese');
      case 'en':
        return translate('settings.english');
      default:
        return languageCode;
    }
  }
}
