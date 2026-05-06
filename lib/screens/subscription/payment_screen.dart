import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/subscription_plan.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/localization_provider.dart';
import '../../utils/constants.dart';

class PaymentScreen extends StatefulWidget {
  final SubscriptionPlan plan;
  final String billingCycle;
  final String changeType;

  const PaymentScreen({
    super.key,
    required this.plan,
    required this.billingCycle,
    required this.changeType,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = 'mpesa';
  bool _isProcessing = false;
  String? _paymentStatus;
  Timer? _pollTimer;

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'mpesa',
      'name': 'M-Pesa',
      'icon': Icons.phone_android,
      'color': Color(0xFFE21C24),
      'description': 'Vodacom M-Pesa',
    },
    {
      'id': 'emola',
      'name': 'e-Mola',
      'icon': Icons.phone_android,
      'color': Color(0xFF0066B3),
      'description': 'Movitel e-Mola',
    },
    {
      'id': 'mkesh',
      'name': 'mKesh',
      'icon': Icons.phone_android,
      'color': Color(0xFF00A651),
      'description': 'Tmcel mKesh',
    },
    {
      'id': 'card',
      'name': 'Cartão',
      'icon': Icons.credit_card,
      'color': Color(0xFF1A237E),
      'description': 'Visa / Mastercard',
    },
  ];

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  double get _amount {
    if (widget.billingCycle == 'annual') {
      return widget.plan.annualPrice ?? (widget.plan.monthlyPrice * 12);
    }
    return widget.plan.monthlyPrice;
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
        title: Text(loc.translate('subscription.payment')),
      ),
      body: _paymentStatus != null
          ? _buildPaymentStatusView(loc)
          : _buildPaymentForm(loc),
    );
  }

  Widget _buildPaymentForm(LocalizationProvider loc) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Resumo do plano
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.workspace_premium, color: AppConstants.primaryColor, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${loc.translate('subscription.plan')} ${widget.plan.name}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.changeType == 'upgrade'
                              ? loc.translate('subscription.upgrading')
                              : loc.translate('subscription.subscribing'),
                          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(loc.translate('subscription.billing_cycle'), style: TextStyle(color: Colors.grey[600])),
                  Text(
                    widget.billingCycle == 'annual'
                        ? loc.translate('subscription.annual')
                        : loc.translate('subscription.monthly'),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(loc.translate('subscription.total'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(
                    '${_amount.toStringAsFixed(0)} ${widget.plan.currency}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppConstants.primaryColor),
                  ),
                ],
              ),
              if (widget.billingCycle == 'annual' && widget.plan.annualSavings != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppConstants.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${loc.translate('subscription.you_save')} ${widget.plan.annualSavings!.toStringAsFixed(0)} ${widget.plan.currency}',
                    style: const TextStyle(color: AppConstants.accentColor, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Selecção de método de pagamento
        Text(
          loc.translate('subscription.select_method'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        ...(_paymentMethods.map((method) => _buildMethodCard(method))),

        const SizedBox(height: 24),

        // Botão pagar
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isProcessing ? null : _processPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: _isProcessing
                ? const SizedBox(
                    width: 22, height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '${loc.translate('subscription.pay')} ${_amount.toStringAsFixed(0)} ${widget.plan.currency}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 12),

        // Nota de segurança
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shield, size: 14, color: Colors.grey[400]),
            const SizedBox(width: 6),
            Text(
              loc.translate('subscription.secure_payment'),
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMethodCard(Map<String, dynamic> method) {
    final isSelected = _selectedMethod == method['id'];

    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = method['id'] as String),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppConstants.primaryColor : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: AppConstants.primaryColor.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (method['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(method['icon'] as IconData, color: method['color'] as Color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(method['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  Text(method['description'] as String, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                ],
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppConstants.primaryColor : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentStatusView(LocalizationProvider loc) {
    final isSuccess = _paymentStatus == 'completed' || _paymentStatus == 'paid';
    final isPending = _paymentStatus == 'pending' || _paymentStatus == 'processing';
    final isFailed = _paymentStatus == 'failed' || _paymentStatus == 'error';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone de estado
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSuccess
                    ? AppConstants.accentColor.withOpacity(0.1)
                    : isPending
                        ? AppConstants.warningColor.withOpacity(0.1)
                        : AppConstants.errorColor.withOpacity(0.1),
              ),
              child: Icon(
                isSuccess
                    ? Icons.check_circle
                    : isPending
                        ? Icons.hourglass_top
                        : Icons.error,
                size: 48,
                color: isSuccess
                    ? AppConstants.accentColor
                    : isPending
                        ? AppConstants.warningColor
                        : AppConstants.errorColor,
              ),
            ),
            const SizedBox(height: 24),

            Text(
              isSuccess
                  ? loc.translate('subscription.payment_success')
                  : isPending
                      ? loc.translate('subscription.payment_pending')
                      : loc.translate('subscription.payment_failed'),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            Text(
              isSuccess
                  ? loc.translate('subscription.payment_success_desc')
                  : isPending
                      ? loc.translate('subscription.payment_pending_desc')
                      : loc.translate('subscription.payment_failed_desc'),
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            if (isPending) ...[
              const CircularProgressIndicator(color: AppConstants.primaryColor),
              const SizedBox(height: 16),
              Text(
                loc.translate('subscription.checking_payment'),
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
            ],

            if (isSuccess)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(loc.translate('subscription.go_home')),
                ),
              ),

            if (isFailed) ...[
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => setState(() => _paymentStatus = null),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(loc.translate('subscription.try_again')),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(loc.translate('common.cancel')),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);

    final sub = context.read<SubscriptionProvider>();
    final success = await sub.subscribe(
      widget.plan.id,
      billingCycle: widget.billingCycle,
      paymentMethod: _selectedMethod,
    );

    if (!mounted) return;

    if (success) {
      if (sub.paymentUrl != null) {
        // Abrir URL de pagamento no browser
        final url = Uri.parse(sub.paymentUrl!);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }

        // Iniciar polling do estado do pagamento
        setState(() {
          _isProcessing = false;
          _paymentStatus = 'pending';
        });
        _startPaymentPolling(sub.paymentId!);
      } else {
        // Plano activado directamente (gratuito)
        setState(() {
          _isProcessing = false;
          _paymentStatus = 'completed';
        });
      }
    } else {
      setState(() {
        _isProcessing = false;
        _paymentStatus = 'failed';
      });
    }
  }

  void _startPaymentPolling(String paymentId) {
    int attempts = 0;
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      attempts++;
      if (attempts > 60) {
        // Timeout após 5 minutos
        timer.cancel();
        if (mounted) {
          setState(() => _paymentStatus = 'failed');
        }
        return;
      }

      final sub = context.read<SubscriptionProvider>();
      final status = await sub.checkPaymentStatus(paymentId);

      if (!mounted) {
        timer.cancel();
        return;
      }

      if (status == 'completed' || status == 'paid') {
        timer.cancel();
        setState(() => _paymentStatus = 'completed');
      } else if (status == 'failed' || status == 'cancelled') {
        timer.cancel();
        setState(() => _paymentStatus = 'failed');
      }
    });
  }
}
