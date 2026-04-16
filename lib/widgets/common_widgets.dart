import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class NexSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const NexSearchBar({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Nex.surfaceDim,
        borderRadius: BorderRadius.circular(Nex.r12),
      ),
      child: TextField(
        onChanged: onChanged,
        style: Nex.body,
        decoration: InputDecoration(
          hintText: 'Search…',
          hintStyle: Nex.body.copyWith(color: Nex.textMuted),
          prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Nex.textMuted),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionTitle({super.key, required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Nex.h3),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(action!, style: Nex.label.copyWith(color: Nex.primary)),
          ),
      ],
    );
  }
}

class ModeChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const ModeChip({
    super.key,
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () { HapticFeedback.selectionClick(); onTap(); },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : Nex.surfaceDim,
          borderRadius: BorderRadius.circular(Nex.r8),
          border: Border.all(
            color: selected ? color.withValues(alpha: 0.3) : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: Nex.label.copyWith(
            color: selected ? color : Nex.textSub,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
