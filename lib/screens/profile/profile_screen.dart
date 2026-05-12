import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/localization_provider.dart';
import '../../utils/constants.dart';
import '../subscription/subscription_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _currentPassCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _editingProfile = false;
  bool _editingPassword = false;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _nameCtrl.text = auth.userName;
    _phoneCtrl.text = auth.user?['phone'] ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final loc = context.read<LocalizationProvider>();
    final auth = context.read<AuthProvider>();
    final success = await auth.updateProfile(_nameCtrl.text, _phoneCtrl.text);
    if (success && mounted) {
      setState(() => _editingProfile = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.translate('profile.profile_updated')), backgroundColor: AppConstants.successColor),
      );
    } else if (mounted && auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error!), backgroundColor: AppConstants.errorColor),
      );
    }
  }

  Future<void> _savePassword() async {
    final loc = context.read<LocalizationProvider>();
    if (_newPassCtrl.text != _confirmPassCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.translate('profile.passwords_mismatch')), backgroundColor: AppConstants.errorColor),
      );
      return;
    }
    if (_newPassCtrl.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.translate('profile.password_min_length')), backgroundColor: AppConstants.errorColor),
      );
      return;
    }
    final auth = context.read<AuthProvider>();
    final success = await auth.updatePassword(
      _currentPassCtrl.text,
      _newPassCtrl.text,
      _confirmPassCtrl.text,
    );
    if (success && mounted) {
      setState(() {
        _editingPassword = false;
        _currentPassCtrl.clear();
        _newPassCtrl.clear();
        _confirmPassCtrl.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.translate('profile.password_changed')), backgroundColor: AppConstants.successColor),
      );
    } else if (mounted && auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error!), backgroundColor: AppConstants.errorColor),
      );
    }
  }

  Future<void> _logout() async {
    final loc = context.read<LocalizationProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.translate('profile.logout')),
        content: Text(loc.translate('profile.logout_confirm')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(loc.translate('common.cancel'))),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(loc.translate('profile.logout'), style: const TextStyle(color: AppConstants.errorColor)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<AuthProvider>().logout();
      if (mounted) Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationProvider>();

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(loc.translate('profile.title')),
      ),
      body: Consumer<AuthProvider>(
        builder: (_, auth, __) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Avatar e info
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppConstants.primaryColor,
                      child: Text(
                        auth.userName.isNotEmpty ? auth.userName[0].toUpperCase() : '?',
                        style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(auth.userName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(auth.userEmail, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppConstants.accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        loc.translateRole(auth.userRole),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppConstants.primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Subscrição - apenas admin e gerente podem ver/gerir planos
              if (auth.userRole == 'admin' || auth.userRole == 'manager' || auth.userRole == 'super_admin') ...[                const SubscriptionCard(),
                const SizedBox(height: 16),
              ],

              // Editar dados pessoais
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person_outline, color: AppConstants.primaryColor),
                        const SizedBox(width: 8),
                        Expanded(child: Text(loc.translate('profile.personal_data'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                        TextButton(
                          onPressed: () => setState(() => _editingProfile = !_editingProfile),
                          child: Text(_editingProfile ? loc.translate('common.cancel') : loc.translate('common.edit')),
                        ),
                      ],
                    ),
                    if (_editingProfile) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: _nameCtrl,
                        decoration: _inputDecoration(loc.translate('profile.name')),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: _inputDecoration(loc.translate('profile.phone')),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: auth.isLoading ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: auth.isLoading
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : Text(loc.translate('common.save')),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Alterar senha
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lock_outline, color: AppConstants.primaryColor),
                        const SizedBox(width: 8),
                        Expanded(child: Text(loc.translate('profile.change_password'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                        TextButton(
                          onPressed: () => setState(() => _editingPassword = !_editingPassword),
                          child: Text(_editingPassword ? loc.translate('common.cancel') : loc.translate('profile.change')),
                        ),
                      ],
                    ),
                    if (_editingPassword) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: _currentPassCtrl,
                        obscureText: true,
                        decoration: _inputDecoration(loc.translate('profile.current_password')),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _newPassCtrl,
                        obscureText: true,
                        decoration: _inputDecoration(loc.translate('profile.new_password')),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _confirmPassCtrl,
                        obscureText: true,
                        decoration: _inputDecoration(loc.translate('profile.confirm_password')),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: auth.isLoading ? null : _savePassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: auth.isLoading
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : Text(loc.translate('profile.save_password')),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Idioma
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.language, color: AppConstants.primaryColor),
                        const SizedBox(width: 8),
                        Expanded(child: Text(loc.translate('profile.language'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => loc.setLocale('pt'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: loc.currentLocale == 'pt' ? AppConstants.primaryColor.withOpacity(0.1) : Colors.grey[100],
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: loc.currentLocale == 'pt' ? AppConstants.primaryColor : Colors.grey.shade300,
                                  width: loc.currentLocale == 'pt' ? 2 : 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Português',
                                  style: TextStyle(
                                    fontWeight: loc.currentLocale == 'pt' ? FontWeight.w700 : FontWeight.w500,
                                    color: loc.currentLocale == 'pt' ? AppConstants.primaryColor : Colors.grey[600],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => loc.setLocale('en'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: loc.currentLocale == 'en' ? AppConstants.primaryColor.withOpacity(0.1) : Colors.grey[100],
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: loc.currentLocale == 'en' ? AppConstants.primaryColor : Colors.grey.shade300,
                                  width: loc.currentLocale == 'en' ? 2 : 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'English',
                                  style: TextStyle(
                                    fontWeight: loc.currentLocale == 'en' ? FontWeight.w700 : FontWeight.w500,
                                    color: loc.currentLocale == 'en' ? AppConstants.primaryColor : Colors.grey[600],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Botão sair
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout, color: AppConstants.errorColor),
                  label: Text(loc.translate('profile.logout'), style: const TextStyle(color: AppConstants.errorColor, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppConstants.errorColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Versão
              Center(
                child: Text('Pardal v1.3.0', style: TextStyle(fontSize: 12, color: Colors.grey[400])),
              ),
            ],
          );
        },
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: AppConstants.backgroundColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppConstants.primaryColor, width: 2)),
    );
  }
}
