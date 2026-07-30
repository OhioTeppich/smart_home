import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../application/home_controller.dart';
import '../../domain/home_models.dart';
import 'home_card.dart';

class MarketsCard extends StatelessWidget {
  const MarketsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = HomeScope.of(context);
    return HomeCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HomeCardTitle(
            icon: Icons.show_chart_rounded,
            title: 'Märkte',
            trailing: 'Heute',
          ),
          const SizedBox(height: 18),
          ...controller.markets.map(
            (symbol) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _MarketRow(
                symbol: symbol,
                quote: controller.marketQuotes[symbol],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MarketRow extends StatelessWidget {
  const _MarketRow({required this.symbol, required this.quote});

  final MarketSymbol symbol;
  final MarketQuote? quote;

  @override
  Widget build(BuildContext context) {
    final positive = (quote?.changePercent ?? 0) >= 0;
    final color = _marketColor(symbol);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(.22)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 68,
            child: Row(
              children: [
                Text(
                  symbol.label,
                  style: TextStyle(color: color, fontWeight: FontWeight.w800),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: quote?.isLive == true ? AppColors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              quote == null ? '—' : _formatValue(quote!.price, 2),
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
          ),
          Text(
            quote == null
                ? 'Lädt …'
                : '${positive ? '+' : ''}${quote!.changePercent.toStringAsFixed(2)}%',
            style: TextStyle(
              color: positive ? AppColors.green : Colors.red,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatValue(double value, int decimals) {
  final parts = value.toStringAsFixed(decimals).split('.');
  final grouped = parts.first.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => '.',
  );
  return '$grouped,${parts[1]}';
}

Color _marketColor(MarketSymbol symbol) => switch (symbol) {
      MarketSymbol.nq => AppColors.blueDark,
      MarketSymbol.es => AppColors.brown,
      MarketSymbol.btc => const Color(0xFFE19A3E),
    };
