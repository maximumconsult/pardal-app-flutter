import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/data_provider.dart';
import '../../providers/localization_provider.dart';
import '../../utils/constants.dart';
import '../../utils/error_helper.dart';

class AddCostScreen extends StatefulWidget {
  final int batchId;
  final String batchName;
  const AddCostScreen({super.key, required this.batchId, required this.batchName});

  @override
  State<AddCostScreen> createState() => _AddCostScreenState();
}

class _AddCostScreenState extends State<AddCostScreen> {
  final _formKey = GlobalKey<FormState>();
  int? _categoryId;
  DateTime _date = DateTime.now();
  final _quantityCtrl = TextEditingController();
  final _unitCtrl = TextEditingController();
  final _unitPriceCtrl = TextEditingController();
  final _totalCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  @override
  void dispose() {
    _quantityCtrl.dispose();
    _unitCtrl.dispose();
    _unitPriceCtrl.dispose();
    _totalCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _calcTotal() {
    final qty = double.tryParse(_quantityCtrl.text) ?? 0;
    final price = double.tryParse(_unitPriceCtrl.text) ?? 0;
    if (qty > 0 && price > 0) {
      _totalCtrl.text = (qty * price).toStringAsFixed(2);
    }
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
    final loc = context.read<LocalizationProvider>();
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.translate('costs.category_required')), backgroundColor: AppConstants.errorColor),
      );
      return;
    }

    final data = context.read<DataProvider>();
    final body = <String, dynamic>{
      'category_id': _categoryId,
      'entry_date': DateFormat('yyyy-MM-dd').format(_date),
      'total_value': double.parse(_totalCtrl.text),
    };
    if (_quantityCtrl.text.isNotEmpty) body['quantity'] = double.parse(_quantityCtrl.text);
    if (_unitCtrl.text.isNotEmpty) body['quantity_unit'] = _unitCtrl.text;
    if (_unitPriceCtrl.text.isNotEmpty) body['unit_price'] = double.parse(_unitPriceCtrl.text);
    if (_descCtrl.text.isNotEmpty) body['description'] = _descCtrl.text;

    final success = await data.storeCost(widget.batchId, body);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.translate('costs.success_message')), backgroundColor: AppConstants.successColor),
      );
      Navigator.of(context).pop(true);
    } else if (mounted && data.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ErrorHelper.translateError(loc, data.error!)), backgroundColor: AppConstants.errorColor),
      );
    }
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
        title: Text('${loc.translate('costs.cost')} - ${widget.batchName}'),
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
                  // Data
                  Text(loc.translate('costs.date'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
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

                  // Categoria
                  Text(loc.translate('costs.category'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _categoryId,
                        isExpanded: true,
                        hint: Text(loc.translate('costs.select_category')),
                        items: data.categories.map<DropdownMenuItem<int>>((cat) {
                          final catIcon = AppConstants.categoryEmoji(cat['icon'] ?? '');
                          return DropdownMenuItem<int>(
                            value: cat['id'] as int,
                            child: Text('$catIcon ${cat['name']}'),
                          );
                        }).toList(),
                        onChanged: (v) => setState(() => _categoryId = v),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Quantidade e Unidade
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(loc.translate('costs.quantity'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _quantityCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: _inputDecoration('Ex: 50'),
                              onChanged: (_) => _calcTotal(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(loc.translate('costs.unit'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _unitCtrl,
                              decoration: _inputDecoration('kg'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Preço unitário
                  Text(loc.translate('costs.unit_price'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _unitPriceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: _inputDecoration('Ex: 25.00'),
                    onChanged: (_) => _calcTotal(),
                  ),
                  const SizedBox(height: 18),

                  // Valor total
                  Text('${loc.translate('costs.total_value')} *', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _totalCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: _inputDecoration('Ex: 1250.00'),
                    validator: (v) {
                      if (v == null || v.isEmpty) return loc.translate('costs.total_required');
                      if (double.tryParse(v) == null || double.parse(v) <= 0) return loc.translate('costs.total_invalid');
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),

                  // Descrição
                  Text(loc.translate('costs.description'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _descCtrl,
                    maxLines: 3,
                    decoration: _inputDecoration(loc.translate('costs.description_hint')),
                  ),
                  const SizedBox(height: 28),

                  // Botão submeter
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: data.isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: data.isLoading
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(loc.translate('costs.register_cost'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppConstants.primaryColor, width: 2)),
    );
  }
}
