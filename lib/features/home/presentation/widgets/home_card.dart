import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class HomeCardTitle extends StatelessWidget {
  const HomeCardTitle({
    required this.icon,
    required this.title,
    required this.trailing,
    super.key,
  });

  final IconData icon;
  final String title;
  final String trailing;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Icon(icon, size: 18, color: AppColors.blueDark),
          const SizedBox(width: 8),
          Expanded(
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
          Text(
            trailing,
            style: const TextStyle(fontSize: 11, color: AppColors.muted),
          ),
        ],
      );
}

class HomeCard extends StatelessWidget {
  const HomeCard({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.57),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(.78)),
          boxShadow: [
            BoxShadow(
              color: AppColors.blueDark.withOpacity(.055),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: child,
      );
}
