import '../providers/localization_provider.dart';

/// Helper para traduzir mensagens de erro da API
class ErrorHelper {
  /// Traduz uma mensagem de erro da API usando o sistema de i18n.
  /// Se a mensagem é uma chave conhecida (ex: 'no_internet'), traduz.
  /// Se não, retorna a mensagem original (pode ser do servidor).
  static String translateError(LocalizationProvider loc, String? errorMessage) {
    if (errorMessage == null || errorMessage.isEmpty) {
      return loc.translate('common.error');
    }

    // Lista de chaves de erro conhecidas da API
    const knownErrorKeys = [
      'no_internet',
      'server_unreachable',
      'communication_error',
      'not_found',
      'server_error',
      'session_expired',
      'unexpected_response',
      'invalid_response',
      'validation_error',
    ];

    // Se é uma chave conhecida, traduz
    if (knownErrorKeys.contains(errorMessage)) {
      return loc.translate('errors.$errorMessage');
    }

    // Se começa com "Exception:" remove o prefixo
    if (errorMessage.startsWith('Exception:')) {
      final cleaned = errorMessage.replaceFirst('Exception:', '').trim();
      if (knownErrorKeys.contains(cleaned)) {
        return loc.translate('errors.$cleaned');
      }
      return cleaned;
    }

    // Retorna a mensagem original (pode ser mensagem do servidor em linguagem natural)
    return errorMessage;
  }
}
