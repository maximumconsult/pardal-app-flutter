import 'package:flutter/material.dart';

class AppConstants {
  // API - alterar para o URL do servidor de produção
  static const String apiBaseUrl = 'https://app.pardal.app/api/v1';

  // Cores do Pardal (verde escuro)
  static const Color primaryColor = Color(0xFF1B4332);
  static const Color primaryLight = Color(0xFF2D6A4F);
  static const Color primaryDark = Color(0xFF0B2B1E);
  static const Color accentColor = Color(0xFF52B788);
  static const Color accentLight = Color(0xFF95D5B2);
  static const Color backgroundColor = Color(0xFFF5F7F5);
  static const Color cardColor = Colors.white;
  static const Color errorColor = Color(0xFFE63946);
  static const Color warningColor = Color(0xFFF4A261);
  static const Color successColor = Color(0xFF2D6A4F);

  // Emojis de espécies
  static String speciesEmoji(String icon) {
    switch (icon) {
      case 'chicken': return '🐔';
      case 'egg': return '🥚';
      case 'duck': return '🦆';
      case 'quail': return '🐦';
      case 'fish': return '🐟';
      case 'pig': return '🐷';
      case 'goat': return '🐐';
      case 'cow': return '🐄';
      case 'rabbit': return '🐇';
      case 'sheep': return '🐑';
      case 'turkey': return '🦃';
      case 'horse': return '🐴';
      case 'bee': return '🐝';
      default: return '🐾';
    }
  }

  // Emojis de categorias de custos
  static String categoryEmoji(String icon) {
    switch (icon) {
      case 'grain': return '🌾';
      case 'syringe': return '💉';
      case 'pill': return '💊';
      case 'bolt': return '⚡';
      case 'droplet': return '💧';
      case 'wrench': return '🔧';
      case 'truck': return '🚚';
      case 'users': return '👥';
      default: return '📦';
    }
  }

  static Color urgencyColor(String urgency) {
    switch (urgency) {
      case 'urgent': return errorColor;
      case 'important': return warningColor;
      case 'normal': return accentColor;
      default: return Colors.grey;
    }
  }
}
