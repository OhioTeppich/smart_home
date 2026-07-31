import 'package:flutter/material.dart';

/// Shared page-content shell that replaces the vertical
/// `SingleChildScrollView(padding: ...)` boilerplate previously duplicated
/// across every top-level page. Lays [sections] out horizontally instead of
/// stacking them in a vertical `Column`.
class HorizontalPageScaffold extends StatelessWidget {
  const HorizontalPageScaffold({required this.sections, this.snap = true, super.key});

  /// The panels to lay out. A single section falls back to a plain vertical
  /// scroll (nothing to swipe/scroll to horizontally).
  final List<Widget> sections;

  /// `true`: panels snap one-at-a-time like a page (for clearly separate
  /// sections). `false`: free horizontal scroll, several panels can be
  /// partially visible at once (for a couple of loosely related cards).
  final bool snap;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxWidth < 780;
      final padding = EdgeInsets.fromLTRB(
        compact ? 24 : 44,
        32,
        compact ? 24 : 52,
        42,
      );

      if (sections.length == 1) {
        return SingleChildScrollView(padding: padding, child: sections.single);
      }

      if (snap) {
        return Padding(
          padding: padding,
          child: PageView(children: sections),
        );
      }

      final panelWidth = constraints.maxWidth - padding.horizontal;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: padding,
        physics: const BouncingScrollPhysics(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final section in sections) ...[
              SizedBox(width: panelWidth, child: section),
              const SizedBox(width: 18),
            ],
          ],
        ),
      );
    },
  );
}
