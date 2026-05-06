import '../providers/localization_provider.dart';

/// Helper para traduzir mensagens de erro da API
class ErrorHelper {
  /// Mapeamento de mensagens comuns do servidor (em português) para chaves de tradução
  static const Map<String, String> _serverMessageMap = {
    'não é possível adicionar custo a um lote que não está activo': 'errors.batch_not_active_cost',
    'nao e possivel adicionar custo a um lote que nao esta activo': 'errors.batch_not_active_cost',
    'não é possível adicionar mortalidade a um lote que não está activo': 'errors.batch_not_active_mortality',
    'lote não encontrado': 'errors.batch_not_found',
    'credenciais inválidas': 'errors.invalid_credentials',
    'email já está em uso': 'errors.email_in_use',
    'o email já está em uso': 'errors.email_in_use',
    'utilizador não encontrado': 'errors.user_not_found',
    'não autorizado': 'errors.unauthorized',
    'acesso negado': 'errors.access_denied',
    'campo obrigatório': 'errors.field_required',
    'valor inválido': 'errors.invalid_value',
    'operação não permitida': 'errors.operation_not_allowed',
    'lote já concluído': 'errors.batch_already_completed',
    'limite de lotes atingido': 'errors.batch_limit_reached',
    'limite de colaboradores atingido': 'errors.worker_limit_reached',
  };

  /// Traduz uma mensagem de erro da API usando o sistema de i18n.
  /// Se a mensagem é uma chave conhecida (ex: 'no_internet'), traduz.
  /// Se é uma mensagem do servidor em português, mapeia para a chave correcta.
  /// Se não, retorna a mensagem original.
  static String translateError(LocalizationProvider loc, String? errorMessage) {
    if (errorMessage == null || errorMessage.isEmpty) {
      return loc.translate('common.error');
    }

    // Lista de chaves de erro conhecidas da API (retornadas pelo api_service.dart)
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

    // Se é uma chave conhecida, traduz directamente
    if (knownErrorKeys.contains(errorMessage)) {
      return loc.translate('errors.$errorMessage');
    }

    // Se começa com "Exception:" remove o prefixo
    String cleaned = errorMessage;
    if (cleaned.startsWith('Exception:')) {
      cleaned = cleaned.replaceFirst('Exception:', '').trim();
      if (knownErrorKeys.contains(cleaned)) {
        return loc.translate('errors.$cleaned');
      }
    }

    // Verificar se é uma mensagem do servidor conhecida (case-insensitive)
    final lowerCleaned = cleaned.toLowerCase().trim();
    for (final entry in _serverMessageMap.entries) {
      if (lowerCleaned.contains(entry.key.toLowerCase())) {
        return loc.translate(entry.value);
      }
    }

    // Retorna a mensagem original (pode ser mensagem do servidor em linguagem natural)
    return cleaned;
  }
}
