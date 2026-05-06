import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/data_provider.dart';
import '../../providers/localization_provider.dart';
import '../../utils/constants.dart';
import 'add_mortality_screen.dart';
import '../costs/add_cost_screen.dart';

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
    final loc = context.watch<LocalizationProvider>();

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(loc.translate('batch_detail.title')),
      ),
      body: Consumer<DataProvider>(
        builder: (_, data, __) {
          if (data.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor));
          }
          final batch = data.batchDetail;
          if (batch == null) {
            return Center(child: Text(loc.translate('batch_detail.error_loading')));
          }

          final species = batch['species'] as Map<String, dynamic>?;
          final icon = species != null ? AppConstants.speciesEmoji(species['icon'] ?? '') : '🐾';
          final initial = batch['initial_quantity'] ?? 0;
          final current = batch['current_quantity'] ?? 0;
          final mortality = initial > 0 ? ((initial - current) / initial * 100) : 0.0;
          final mortalities = batch['mortalities'] as List<dynamic>? ?? [];
          final costs = batch['costs'] as List<dynamic>? ?? [];

          return RefreshIndicator(
            color: AppConstants.primaryColor,
            onRefresh: () => data.loadBatchDetail(widget.batchId),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Header do lote
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
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppConstants.primaryColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(child: Text(icon, style: const TextStyle(fontSize: 30))),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(batch['name'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                Text(species?['name'] ?? '', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          _InfoTile(label: loc.translate('batch_detail.initial_quantity'), value: '$initial'),
                          _InfoTile(label: loc.translate('batch_detail.current_quantity'), value: '$current', valueColor: AppConstants.primaryColor),
                          _InfoTile(label: loc.translate('batch_detail.mortality'), value: '${mortality.toStringAsFixed(1)}%', valueColor: mortality > 5 ? AppConstants.errorColor : AppConstants.warningColor),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Botões de acção
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.receipt_long,
                        label: loc.translate('batch_detail.register_cost'),
                        color: AppConstants.primaryColor,
                        onTap: () async {
                          final result = await Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => AddCostScreen(batchId: widget.batchId, batchName: batch['name'] ?? '')),
                          );
                          if (result == true && mounted) {
                            context.read<DataProvider>().loadBatchDetail(widget.batchId);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.warning_amber,
                        label: loc.translate('batch_detail.register_mortality'),
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
                const SizedBox(height: 24),

                // Registos de mortalidade
                Text(
                  loc.translate('batch_detail.mortality_records'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppConstants.primaryDark),
                ),
                const SizedBox(height: 8),
                if (mortalities.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(loc.translate('mortalities.no_records'), style: TextStyle(color: Colors.grey[500])),
                    ),
                  )
                else
                  ...mortalities.map((m) {
                    final date = m['entry_date'] ?? m['created_at'] ?? '';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppConstants.errorColor.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppConstants.errorColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text('${m['quantity']}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppConstants.errorColor)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  m['cause'] ?? loc.translate('mortalities.no_cause'),
                                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                                ),
                                Text(date, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                const SizedBox(height: 24),

                // Custos recentes
                Text(
                  loc.translate('batch_detail.recent_costs'),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppConstants.primaryDark),
                ),
                const SizedBox(height: 8),
                if (costs.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(loc.translate('batch_detail.no_costs'), style: TextStyle(color: Colors.grey[500])),
                    ),
                  )
                else
                  ...costs.take(5).map((cost) {
                    final category = cost['category'] as Map<String, dynamic>?;
                    final catIcon = category != null ? AppConstants.categoryEmoji(category['icon'] ?? '') : '📦';
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
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category?['name'] ?? loc.translate('common.cost'),
                                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                                ),
                                if (cost['description'] != null)
                                  Text(cost['description'], style: TextStyle(fontSize: 12, color: Colors.grey[500])),
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
                                  loc.translateStatus(cost['status'] ?? 'pending'),
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
