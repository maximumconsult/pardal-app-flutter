import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/data_provider.dart';
import '../../providers/localization_provider.dart';
import '../../utils/constants.dart';
import 'batch_detail_screen.dart';

class BatchesScreen extends StatelessWidget {
  const BatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = context.watch<LocalizationProvider>();
    
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(localization.translate('batches.title')),
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
                  Text(localization.translate('common.no_data'), style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => data.loadBatches(),
                    child: Text(localization.translate('common.try_again')),
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
                  _SectionHeader(
                    title: localization.translate('batches.active'),
                    count: activeBatches.length,
                  ),
                  const SizedBox(height: 8),
                  ...activeBatches.map((b) => _BatchCard(batch: b)),
                ],
                if (completedBatches.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _SectionHeader(
                    title: localization.translate('batches.completed'),
                    count: completedBatches.length,
                  ),
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
    final localization = context.watch<LocalizationProvider>();
    final icon = AppConstants.speciesEmoji(batch['icon'] ?? '');
    final progress = (batch['progress'] ?? 0) as num;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => BatchDetailScreen(batchId: batch['id'])),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
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
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(child: Text(icon, style: const TextStyle(fontSize: 24))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        batch['name'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        batch['species'] ?? '',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                if (!isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppConstants.accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      localization.translate('batches.active'),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppConstants.accentColor),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            if (!isCompleted) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: progress / 100,
                  backgroundColor: Colors.grey.shade200,
                  color: AppConstants.accentColor,
                  minHeight: 5,
                ),
              ),
              const SizedBox(height: 8),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${batch['current_quantity'] ?? 0}/${batch['initial_quantity'] ?? 0} ${localization.translate('common.animals')}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                if (!isCompleted)
                  Text(
                    '${localization.translate('common.day')} ${batch['days_elapsed'] ?? 0}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppConstants.primaryColor),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
