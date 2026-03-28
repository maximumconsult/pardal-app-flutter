# Pardal Flutter App - v1.1.0 com Internacionalização (i18n)

## 🌍 Suporte Multilingue

Este app suporta **Português (PT)** e **Inglês (EN)** com mudança de idioma instantânea e persistência.

### ✨ Funcionalidades de i18n

- ✅ 150+ strings traduzidas
- ✅ Mudança de idioma instantânea
- ✅ Persistência de preferência de idioma
- ✅ Seletor de idioma na LoginScreen
- ✅ Todas as screens traduzidas

---

## 🚀 Setup Rápido

### Pré-requisitos
- Flutter 3.6.2 ou superior
- Dart 3.0 ou superior
- Android SDK 21+ (para Android)
- Xcode 12+ (para iOS)

### Instalação

```bash
# 1. Clonar repositório
git clone <seu-repositorio>
cd pardal_app

# 2. Obter dependências
flutter pub get

# 3. Executar app em desenvolvimento
flutter run

# 4. Executar testes
flutter test
```

---

## 🏗️ Build

### Build APK (Android)

```bash
# Build de desenvolvimento
flutter build apk

# Build de release
flutter build apk --release
```

**Output**: `build/app/outputs/flutter-app.apk`

### Build AAB (Google Play)

```bash
flutter build appbundle --release
```

**Output**: `build/app/outputs/bundle/release/app-release.aab`

### Build iOS

```bash
flutter build ios --release
```

---

## 🌐 Como Usar i18n

### 1. Acessar Traduções na UI

```dart
import 'package:provider/provider.dart';
import 'providers/localization_provider.dart';

// Opção 1: Watch (recomendado para UI)
final localization = context.watch<LocalizationProvider>();
Text(localization.translate('dashboard.active_batches'))

// Opção 2: Read (para lógica)
final localization = context.read<LocalizationProvider>();
String message = localization.translate('common.success');
```

### 2. Mudar Idioma

```dart
final localization = context.read<LocalizationProvider>();
await localization.setLanguage('en'); // Inglês
await localization.setLanguage('pt'); // Português
```

### 3. Adicionar Novas Traduções

1. Adicionar chave a `assets/i18n/en.json`:
```json
{
  "minha_secao": {
    "minha_chave": "My Translation"
  }
}
```

2. Adicionar chave a `assets/i18n/pt.json`:
```json
{
  "minha_secao": {
    "minha_chave": "Minha Tradução"
  }
}
```

3. Usar no código:
```dart
Text(localization.translate('minha_secao.minha_chave'))
```

---

## 📱 Screens Traduzidas

| Screen | Funcionalidades |
|--------|-----------------|
| LoginScreen | Seletor de idioma, todas as labels |
| HomeScreen | Navegação, menu inferior |
| DashboardScreen | KPIs, resumo financeiro, lotes activos |
| BatchesScreen | Lista de lotes, filtros, status |
| IncidentsScreen | Lista de incidentes, urgência, status |
| ProfileScreen | Dados do utilizador, segurança, logout |

---

## 🔧 Estrutura de Ficheiros

```
lib/
├── main.dart                          # Entry point com LocalizationProvider
├── screens/
│   ├── auth/
│   │   └── login_screen.dart         # Seletor de idioma
│   ├── home_screen.dart
│   ├── dashboard/
│   │   └── dashboard_screen.dart
│   ├── batches/
│   │   └── batches_screen.dart
│   ├── incidents/
│   │   └── incidents_screen.dart
│   └── profile/
│       └── profile_screen.dart
├── providers/
│   ├── auth_provider.dart
│   ├── data_provider.dart
│   └── localization_provider.dart    # ⭐ Provider de i18n
├── services/
│   └── localization_service.dart     # ⭐ Serviço de i18n
└── assets/
    └── i18n/
        ├── en.json                   # ⭐ Traduções em Inglês
        └── pt.json                   # ⭐ Traduções em Português
```

---

## 🔄 CI/CD com GitHub Actions

O projeto inclui workflow automático em `.github/workflows/build.yml` que:

1. **Build APK** automaticamente
2. **Build AAB** automaticamente
3. **Upload de artefatos** para download
4. **Cria releases** quando há tags

### Como usar:

```bash
# Fazer push para trigger o build
git push origin main

# Ou criar uma release
git tag v1.1.0
git push origin v1.1.0
```

---

## 📊 Informações de Versão

- **Versão**: 1.1.0+2
- **Flutter**: 3.6.2
- **Dart**: 3.0+
- **Idiomas**: 2 (PT, EN)
- **Strings**: 150+

---

## 🐛 Troubleshooting

### Problema: "Strings aparecem como '???'"
```bash
flutter clean
flutter pub get
flutter run
```

### Problema: "Idioma não persiste"
Verificar se `SharedPreferences` está instalado:
```bash
flutter pub add shared_preferences
```

### Problema: "Build falha"
```bash
flutter clean
flutter pub get
flutter pub upgrade
flutter build apk --release
```

---

## 📝 Notas de Lançamento v1.1.0

### Português
- ✅ Suporte completo para Português
- ✅ Mudança de idioma instantânea
- ✅ Todas as screens traduzidas
- ✅ Persistência de preferência de idioma

### English
- ✅ Full Portuguese support
- ✅ Instant language switching
- ✅ All screens translated
- ✅ Language preference persistence

---

## 📞 Suporte

Para dúvidas ou problemas:
1. Verificar documentação Flutter: https://flutter.dev
2. Verificar logs: `flutter logs`
3. Executar testes: `flutter test`

---

**Desenvolvido com ❤️ para Pardal**
