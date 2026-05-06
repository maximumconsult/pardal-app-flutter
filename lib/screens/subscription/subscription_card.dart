import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/subscription_provider.dart';
import '../../providers/localization_provider.dart';
import '../../utils/constants.dart';

class SubscriptionCard extends StatefulWidget {
  const SubscriptionCard({super.key});

  @override
  State<SubscriptionCard> createState() => _SubscriptionCardState();
}

class _SubscriptionCardState extends State<SubscriptionCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubscriptionProvider>().loadCurrentSubscription();
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<LocalizationProvider>();

    return Consumer<SubscriptionProvider>(
      builder: (_, sub, __) {
        final plan = sub.currentPlan;

        return Container(
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
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppConstants.accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.workspace_premium, color: AppConstants.accentColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          loc.translate('subscription.manage_subscription'),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        if (plan != null)
                          Text(
                            '${loc.translate('subscription.your_plan')}: ${plan.name}',
                            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                          ),
                      ],
                    ),
                  ),
                  if (sub.subscriptionStatus == 'active')
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppConstants.accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        loc.translate('subscription.active'),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppConstants.accentColor),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              if (plan != null) ...[
                // Info do plano actual
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppConstants.backgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(plan.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                            const SizedBox(height: 2),
                            Text(
                              plan.isFree ? 'Grátis' : '${plan.formattedMonthlyPrice}/mês',
                              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${plan.maxBatches} lotes • ${plan.maxUsers} users',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Botão ver planos
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/plans'),
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: Text(loc.translate('subscription.view_plans')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppConstants.primaryColor,
                    side: const BorderSide(color: AppConstants.primaryColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
