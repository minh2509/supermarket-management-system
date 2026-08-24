import 'package:flutter/material.dart';
import 'package:supermarket_manager_system/domain/models/discount.dart';

/// Teal header modal like cashier HTML — tap row to select (null = no discount).
Future<Discount?> showCashierDiscountSelectDialog(
  BuildContext context, {
  required List<Discount> applicableDiscounts,
}) {
  return showDialog<Discount?>(
    context: context,
    barrierColor: Colors.black54,
    builder: (dialogContext) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Material(
            borderRadius: BorderRadius.circular(12),
            clipBehavior: Clip.antiAlias,
            elevation: 12,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Select Discount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Material(
                        color: const Color.fromRGBO(255, 255, 255, 0.2),
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          onTap: () => Navigator.of(dialogContext).pop(),
                          borderRadius: BorderRadius.circular(8),
                          child: const SizedBox(
                            width: 36,
                            height: 36,
                            child: Center(
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 340),
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        _DiscountTile(
                          name: 'No discount',
                          percentLabel: '0%',
                          percentColor: const Color(0xFF6B7280),
                          onTap: () =>
                              Navigator.of(dialogContext).pop<Discount?>(null),
                        ),
                        ...applicableDiscounts.map(
                          (d) => _DiscountTile(
                            name: d.name,
                            percentLabel:
                                '${d.percent == d.percent.roundToDouble() ? d.percent.toStringAsFixed(0) : d.percent.toStringAsFixed(1)}%',
                            percentColor: const Color(0xFF2E7D32),
                            onTap: () =>
                                Navigator.of(dialogContext).pop<Discount?>(d),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _DiscountTile extends StatelessWidget {
  const _DiscountTile({
    required this.name,
    required this.percentLabel,
    required this.percentColor,
    required this.onTap,
  });

  final String name;
  final String percentLabel;
  final Color percentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        hoverColor: const Color(0xFFF0FDFA),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFE8EAED)),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1D21),
                    fontSize: 15,
                  ),
                ),
              ),
              Text(
                percentLabel,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: percentColor,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Active date range + minimum order amount (same calendar day, local).
bool isDiscountApplicableForOrder(Discount d, double orderTotal) {
  if (orderTotal < d.minOrderAmount) {
    return false;
  }
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final start = DateTime(d.startDate.year, d.startDate.month, d.startDate.day);
  final end = DateTime(d.endDate.year, d.endDate.month, d.endDate.day);
  return !today.isBefore(start) && !today.isAfter(end);
}
