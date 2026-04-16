import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class NexBottomNav extends StatelessWidget {
  final int current;
  final ValueChanged<int> onTap;
  final VoidCallback onAdd;

  const NexBottomNav({
    super.key,
    required this.current,
    required this.onTap,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Nex.surface,
        border: const Border(top: BorderSide(color: Nex.border, width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              _Tab(icon: Icons.home_rounded, label: 'Home', active: current == 0, onTap: () => onTap(0)),
              _Tab(icon: Icons.timeline_rounded, label: 'Timeline', active: current == 1, onTap: () => onTap(1)),
              _CenterButton(onTap: onAdd),
              _Tab(icon: Icons.folder_rounded, label: 'Spaces', active: current == 2, onTap: () => onTap(2)),
              _Tab(icon: Icons.insights_rounded, label: 'Insights', active: current == 3, onTap: () => onTap(3)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _Tab({required this.icon, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: active ? Nex.primary : Nex.textMuted),
            const SizedBox(height: 2),
            Text(
              label,
              style: Nex.small.copyWith(
                color: active ? Nex.primary : Nex.textMuted,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CenterButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            onTap();
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Nex.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }
}
