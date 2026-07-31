import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'app_section.dart';

class AppNavigationBar extends StatelessWidget {
  const AppNavigationBar({
    required this.section,
    required this.compact,
    required this.onSectionChanged,
    required this.onOpenSettings,
    this.trailing,
    super.key,
  });

  final AppSection section;
  final bool compact;
  final ValueChanged<AppSection> onSectionChanged;
  final VoidCallback onOpenSettings;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.64),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white.withOpacity(.88)),
            boxShadow: [
              BoxShadow(
                color: AppColors.blueDark.withOpacity(.09),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  '30. Juli 2026',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
              Container(width: 1, height: 34, color: AppColors.line),
              const SizedBox(width: 14),
              _NavItem(
                icon: Icons.grid_view_rounded,
                label: 'Home',
                selected: section == AppSection.home,
                compact: compact,
                onTap: () => onSectionChanged(AppSection.home),
              ),
              const SizedBox(width: 6),
              _NavItem(
                icon: Icons.bolt_rounded,
                label: 'Energie',
                selected: section == AppSection.energy,
                compact: compact,
                onTap: () => onSectionChanged(AppSection.energy),
              ),
              const SizedBox(width: 6),
              _RoomsNavItem(
                section: section,
                compact: compact,
                onSectionChanged: onSectionChanged,
              ),
              const Spacer(),
              if (trailing != null) ...[trailing!, const SizedBox(width: 10)],
              Container(width: 1, height: 34, color: AppColors.line),
              const SizedBox(width: 10),
              IconButton(
                onPressed: onOpenSettings,
                tooltip: 'Home Assistant-Verbindung',
                icon: const Icon(Icons.settings_outlined),
                color: AppColors.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.compact,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(13),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: 56,
      padding: EdgeInsets.symmetric(horizontal: compact ? 14 : 17),
      decoration: BoxDecoration(
        color: selected ? AppColors.ink : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 22,
            color: selected ? Colors.white : AppColors.muted,
          ),
          if (!compact) ...[
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.muted,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

class _RoomSpec {
  const _RoomSpec(this.section, this.icon, this.label);
  final AppSection section;
  final IconData icon;
  final String label;
}

const _rooms = [
  _RoomSpec(AppSection.livingRoom, Icons.weekend_rounded, 'Wohnzimmer'),
  _RoomSpec(AppSection.bedroom, Icons.bedroom_parent_outlined, 'Schlafzimmer'),
  _RoomSpec(AppSection.kitchen, Icons.kitchen_outlined, 'Küche'),
  _RoomSpec(AppSection.bathroom, Icons.bathtub_outlined, 'Bad'),
  _RoomSpec(AppSection.hallway, Icons.door_front_door_outlined, 'Flur'),
];

class _RoomsNavItem extends StatefulWidget {
  const _RoomsNavItem({
    required this.section,
    required this.compact,
    required this.onSectionChanged,
  });

  final AppSection section;
  final bool compact;
  final ValueChanged<AppSection> onSectionChanged;

  @override
  State<_RoomsNavItem> createState() => _RoomsNavItemState();
}

class _RoomsNavItemState extends State<_RoomsNavItem> {
  final _overlayController = OverlayPortalController();
  final _link = LayerLink();

  bool get _isRoomSection =>
      _rooms.any((room) => room.section == widget.section);

  void _select(AppSection section) {
    widget.onSectionChanged(section);
    _overlayController.hide();
  }

  @override
  Widget build(BuildContext context) {
    final selected = _isRoomSection;
    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _overlayController,
        overlayChildBuilder: (context) => Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _overlayController.hide,
              ),
            ),
            CompositedTransformFollower(
              link: _link,
              showWhenUnlinked: false,
              offset: const Offset(0, 64),
              child: _RoomsDropdownPanel(
                current: widget.section,
                onSelect: _select,
              ),
            ),
          ],
        ),
        child: InkWell(
          onTap: _overlayController.toggle,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 56,
            padding: EdgeInsets.symmetric(horizontal: widget.compact ? 14 : 17),
            decoration: BoxDecoration(
              color: selected ? AppColors.ink : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.other_houses_rounded,
                  size: 22,
                  color: selected ? Colors.white : AppColors.muted,
                ),
                if (!widget.compact) ...[
                  const SizedBox(width: 10),
                  Text(
                    'Räume',
                    style: TextStyle(
                      color: selected ? Colors.white : AppColors.muted,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.expand_more_rounded,
                    size: 20,
                    color: selected ? Colors.white : AppColors.muted,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoomsDropdownPanel extends StatelessWidget {
  const _RoomsDropdownPanel({required this.current, required this.onSelect});

  final AppSection current;
  final ValueChanged<AppSection> onSelect;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Material(
        color: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              width: 240,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.88),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(.9)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blueDark.withOpacity(.12),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final room in _rooms)
                    _RoomsDropdownItem(
                      room: room,
                      selected: room.section == current,
                      onTap: () => onSelect(room.section),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoomsDropdownItem extends StatelessWidget {
  const _RoomsDropdownItem({
    required this.room,
    required this.selected,
    required this.onTap,
  });

  final _RoomSpec room;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(13),
    child: Container(
      width: double.infinity,
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: selected ? AppColors.ink : Colors.transparent,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          Icon(
            room.icon,
            size: 20,
            color: selected ? Colors.white : AppColors.muted,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              room.label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.ink,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
