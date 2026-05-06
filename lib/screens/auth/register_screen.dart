import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/localization_provider.dart';
import '../../utils/constants.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _farmNameCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _farmNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
      farmName: _farmNameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
    );
    if (success && mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
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

                        _buildLabel(loc.translate('auth.phone')),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: _inputDecoration(
                            hint: loc.translate('auth.phone_hint'),
                            icon: Icons.phone_outlined,
                          ),
                        ),
                        const SizedBox(height: 14),

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
                                          auth.error!,
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
