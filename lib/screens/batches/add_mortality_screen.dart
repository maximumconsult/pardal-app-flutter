import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/data_provider.dart';
import '../../utils/constants.dart';

class AddMortalityScreen extends StatefulWidget {
  final int batchId;
  final String batchName;
  final int currentQuantity;
  const AddMortalityScreen({super.key, required this.batchId, required this.batchName, required this.currentQuantity});

  @override
  State<AddMortalityScreen> createState() => _AddMortalityScreenState();
}

class _AddMortalityScreenState extends State<AddMortalityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityCtrl = TextEditingController();
  final _causeCtrl = TextEditingController();
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _quantityCtrl.dispose();
    _causeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppConstants.primaryColor),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final data = context.read<DataProvider>();
    final success = await data.storeMortality(widget.batchId, {
      'quantity': int.parse(_quantityCtrl.text),
      'cause': _causeCtrl.text.isNotEmpty ? _causeCtrl.text : null,
      'entry_date': DateFormat('yyyy-MM-dd').format(_date),
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mortalidade registada com sucesso!'), backgroundColor: AppConstants.successColor),
      );
      Navigator.of(context).pop(true);
    } else if (mounted && data.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data.error!), backgroundColor: AppConstants.errorColor),
      );
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
        title: const Text('Registar Mortalidade'),
      ),
      body: Consumer<DataProvider>(
        builder: (_, data, __) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info do lote
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppConstants.errorColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppConstants.errorColor.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber, color: AppConstants.errorColor),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.batchName, style: const TextStyle(fontWeight: FontWeight.w600)),
                              Text('Quantidade actual: ${widget.currentQuantity} animais', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Data
                  const Text('Data da Ocorrência', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 18, color: AppConstants.primaryColor),
                          const SizedBox(width: 10),
                          Text(DateFormat('dd/MM/yyyy').format(_date), style: const TextStyle(fontSize: 15)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Quantidade
                  const Text('Quantidade de Perdas *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _quantityCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Ex: 5',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppConstants.primaryColor, width: 2)),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Quantidade é obrigatória';
                      final qty = int.tryParse(v);
                      if (qty == null || qty <= 0) return 'Quantidade inválida';
                      if (qty > widget.currentQuantity) return 'Não pode exceder ${widget.currentQuantity}';
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),

                  // Causa
                  const Text('Causa / Motivo', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _causeCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Descreva a causa da mortalidade...',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppConstants.primaryColor, width: 2)),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Botão
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: data.isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.errorColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: data.isLoading
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Registar Mortalidade', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
