import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/data_provider.dart';
import '../../utils/constants.dart';
import 'batch_detail_screen.dart';

class BatchesScreen extends StatelessWidget {
  const BatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Ciclos / Lotes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<DataProvider>().loadBatches(),
          ),
        ],
      ),
      body: Consumer<DataProvider>(
        builder: (_, data, __) {
          if (data.isLoading && data.batches.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor));
          }
          if (data.batches.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('Nenhum lote encontrado', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => data.loadBatches(),
                    child: const Text('Actualizar'),
                  ),
                ],
              ),
            );
          }

          final activeBatches = data.batches.where((b) => b['status'] == 'active').toList();
          final completedBatches = data.batches.where((b) => b['status'] != 'active').toList();

          return RefreshIndicator(
            color: AppConstants.primaryColor,
            onRefresh: () => data.loadBatches(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (activeBatches.isNotEmpty) ...[
                  _SectionHeader(title: 'Lotes Activos', count: activeBatches.length),
                  const SizedBox(height: 8),
                  ...activeBatches.map((b) => _BatchCard(batch: b)),
                ],
                if (completedBatches.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _SectionHeader(title: 'Lotes Concluídos', count: completedBatches.length),
                  const SizedBox(height: 8),
                  ...completedBatches.map((b) => _BatchCard(batch: b, isCompleted: true)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppConstants.primaryDark)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text('$count', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppConstants.primaryColor)),
        ),
      ],
    );
  }
}

class _BatchCard extends StatelessWidget {
  final Map<String, dynamic> batch;
  final bool isCompleted;
  const _BatchCard({required this.batch, this.isCompleted = false});

  @override
  Widget build(BuildContext context) {
    final species = batch['species'] as Map<String, dynamic>?;
    final icon = species != null ? AppConstants.speciesEmoji(species['icon'] ?? '') : '🐾';
    final initial = batch['initial_quantity'] ?? 0;
    final current = batch['current_quantity'] ?? 0;
    final mortality = initial > 0 ? ((initial - current) / initial * 100) : 0.0;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BatchDetailScreen(batchId: batch['id'] as int),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: isCompleted ? Border.all(color: Colors.grey.shade200) : null,
          boxShadow: isCompleted
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isCompleted
                    ? Colors.grey.withOpacity(0.1)
                    : AppConstants.accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(child: Text(icon, style: const TextStyle(fontSize: 28))),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          batch['name'] ?? '',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: isCompleted ? Colors.grey : Colors.black87,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? Colors.grey.withOpacity(0.1)
                              : AppConstants.accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          AppConstants.statusLabel(batch['status'] ?? ''),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isCompleted ? Colors.grey : AppConstants.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${species?['name'] ?? ''} · $current / $initial animais',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  if (mortality > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.trending_down, size: 14, color: mortality > 5 ? AppConstants.errorColor : Colors.orange),
                        const SizedBox(width: 4),
                        Text(
                          'Mortalidade: ${mortality.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: mortality > 5 ? AppConstants.errorColor : Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
