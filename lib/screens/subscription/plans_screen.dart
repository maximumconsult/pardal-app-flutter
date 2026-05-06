import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/subscription_plan.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/localization_provider.dart';
import '../../utils/constants.dart';
import 'payment_screen.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  bool _isAnnual = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sub = context.read<SubscriptionProvider>();
      sub.loadPlans();
      sub.loadCurrentSubscription();
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
        title: Text(loc.translate('subscription.plans_title')),
      ),
      body: Consumer<SubscriptionProvider>(
        builder: (_, sub, __) {
          if (sub.isLoading && sub.plans.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor));
          }
          if (sub.error != null && sub.plans.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(loc.translate('subscription.error_loading'),
                      style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => sub.loadPlans(),
                    style: ElevatedButton.styleFrom(backgroundColor: AppConstants.primaryColor),
                    child: Text(loc.translate('common.retry'), style: const TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Header com toggle mensal/anual
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                decoration: const BoxDecoration(
                  color: AppConstants.primaryColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      loc.translate('subscription.choose_plan'),
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    // Toggle mensal/anual
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildToggleButton(
                            label: loc.translate('subscription.monthly'),
                            isSelected: !_isAnnual,
                            onTap: () => setState(() => _isAnnual = false),
                          ),
                          _buildToggleButton(
                            label: loc.translate('subscription.annual'),
                            isSelected: _isAnnual,
                            onTap: () => setState(() => _isAnnual = true),
                            badge: loc.translate('subscription.save_badge'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Lista de planos
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sub.plans.length,
                  itemBuilder: (context, index) {
                    final plan = sub.plans[index];
                    final changeType = sub.getPlanChangeType(plan);
                    return _buildPlanCard(context, plan, changeType, sub, loc);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    String? badge,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppConstants.primaryColor : Colors.white70,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppConstants.accentColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context,
    SubscriptionPlan plan,
    String changeType,
    SubscriptionProvider sub,
    LocalizationProvider loc,
  ) {
    final isCurrent = changeType == 'current';
    final isPopular = plan.slug == 'crescimento';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent
              ? AppConstants.accentColor
              : isPopular
                  ? AppConstants.primaryColor
                  : Colors.grey.shade200,
          width: isCurrent || isPopular ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Badge popular ou plano actual
          if (isPopular || isCurrent)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: isCurrent ? AppConstants.accentColor : AppConstants.primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
              ),
              child: Center(
                child: Text(
                  isCurrent
                      ? loc.translate('subscription.current_plan')
                      : loc.translate('subscription.popular'),
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nome e preço
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(plan.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          if (plan.description != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(plan.description!, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                            ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _isAnnual ? plan.formattedAnnualPrice : plan.formattedMonthlyPrice,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppConstants.primaryColor),
                        ),
                        Text(
                          plan.isFree ? '' : _isAnnual ? '/${loc.translate('subscription.year')}' : '/${loc.translate('subscription.month')}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Funcionalidades
                _buildFeatureRow(Icons.layers, '${plan.maxBatches} ${loc.translate('subscription.batches')}', true),
                _buildFeatureRow(Icons.pets, '${plan.maxSpecies} ${loc.translate('subscription.species')}', true),
                _buildFeatureRow(Icons.people, '${plan.maxUsers} ${loc.translate('subscription.users')}', true),
                _buildFeatureRow(Icons.bar_chart, loc.translate('subscription.reports'), plan.hasReports),
                _buildFeatureRow(Icons.warning_amber, loc.translate('subscription.incidents'), plan.hasIncidents),
                _buildFeatureRow(Icons.file_download, loc.translate('subscription.export'), plan.hasExport),
                _buildFeatureRow(Icons.notifications, loc.translate('subscription.notifications'), plan.hasNotifications),
                _buildFeatureRow(Icons.business, loc.translate('subscription.multi_farm'), plan.hasMultiFarm),
                _buildFeatureRow(Icons.support_agent, loc.translate('subscription.priority_support'), plan.hasPrioritySupport),

                const SizedBox(height: 16),

                // Botão de acção
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: isCurrent
                        ? null
                        : () => _handlePlanSelection(plan, changeType, sub, loc),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCurrent
                          ? Colors.grey[300]
                          : changeType == 'downgrade'
                              ? Colors.orange.shade600
                              : AppConstants.primaryColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[200],
                      disabledForegroundColor: Colors.grey[500],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(
                      isCurrent
                          ? loc.translate('subscription.current')
                          : changeType == 'upgrade'
                              ? loc.translate('subscription.upgrade')
                              : changeType == 'downgrade'
                                  ? loc.translate('subscription.downgrade')
                                  : loc.translate('subscription.subscribe_btn'),
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text, bool included) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            included ? Icons.check_circle : Icons.cancel,
            size: 18,
            color: included ? AppConstants.accentColor : Colors.grey[300],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: included ? Colors.grey[800] : Colors.grey[400],
                decoration: included ? null : TextDecoration.lineThrough,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handlePlanSelection(
    SubscriptionPlan plan,
    String changeType,
    SubscriptionProvider sub,
    LocalizationProvider loc,
  ) {
    if (plan.isFree) {
      // Plano gratuito - confirmar downgrade
      _showConfirmDialog(plan, changeType, sub, loc);
    } else {
      // Plano pago - ir para ecrã de pagamento
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentScreen(
            plan: plan,
            billingCycle: _isAnnual ? 'annual' : 'monthly',
            changeType: changeType,
          ),
        ),
      );
    }
  }

  void _showConfirmDialog(
    SubscriptionPlan plan,
    String changeType,
    SubscriptionProvider sub,
    LocalizationProvider loc,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          changeType == 'downgrade'
              ? loc.translate('subscription.confirm_downgrade')
              : loc.translate('subscription.confirm_change'),
        ),
        content: Text(
          changeType == 'downgrade'
              ? loc.translate('subscription.downgrade_warning')
              : loc.translate('subscription.change_to_free'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(loc.translate('common.cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await sub.subscribe(plan.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(loc.translate('subscription.plan_changed')),
                    backgroundColor: AppConstants.successColor,
                  ),
                );
              } else if (sub.error != null && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(sub.error!), backgroundColor: AppConstants.errorColor),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: changeType == 'downgrade' ? Colors.orange : AppConstants.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text(loc.translate('common.confirm')),
          ),
        ],
      ),
    );
  }
}
