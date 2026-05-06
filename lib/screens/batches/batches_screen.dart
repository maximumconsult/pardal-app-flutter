import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/data_provider.dart';
import '../../providers/localization_provider.dart';
import '../../utils/constants.dart';
import 'batch_detail_screen.dart';

class BatchesScreen extends StatefulWidget {
  const BatchesScreen({super.key});

  @override
  State<BatchesScreen> createState() => _BatchesScreenState();
}

class _BatchesScreenState extends State<BatchesScreen> {
  void _showAddBatchDialog(BuildContext context, LocalizationProvider loc) {
    final nameCtrl = TextEditingController();
    final quantityCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    int? selectedSpeciesId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final data = context.read<DataProvider>();
            return Container(
              padding: EdgeInsets.only(
                top: 24,
                left: 24,
                right: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      Text(
                        loc.translate('batches.add_batch'),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: nameCtrl,
                        decoration: InputDecoration(
                          labelText: loc.translate('batches.batch_name'),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.label_outline),
                        ),
                        validator: (v) => v == null || v.isEmpty ? loc.translate('common.required') : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        value: selectedSpeciesId,
                        decoration: InputDecoration(
                          labelText: loc.translate('batches.species'),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.pets),
                        ),
                        items: data.species.map<DropdownMenuItem<int>>((s) {
                          return DropdownMenuItem<int>(
                            value: s['id'] as int,
                            child: Text(s['name'] ?? ''),
                          );
                        }).toList(),
                        onChanged: (v) => setModalState(() => selectedSpeciesId = v),
                        validator: (v) => v == null ? loc.translate('common.required') : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: quantityCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: loc.translate('batches.initial_quantity'),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          prefixIcon: const Icon(Icons.numbers),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return loc.translate('common.required');
                          if (int.tryParse(v) == null) return loc.translate('common.invalid_number');
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (!formKey.currentState!.validate()) return;
                            final now = DateTime.now();
                            final batchData = {
                              'name': nameCtrl.text.trim(),
                              'species_id': selectedSpeciesId,
                              'initial_quantity': int.parse(quantityCtrl.text.trim()),
                              'start_date': now.toIso8601String().split('T')[0],
                            };
                            try {
                              await data.storeBatch(batchData);
                              if (ctx.mounted) Navigator.of(ctx).pop();
                              data.loadBatches();
                            } catch (e) {
                              if (ctx.mounted) {
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  SnackBar(content: Text(e.toString()), backgroundColor: AppConstants.errorColor),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(loc.translate('common.save'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
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
        title: Text(loc.translate('batches.cycles_batches')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: loc.translate('common.refresh'),
            onPressed: () => context.read<DataProvider>().loadBatches(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddBatchDialog(context, loc);
        },
        backgroundColor: AppConstants.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
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
                  Text(loc.translate('batches.no_batches'), style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => data.loadBatches(),
                    child: Text(loc.translate('common.refresh')),
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
                  _SectionHeader(title: loc.translate('batches.active_batches'), count: activeBatches.length),
                  const SizedBox(height: 8),
                  ...activeBatches.map((b) => _BatchCard(batch: b)),
                ],
                if (completedBatches.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _SectionHeader(title: loc.translate('batches.completed_batches'), count: completedBatches.length),
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
    final loc = context.watch<LocalizationProvider>();
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
                          loc.translateStatus(batch['status'] ?? 'active'),
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
                    '${species?['name'] ?? ''} · $current / $initial ${loc.translate('common.animals')}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  if (mortality > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.trending_down, size: 14, color: mortality > 5 ? AppConstants.errorColor : Colors.orange),
                        const SizedBox(width: 4),
                        Text(
                          loc.translateWithParams('batches.mortality_label', {'rate': mortality.toStringAsFixed(1)}),
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
