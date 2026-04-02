import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../utils/constants.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Consumer<AuthProvider>(
          builder: (_, auth, __) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Pardal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(
                'Olá, ${auth.userName}',
                style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8)),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<DataProvider>().loadDashboard(),
          ),
        ],
      ),
      body: Consumer<DataProvider>(
        builder: (_, data, __) {
          if (data.isLoading && data.dashboard == null) {
            return const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor));
          }
          if (data.error != null && data.dashboard == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(data.error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => data.loadDashboard(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tentar novamente'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          final d = data.dashboard;
          if (d == null) return const SizedBox.shrink();

          // Extrair KPIs - a API retorna os dados dentro de 'kpis'
          final kpis = d['kpis'] as Map<String, dynamic>? ?? d;
          final activeBatchesList = d['active_batches'] as List<dynamic>? ?? [];
          final farm = d['farm'] as Map<String, dynamic>?;
          final currency = farm?['currency'] ?? 'MT';

          return RefreshIndicator(
            color: AppConstants.primaryColor,
            onRefresh: () => data.loadDashboard(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Nome da quinta
                if (farm != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      farm['name'] ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppConstants.primaryDark,
                      ),
                    ),
                  ),

                // KPIs principais - linha 1
                Row(
                  children: [
                    _KpiCard(
                      icon: Icons.inventory_2,
                      label: 'Lotes Activos',
                      value: '${kpis['active_batches'] ?? 0}',
                      color: AppConstants.primaryColor,
                    ),
                    const SizedBox(width: 12),
                    _KpiCard(
                      icon: Icons.pets,
                      label: 'Animais Vivos',
                      value: '${kpis['total_animals'] ?? 0}',
                      color: AppConstants.accentColor,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // KPIs - linha 2
                Row(
                  children: [
                    _KpiCard(
                      icon: Icons.warning_amber,
                      label: 'Ocorrências',
                      value: '${kpis['pending_incidents'] ?? 0}',
                      color: AppConstants.warningColor,
                      subtitle: '${kpis['urgent_incidents'] ?? 0} urgentes',
                    ),
                    const SizedBox(width: 12),
                    _KpiCard(
                      icon: Icons.receipt_long,
                      label: 'Custos Pendentes',
                      value: '${kpis['pending_costs_count'] ?? 0}',
                      color: Colors.blue,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Resumo financeiro
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Resumo Financeiro',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppConstants.primaryDark),
                      ),
                      const SizedBox(height: 12),
                      _FinanceRow(
                        label: 'Custos Activos',
                        value: '${_formatNumber(kpis['total_active_costs'])} $currency',
                        color: AppConstants.errorColor,
                        icon: Icons.trending_down,
                      ),
                      const SizedBox(height: 8),
                      _FinanceRow(
                        label: 'Receita Total',
                        value: '${_formatNumber(kpis['total_revenue'])} $currency',
                        color: AppConstants.accentColor,
                        icon: Icons.trending_up,
                      ),
                      const Divider(height: 20),
                      _FinanceRow(
                        label: 'Lucro Global',
                        value: '${_formatNumber(kpis['global_profit'])} $currency',
                        color: (kpis['is_profitable'] == true) ? AppConstants.accentColor : AppConstants.errorColor,
                        icon: (kpis['is_profitable'] == true) ? Icons.thumb_up : Icons.thumb_down,
                        bold: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Lotes activos
                const Text(
                  'Lotes Activos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppConstants.primaryDark),
                ),
                const SizedBox(height: 12),
                if (activeBatchesList.isNotEmpty)
                  ...activeBatchesList.map((batch) {
                    final icon = AppConstants.speciesEmoji(batch['icon'] ?? '');
                    final progress = (batch['progress'] ?? 0) as num;
                    final mortalityRate = (batch['mortality_rate'] ?? 0) as num;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppConstants.primaryColor.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(child: Text(icon, style: const TextStyle(fontSize: 26))),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      batch['name'] ?? '',
                                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${batch['species'] ?? ''} · ${batch['current_quantity'] ?? 0}/${batch['initial_quantity'] ?? 0} animais',
                                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Dia ${batch['days_elapsed'] ?? 0}',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppConstants.primaryColor),
                                  ),
                                  Text(
                                    '${batch['days_remaining'] ?? 0} restantes',
                                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Barra de progresso
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress / 100,
                              backgroundColor: Colors.grey.shade200,
                              color: AppConstants.accentColor,
                              minHeight: 6,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Detalhes do lote
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Mortalidade: ${mortalityRate.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: mortalityRate > 5 ? AppConstants.errorColor : Colors.grey[600],
                                  fontWeight: mortalityRate > 5 ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                              Text(
                                'Custo: ${_formatNumber(batch['total_cost'])} $currency',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  })
                else
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text('Nenhum lote activo', style: TextStyle(color: Colors.grey)),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  static String _formatNumber(dynamic value) {
    if (value == null) return '0';
    final num n = value is num ? value : num.tryParse(value.toString()) ?? 0;
    if (n >= 1000000) {
      return '${(n / 1000000).toStringAsFixed(1)}M';
    } else if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(1)}K';
    }
    return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 2);
  }
}

class _KpiCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final String? subtitle;

  const _KpiCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(subtitle!, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            ],
          ],
        ),
      ),
    );
  }
}

class _FinanceRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final bool bold;

  const _FinanceRow({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
