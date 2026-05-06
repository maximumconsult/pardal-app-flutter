import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/localization_provider.dart';
import '../../utils/constants.dart';
import '../../utils/error_helper.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _farmNameCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _selectedCountry;
  String? _selectedCurrency;

  // Lista de países lusófonos e africanos
  static const List<Map<String, String>> _countries = [
    {'code': 'MZ', 'name': 'Moçambique'},
    {'code': 'BR', 'name': 'Brasil'},
    {'code': 'PT', 'name': 'Portugal'},
    {'code': 'AO', 'name': 'Angola'},
    {'code': 'CV', 'name': 'Cabo Verde'},
    {'code': 'GW', 'name': 'Guiné-Bissau'},
    {'code': 'ST', 'name': 'São Tomé e Príncipe'},
    {'code': 'TL', 'name': 'Timor-Leste'},
    {'code': 'ZA', 'name': 'África do Sul'},
    {'code': 'GH', 'name': 'Gana'},
    {'code': 'NG', 'name': 'Nigéria'},
    {'code': 'KE', 'name': 'Quénia'},
    {'code': 'TZ', 'name': 'Tanzânia'},
    {'code': 'ZW', 'name': 'Zimbabué'},
    {'code': 'MW', 'name': 'Malawi'},
    {'code': 'ZM', 'name': 'Zâmbia'},
    {'code': 'BW', 'name': 'Botsuana'},
    {'code': 'NA', 'name': 'Namíbia'},
    {'code': 'SZ', 'name': 'Eswatini'},
    {'code': 'LS', 'name': 'Lesoto'},
  ];

  // Lista de moedas disponíveis
  static const List<Map<String, String>> _currencies = [
    {'code': 'MZN', 'name': 'Metical (MZN)'},
    {'code': 'BRL', 'name': 'Real (BRL)'},
    {'code': 'EUR', 'name': 'Euro (EUR)'},
    {'code': 'USD', 'name': 'Dólar (USD)'},
    {'code': 'AOA', 'name': 'Kwanza (AOA)'},
    {'code': 'CVE', 'name': 'Escudo Cabo-verdiano (CVE)'},
    {'code': 'XOF', 'name': 'Franco CFA Ocidental (XOF)'},
    {'code': 'STN', 'name': 'Dobra (STN)'},
    {'code': 'ZAR', 'name': 'Rand (ZAR)'},
    {'code': 'GHS', 'name': 'Cedi (GHS)'},
    {'code': 'NGN', 'name': 'Naira (NGN)'},
    {'code': 'KES', 'name': 'Xelim Queniano (KES)'},
    {'code': 'TZS', 'name': 'Xelim Tanzaniano (TZS)'},
    {'code': 'ZWL', 'name': 'Dólar Zimbabuense (ZWL)'},
    {'code': 'MWK', 'name': 'Kwacha Malauiano (MWK)'},
    {'code': 'ZMW', 'name': 'Kwacha Zambiano (ZMW)'},
    {'code': 'BWP', 'name': 'Pula (BWP)'},
    {'code': 'NAD', 'name': 'Dólar Namibiano (NAD)'},
    {'code': 'SZL', 'name': 'Lilangeni (SZL)'},
    {'code': 'LSL', 'name': 'Loti (LSL)'},
    {'code': 'GBP', 'name': 'Libra Esterlina (GBP)'},
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _farmNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final loc = context.read<LocalizationProvider>();
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedCountry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.translate('auth.country_required')),
          backgroundColor: AppConstants.errorColor,
        ),
      );
      return;
    }
    if (_selectedCurrency == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.translate('auth.currency_required')),
          backgroundColor: AppConstants.errorColor,
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      farmName: _farmNameCtrl.text.trim(),
      country: _selectedCountry!,
      currency: _selectedCurrency!,
    );
    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else if (mounted && auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ErrorHelper.translateError(loc, auth.error!)),
          backgroundColor: AppConstants.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationProvider>();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1B4332),
              Color(0xFF2D6A4F),
              Color(0xFF40916C),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 24),
                Image.asset(
                  'assets/images/logo_icon.png',
                  width: 70,
                  height: 70,
                ),
                const SizedBox(height: 8),
                Text(
                  loc.translate('auth.create_account'),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  loc.translate('auth.register_subtitle'),
                  style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8)),
                ),
                const SizedBox(height: 20),

                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nome
                        _buildLabel(loc.translate('auth.name')),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _nameCtrl,
                          decoration: _inputDecoration(
                            hint: loc.translate('auth.name_hint'),
                            icon: Icons.person_outline,
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return loc.translate('auth.name_required');
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Email
                        _buildLabel(loc.translate('auth.email')),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _inputDecoration(
                            hint: loc.translate('auth.email_hint'),
                            icon: Icons.email_outlined,
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return loc.translate('auth.email_error');
                            if (!v.contains('@')) return loc.translate('auth.email_error');
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Nome da Quinta
                        _buildLabel(loc.translate('auth.farm_name')),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _farmNameCtrl,
                          decoration: _inputDecoration(
                            hint: loc.translate('auth.farm_name_hint'),
                            icon: Icons.agriculture_outlined,
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return loc.translate('auth.farm_name_required');
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // País
                        _buildLabel(loc.translate('auth.country')),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedCountry,
                              isExpanded: true,
                              hint: Text(loc.translate('auth.select_country'), style: TextStyle(color: Colors.grey[500])),
                              icon: const Icon(Icons.arrow_drop_down, color: AppConstants.primaryColor),
                              items: _countries.map((country) {
                                return DropdownMenuItem<String>(
                                  value: country['code'],
                                  child: Text(country['name']!),
                                );
                              }).toList(),
                              onChanged: (v) {
                                setState(() {
                                  _selectedCountry = v;
                                  // Auto-selecionar moeda baseada no país
                                  if (v == 'MZ') _selectedCurrency = 'MZN';
                                  else if (v == 'BR') _selectedCurrency = 'BRL';
                                  else if (v == 'PT') _selectedCurrency = 'EUR';
                                  else if (v == 'AO') _selectedCurrency = 'AOA';
                                  else if (v == 'CV') _selectedCurrency = 'CVE';
                                  else if (v == 'GW') _selectedCurrency = 'XOF';
                                  else if (v == 'ST') _selectedCurrency = 'STN';
                                  else if (v == 'ZA') _selectedCurrency = 'ZAR';
                                  else if (v == 'GH') _selectedCurrency = 'GHS';
                                  else if (v == 'NG') _selectedCurrency = 'NGN';
                                  else if (v == 'KE') _selectedCurrency = 'KES';
                                  else if (v == 'TZ') _selectedCurrency = 'TZS';
                                  else if (v == 'ZW') _selectedCurrency = 'ZWL';
                                  else if (v == 'MW') _selectedCurrency = 'MWK';
                                  else if (v == 'ZM') _selectedCurrency = 'ZMW';
                                  else if (v == 'BW') _selectedCurrency = 'BWP';
                                  else if (v == 'NA') _selectedCurrency = 'NAD';
                                  else if (v == 'SZ') _selectedCurrency = 'SZL';
                                  else if (v == 'LS') _selectedCurrency = 'LSL';
                                  else if (v == 'TL') _selectedCurrency = 'USD';
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Moeda
                        _buildLabel(loc.translate('auth.currency')),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedCurrency,
                              isExpanded: true,
                              hint: Text(loc.translate('auth.select_currency'), style: TextStyle(color: Colors.grey[500])),
                              icon: const Icon(Icons.arrow_drop_down, color: AppConstants.primaryColor),
                              items: _currencies.map((currency) {
                                return DropdownMenuItem<String>(
                                  value: currency['code'],
                                  child: Text(currency['name']!),
                                );
                              }).toList(),
                              onChanged: (v) => setState(() => _selectedCurrency = v),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Senha
                        _buildLabel(loc.translate('auth.password')),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _passwordCtrl,
                          obscureText: _obscurePassword,
                          decoration: _inputDecoration(
                            hint: loc.translate('auth.password_hint'),
                            icon: Icons.lock_outline,
                          ).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return loc.translate('auth.password_error');
                            if (v.length < 6) return loc.translate('auth.password_min_length');
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        // Confirmar Senha
                        _buildLabel(loc.translate('auth.confirm_password')),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _confirmPasswordCtrl,
                          obscureText: _obscureConfirm,
                          decoration: _inputDecoration(
                            hint: loc.translate('auth.confirm_password_hint'),
                            icon: Icons.lock_outline,
                          ).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return loc.translate('auth.confirm_password_error');
                            if (v != _passwordCtrl.text) return loc.translate('auth.passwords_dont_match');
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),

                        // Erro
                        Consumer<AuthProvider>(
                          builder: (_, auth, __) {
                            if (auth.error != null) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppConstants.errorColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.error_outline, color: AppConstants.errorColor, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          ErrorHelper.translateError(loc, auth.error!),
                                          style: const TextStyle(color: AppConstants.errorColor, fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        const SizedBox(height: 16),

                        // Botão Registar
                        Consumer<AuthProvider>(
                          builder: (_, auth, __) {
                            return SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: auth.isLoading ? null : _register,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1B4332),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 2,
                                ),
                                child: auth.isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : Text(
                                        loc.translate('auth.register'),
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),

                        // Link para login
                        Center(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: RichText(
                              text: TextSpan(
                                text: loc.translate('auth.already_have_account'),
                                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                                children: [
                                  TextSpan(
                                    text: ' ${loc.translate('common.login')}',
                                    style: const TextStyle(
                                      color: Color(0xFF1B4332),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14));
  }

  InputDecoration _inputDecoration({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppConstants.primaryColor),
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppConstants.primaryColor, width: 2)),
    );
  }
}
