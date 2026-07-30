import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/energy_point.dart';

class EnergyPeriodSelector extends StatelessWidget {
  const EnergyPeriodSelector({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final Period value;
  final ValueChanged<Period> onChanged;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(4),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: Period.values.map((item) {
        final selected = item == value;
        return GestureDetector(
          onTap: () => onChanged(item),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? AppColors.ink : Colors.transparent,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              _label(item),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : AppColors.muted,
              ),
            ),
          ),
        );
      }).toList(),
    ),
  );

  String _label(Period value) => switch (value) {
    Period.day => 'Tag',
    Period.week => 'Woche',
    Period.month => 'Monat',
  };
}
