import 'package:flutter/material.dart';

import '../widgets/home_overview.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 780;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        compact ? 24 : 44,
        32,
        compact ? 24 : 52,
        42,
      ),
      child: HomeOverview(compact: compact),
    );
  }
}
