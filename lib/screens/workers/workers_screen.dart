import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/data_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/pardal_app_bar.dart';

class WorkersScreen extends StatefulWidget {
  const WorkersScreen({super.key});

  @override
  State<WorkersScreen> createState() => _WorkersScreenState();
}

class _WorkersScreenState extends State<WorkersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataProvider>().loadWorkers();
    });
  }

  void _showAddWorkerDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    String selectedRole = 'worker';
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Adicionar Colaborador',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Preencha os dados do novo colaborador',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 20),

                  // Nome
                  const Text('Nome Completo *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: _inputDecoration('Ex: João Silva'),
                    validator: (v) => (v == null || v.isEmpty) ? 'Nome é obrigatório' : null,
                  ),
                  const SizedBox(height: 14),

                  // Email
                  const Text('Email *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _inputDecoration('Ex: joao@email.com'),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Email é obrigatório';
                      if (!v.contains('@')) return 'Email inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Telefone
                  const Text('Telefone', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: _inputDecoration('Ex: +258 84 123 4567'),
                  ),
                  const SizedBox(height: 14),

                  // Password
                  const Text('Palavra-passe *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: passwordCtrl,
                    obscureText: true,
                    decoration: _inputDecoration('Mínimo 6 caracteres'),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Palavra-passe é obrigatória';
                      if (v.length < 6) return 'Mínimo 6 caracteres';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Função
                  const Text('Função *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setSheetState(() => selectedRole = 'worker'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: selectedRole == 'worker' ? AppConstants.primaryColor.withOpacity(0.1) : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: selectedRole == 'worker' ? AppConstants.primaryColor : Colors.grey.shade300,
                                width: selectedRole == 'worker' ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.person, color: selectedRole == 'worker' ? AppConstants.primaryColor : Colors.grey[400], size: 28),
                                const SizedBox(height: 4),
                                Text(
                                  'Colaborador',
                                  style: TextStyle(
                                    fontWeight: selectedRole == 'worker' ? FontWeight.w700 : FontWeight.w500,
                                    color: selectedRole == 'worker' ? AppConstants.primaryColor : Colors.grey[600],
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setSheetState(() => selectedRole = 'manager'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: selectedRole == 'manager' ? AppConstants.accentColor.withOpacity(0.1) : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: selectedRole == 'manager' ? AppConstants.accentColor : Colors.grey.shade300,
                                width: selectedRole == 'manager' ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.manage_accounts, color: selectedRole == 'manager' ? AppConstants.accentColor : Colors.grey[400], size: 28),
                                const SizedBox(height: 4),
                                Text(
                                  'Gestor',
                                  style: TextStyle(
                                    fontWeight: selectedRole == 'manager' ? FontWeight.w700 : FontWeight.w500,
                                    color: selectedRole == 'manager' ? AppConstants.accentColor : Colors.grey[600],
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Botão
                  Consumer<DataProvider>(
                    builder: (_, data, __) => SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: data.isLoading ? null : () async {
                          if (!formKey.currentState!.validate()) return;
                          final body = <String, dynamic>{
                            'name': nameCtrl.text,
                            'email': emailCtrl.text,
                            'password': passwordCtrl.text,
                            'role': selectedRole,
                          };
                          if (phoneCtrl.text.isNotEmpty) body['phone'] = phoneCtrl.text;

                          final success = await data.addWorker(body);
                          if (success && ctx.mounted) {
                            await data.loadWorkers();
                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                              _showWorkerAddedDialog(nameCtrl.text, selectedRole);
                            }
                          } else if (ctx.mounted && data.error != null) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(content: Text(data.error!), backgroundColor: AppConstants.errorColor),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: data.isLoading
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Adicionar Colaborador', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showWorkerAddedDialog(String name, String role) {
    final roleLabel = role == 'manager' ? 'Gestor' : 'Colaborador';
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppConstants.successColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_add, color: AppConstants.successColor, size: 48),
            ),
            const SizedBox(height: 16),
            const Text(
              'Colaborador Adicionado!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '$name foi adicionado como $roleLabel. Pode agora fazer login no Pardal com as credenciais fornecidas.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('OK'),
            ),
          ),
        ],
      ),
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'admin':
        return AppConstants.errorColor;
      case 'manager':
        return AppConstants.accentColor;
      default:
        return AppConstants.primaryColor;
    }
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'admin':
        return 'Administrador';
      case 'manager':
        return 'Gestor';
      default:
        return 'Colaborador';
    }
  }

  IconData _roleIcon(String role) {
    switch (role) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'manager':
        return Icons.manage_accounts;
      default:
        return Icons.person;
    }
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppConstants.primaryColor, width: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final userRole = auth.user?['role'] ?? '';
    final isAdminOrManager = userRole == 'admin' || userRole == 'manager';

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: PardalAppBar.build(title: 'Equipa'),
      body: Consumer<DataProvider>(
        builder: (_, data, __) {
          if (data.isLoading && data.workers.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor));
          }

          final workers = data.workers;

          if (workers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.group_off, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('Nenhum colaborador', style: TextStyle(fontSize: 18, color: Colors.grey[500], fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text('Adicione colaboradores para gerir a sua quinta', style: TextStyle(fontSize: 14, color: Colors.grey[400])),
                ],
              ),
            );
          }

          // Group by role
          final admins = workers.where((w) => w['role'] == 'admin').toList();
          final managers = workers.where((w) => w['role'] == 'manager').toList();
          final workersList = workers.where((w) => w['role'] == 'worker').toList();

          return RefreshIndicator(
            onRefresh: () => data.loadWorkers(),
            color: AppConstants.primaryColor,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Summary card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Row(
                    children: [
                      _summaryItem('Total', workers.length.toString(), Icons.group, AppConstants.primaryColor),
                      _divider(),
                      _summaryItem('Gestores', managers.length.toString(), Icons.manage_accounts, AppConstants.accentColor),
                      _divider(),
                      _summaryItem('Colaboradores', workersList.length.toString(), Icons.person, Colors.blue),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Admins
                if (admins.isNotEmpty) ...[
                  _sectionHeader('Administradores', admins.length),
                  const SizedBox(height: 8),
                  ...admins.map((w) => _workerCard(w)),
                  const SizedBox(height: 16),
                ],

                // Managers
                if (managers.isNotEmpty) ...[
                  _sectionHeader('Gestores', managers.length),
                  const SizedBox(height: 8),
                  ...managers.map((w) => _workerCard(w)),
                  const SizedBox(height: 16),
                ],

                // Workers
                if (workersList.isNotEmpty) ...[
                  _sectionHeader('Colaboradores', workersList.length),
                  const SizedBox(height: 8),
                  ...workersList.map((w) => _workerCard(w)),
                ],
              ],
            ),
          );
        },
      ),
      floatingActionButton: isAdminOrManager
          ? FloatingActionButton.extended(
              onPressed: _showAddWorkerDialog,
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.person_add),
              label: const Text('Adicionar', style: TextStyle(fontWeight: FontWeight.w600)),
            )
          : null,
    );
  }

  Widget _summaryItem(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 40, color: Colors.grey[200]);
  }

  Widget _sectionHeader(String title, int count) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text('$count', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppConstants.primaryColor)),
        ),
      ],
    );
  }

  Widget _workerCard(Map<String, dynamic> worker) {
    final role = worker['role'] ?? 'worker';
    final status = worker['status'] ?? 'active';
    final createdAt = worker['created_at'] != null
        ? DateFormat('dd/MM/yyyy').format(DateTime.parse(worker['created_at']))
        : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _roleColor(role).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_roleIcon(role), color: _roleColor(role), size: 24),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        worker['name'] ?? 'Sem nome',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _roleColor(role).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _roleLabel(role),
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _roleColor(role)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.email_outlined, size: 14, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        worker['email'] ?? '-',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (worker['phone'] != null && worker['phone'].toString().isNotEmpty) ...[
                      Icon(Icons.phone_outlined, size: 14, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(worker['phone'], style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                      const SizedBox(width: 12),
                    ],
                    Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text('Desde $createdAt', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                  ],
                ),
              ],
            ),
          ),
          // Status indicator
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: status == 'active' ? AppConstants.successColor : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
