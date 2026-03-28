import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/data_provider.dart';
import '../../utils/constants.dart';
import '../costs/add_cost_screen.dart';
import 'add_mortality_screen.dart';

class BatchDetailScreen extends StatefulWidget {
  final int batchId;
  const BatchDetailScreen({super.key, required this.batchId});

  @override
  State<BatchDetailScreen> createState() => _BatchDetailScreenState();
}

class _BatchDetailScreenState extends State<BatchDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataProvider>().loadBatchDetail(widget.batchId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Detalhe do Lote'),
      ),
      body: Consumer<DataProvider>(
        builder: (_, data, __) {
          if (data.isLoading && data.batchDetail == null) {
            return const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor));
          }
          final detail = data.batchDetail;
          if (detail == null) {
            return const Center(child: Text('Erro ao carregar o lote'));
          }

          final batch = detail['batch'] as Map<String, dynamic>? ?? detail;
          final species = batch['species'] as Map<String, dynamic>?;
          final icon = species != null ? AppConstants.speciesEmoji(species['icon'] ?? '') : '🐾';
          final initial = batch['initial_quantity'] ?? 0;
          final current = batch['current_quantity'] ?? 0;
          final mortalityRate = batch['mortality_rate'];
          final mortality = mortalityRate is num ? mortalityRate.toDouble() : (initial > 0 ? ((initial - current) / initial * 100) : 0.0);
          final isActive = batch['status'] == 'active';
          final costs = batch['approved_costs'] as List<dynamic>? ?? batch['pending_costs'] as List<dynamic>? ?? detail['costs'] as List<dynamic>? ?? [];
          final mortalityLogs = batch['mortality_logs'] as List<dynamic>? ?? detail['mortality_logs'] as List<dynamic>? ?? [];

          return RefreshIndicator(
            color: AppConstants.primaryColor,
            onRefresh: () => data.loadBatchDetail(widget.batchId),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Cabeçalho do lote
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppConstants.accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(child: Text(icon, style: const TextStyle(fontSize: 32))),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(batch['name'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                Text(species?['name'] ?? '', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isActive ? AppConstants.accentColor.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              AppConstants.statusLabel(batch['status'] ?? ''),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isActive ? AppConstants.primaryColor : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          _InfoTile(label: 'Quantidade Inicial', value: '$initial'),
                          _InfoTile(label: 'Quantidade Actual', value: '$current'),
                          _InfoTile(
                            label: 'Mortalidade',
                            value: '${mortality.toStringAsFixed(1)}%',
                            valueColor: mortality > 5 ? AppConstants.errorColor : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Acções rápidas
                if (isActive) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.add_circle_outline,
                          label: 'Registar Custo',
                          color: AppConstants.primaryColor,
                          onTap: () async {
                            final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => AddCostScreen(batchId: widget.batchId, batchName: batch['name'] ?? ''),
                              ),
                            );
                            if (result == true && mounted) {
                              context.read<DataProvider>().loadBatchDetail(widget.batchId);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.trending_down,
                          label: 'Registar Mortalidade',
                          color: AppConstants.errorColor,
                          onTap: () async {
                            final result = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => AddMortalityScreen(
                                  batchId: widget.batchId,
                                  batchName: batch['name'] ?? '',
                                  currentQuantity: current,
                                ),
                              ),
                            );
                            if (result == true && mounted) {
                              context.read<DataProvider>().loadBatchDetail(widget.batchId);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],

                // Registos de mortalidade
                if (mortalityLogs.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text('Registos de Mortalidade', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppConstants.primaryDark)),
                  const SizedBox(height: 8),
                  ...mortalityLogs.take(5).map((log) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppConstants.errorColor.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.trending_down, color: AppConstants.errorColor, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${log['quantity']} animais', style: const TextStyle(fontWeight: FontWeight.w600)),
                              if (log['cause'] != null)
                                Text(log['cause'], style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                            ],
                          ),
                        ),
                        Text(log['entry_date'] ?? log['date'] ?? '', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                      ],
                    ),
                  )),
                ],

                // Custos recentes
                const SizedBox(height: 24),
                const Text('Custos Recentes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppConstants.primaryDark)),
                const SizedBox(height: 8),
                if (costs.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                    child: const Center(child: Text('Nenhum custo registado', style: TextStyle(color: Colors.grey))),
                  )
                else
                  ...costs.take(10).map((cost) {
                    final cat = cost['category'] as Map<String, dynamic>?;
                    final catIcon = cat != null ? AppConstants.categoryEmoji(cat['icon'] ?? '') : '📦';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Text(catIcon, style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(cat?['name'] ?? 'Custo', style: const TextStyle(fontWeight: FontWeight.w500)),
                                if (cost['description'] != null && cost['description'] != '')
                                  Text(cost['description'], style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${cost['total_value']} MT',
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: cost['status'] == 'approved'
                                      ? AppConstants.accentColor.withOpacity(0.1)
                                      : cost['status'] == 'rejected'
                                          ? AppConstants.errorColor.withOpacity(0.1)
                                          : Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  AppConstants.statusLabel(cost['status'] ?? ''),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: cost['status'] == 'approved'
                                        ? AppConstants.primaryColor
                                        : cost['status'] == 'rejected'
                                            ? AppConstants.errorColor
                                            : Colors.orange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _InfoTile({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: valueColor ?? AppConstants.primaryDark)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600]), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
