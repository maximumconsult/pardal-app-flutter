import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/localization_provider.dart';
import '../../utils/constants.dart';

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
    final auth = context.read<AuthProvider>();
    final localization = context.read<LocalizationProvider>();
    final success = await auth.updateProfile(_nameCtrl.text, _phoneCtrl.text);
    if (success && mounted) {
      setState(() => _editingProfile = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localization.translate('profile.profile_updated')),
          backgroundColor: AppConstants.successColor,
        ),
      );
    } else if (mounted && auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error!), backgroundColor: AppConstants.errorColor),
      );
    }
  }

  Future<void> _savePassword() async {
    final localization = context.read<LocalizationProvider>();
    
    if (_newPassCtrl.text != _confirmPassCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localization.translate('profile.passwords_mismatch')),
          backgroundColor: AppConstants.errorColor,
        ),
      );
      return;
    }
    if (_newPassCtrl.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localization.translate('profile.password_min_length')),
          backgroundColor: AppConstants.errorColor,
        ),
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
        SnackBar(
          content: Text(localization.translate('profile.password_changed')),
          backgroundColor: AppConstants.successColor,
        ),
      );
    } else if (mounted && auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error!), backgroundColor: AppConstants.errorColor),
      );
    }
  }

  Future<void> _logout() async {
    final localization = context.read<LocalizationProvider>();
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(localization.translate('profile.logout')),
        content: Text(localization.translate('profile.logout_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(localization.translate('common.cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(localization.translate('profile.logout')),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final auth = context.read<AuthProvider>();
      await auth.logout();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = context.watch<LocalizationProvider>();
    
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(localization.translate('navigation.profile')),
      ),
      body: Consumer<AuthProvider>(
        builder: (_, auth, __) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Avatar
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const Center(
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Secção de Perfil
              _SectionCard(
                title: localization.translate('profile.profile'),
                children: [
                  _ProfileField(
                    label: localization.translate('profile.name'),
                    value: auth.userName,
                  ),
                  _ProfileField(
                    label: localization.translate('profile.email'),
                    value: auth.user?['email'] ?? '',
                  ),
                  _ProfileField(
                    label: localization.translate('profile.phone'),
                    value: auth.user?['phone'] ?? '',
                  ),
                  _ProfileField(
                    label: localization.translate('profile.role'),
                    value: auth.user?['role'] ?? '',
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => setState(() => _editingProfile = !_editingProfile),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        _editingProfile
                            ? localization.translate('common.cancel')
                            : localization.translate('profile.edit_profile'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Secção de Segurança
              _SectionCard(
                title: localization.translate('profile.security'),
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => setState(() => _editingPassword = !_editingPassword),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.warningColor,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        _editingPassword
                            ? localization.translate('common.cancel')
                            : localization.translate('profile.change_password'),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Botão Logout
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.errorColor,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(localization.translate('profile.logout')),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppConstants.primaryDark),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppConstants.primaryDark),
          ),
        ],
      ),
    );
  }
}
