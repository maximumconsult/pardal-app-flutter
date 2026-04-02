import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../utils/constants.dart';
import '../../providers/localization_provider.dart';

class MortalitiesScreen extends StatefulWidget {
  const MortalitiesScreen({super.key});

  @override
  State<MortalitiesScreen> createState() => _MortalitiesScreenState();
}

class _MortalitiesScreenState extends State<MortalitiesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataProvider>().loadMortalities();
    });
  }

  void _confirmDelete(BuildContext context, int mortalityId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar Registo'),
        content: const Text('Tem a certeza que deseja eliminar este registo de mortalidade? Esta acção irá restaurar a quantidade de animais no lote.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await context.read<DataProvider>().deleteMortality(mortalityId);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Registo eliminado com sucesso'), backgroundColor: AppConstants.primaryColor),
                );
                context.read<DataProvider>().loadMortalities();
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.read<DataProvider>().error ?? 'Erro ao eliminar'), backgroundColor: AppConstants.errorColor),
                );
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isAdminOrManager = auth.userRole == 'admin' || auth.userRole == 'manager';

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Consumer<LocalizationProvider>(
          builder: (_, localization, __) => Text(localization.translate('common.mortality')),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<DataProvider>().loadMortalities(),
          ),
        ],
      ),
      body: Consumer<DataProvider>(
        builder: (_, data, __) {
          if (data.isLoading && data.mortalities.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor));
          }
          if (data.mortalities.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pets_outlined, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('Nenhum registo de mortalidade', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => data.loadMortalities(),
                    child: const Text('Actualizar'),
                  ),
                ],
              ),
            );
          }

          final summary = data.mortalitySummary;

          return RefreshIndicator(
            color: AppConstants.primaryColor,
            onRefresh: () => data.loadMortalities(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Summary cards
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        title: 'Total Registos',
                        value: '${summary?['total_records'] ?? data.mortalities.length}',
                        icon: Icons.assignment,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryCard(
                        title: 'Total Mortes',
                        value: '${summary?['total_deaths'] ?? 0}',
                        icon: Icons.pets,
                        color: AppConstants.errorColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Histórico de Mortalidades',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppConstants.primaryDark),
                ),
                const SizedBox(height: 12),
                ...data.mortalities.map((m) => _MortalityCard(
                  mortality: m,
                  canDelete: isAdminOrManager,
                  onDelete: () => _confirmDelete(context, m['id'] as int),
                )),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }
}

class _MortalityCard extends StatelessWidget {
  final Map<String, dynamic> mortality;
  final bool canDelete;
  final VoidCallback onDelete;

  const _MortalityCard({
    required this.mortality,
    required this.canDelete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final batch = mortality['batch'] as Map<String, dynamic>?;
    final reporter = mortality['reporter'] as Map<String, dynamic>?;
    final date = mortality['date'] ?? '';
    final quantity = mortality['quantity'] ?? 0;
    final cause = mortality['cause'] ?? 'Sem causa registada';
    final createdAt = mortality['created_at'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppConstants.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$quantity mortes',
                  style: const TextStyle(
                    color: AppConstants.errorColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  batch?['name'] ?? 'Lote desconhecido',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (canDelete)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.medical_services_outlined, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Causa: $cause',
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 12, color: Colors.grey[400]),
              const SizedBox(width: 4),
              Text(
                'Data: $date',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              const SizedBox(width: 16),
              Icon(Icons.person_outline, size: 12, color: Colors.grey[400]),
              const SizedBox(width: 4),
              Text(
                reporter?['name'] ?? 'Desconhecido',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
          if (createdAt.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 12, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Text(
                  'Registado: $createdAt',
                  style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
