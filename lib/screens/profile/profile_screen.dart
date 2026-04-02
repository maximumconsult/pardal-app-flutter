import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
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
    final success = await auth.updateProfile(_nameCtrl.text, _phoneCtrl.text);
    if (success && mounted) {
      setState(() => _editingProfile = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado!'), backgroundColor: AppConstants.successColor),
      );
    } else if (mounted && auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error!), backgroundColor: AppConstants.errorColor),
      );
    }
  }

  Future<void> _savePassword() async {
    if (_newPassCtrl.text != _confirmPassCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('As palavras-passe não coincidem'), backgroundColor: AppConstants.errorColor),
      );
      return;
    }
    if (_newPassCtrl.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A palavra-passe deve ter pelo menos 6 caracteres'), backgroundColor: AppConstants.errorColor),
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
        const SnackBar(content: Text('Palavra-passe alterada!'), backgroundColor: AppConstants.successColor),
      );
    } else if (mounted && auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error!), backgroundColor: AppConstants.errorColor),
      );
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Tem a certeza que deseja sair?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sair', style: TextStyle(color: AppConstants.errorColor)),
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
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Meu Perfil'),
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
                        auth.userRole == 'admin' ? 'Administrador' : auth.userRole == 'manager' ? 'Gestor' : 'Colaborador',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppConstants.primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

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
                        const Expanded(child: Text('Dados Pessoais', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                        TextButton(
                          onPressed: () => setState(() => _editingProfile = !_editingProfile),
                          child: Text(_editingProfile ? 'Cancelar' : 'Editar'),
                        ),
                      ],
                    ),
                    if (_editingProfile) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: _nameCtrl,
                        decoration: _inputDecoration('Nome'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: _inputDecoration('Telefone'),
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
                              : const Text('Guardar'),
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
                        const Expanded(child: Text('Alterar Palavra-passe', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                        TextButton(
                          onPressed: () => setState(() => _editingPassword = !_editingPassword),
                          child: Text(_editingPassword ? 'Cancelar' : 'Alterar'),
                        ),
                      ],
                    ),
                    if (_editingPassword) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: _currentPassCtrl,
                        obscureText: true,
                        decoration: _inputDecoration('Palavra-passe actual'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _newPassCtrl,
                        obscureText: true,
                        decoration: _inputDecoration('Nova palavra-passe'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _confirmPassCtrl,
                        obscureText: true,
                        decoration: _inputDecoration('Confirmar nova palavra-passe'),
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
                              : const Text('Guardar Palavra-passe'),
                        ),
                      ),
                    ],
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
                  label: const Text('Sair', style: TextStyle(color: AppConstants.errorColor, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppConstants.errorColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Versão
              Center(
                child: Text('Pardal v1.0.0', style: TextStyle(fontSize: 12, color: Colors.grey[400])),
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
