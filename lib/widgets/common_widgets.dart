import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class GradientLogo extends StatelessWidget {
  final double fontSize;

  const GradientLogo({super.key, this.fontSize = 28});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => NexColors.logoGradient.createShader(bounds),
      child: Text(
        'NexNote',
        style: NexTypography.logo.copyWith(
          fontSize: fontSize,
          color: Colors.white,
        ),
      ),
    );
  }
}

class SearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final String hintText;

  const SearchField({
    super.key,
    required this.onChanged,
    this.hintText = 'Search your thoughts…',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: NexColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        onChanged: onChanged,
        style: NexTypography.bodyMedium.copyWith(color: NexColors.textPrimary),
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: const Icon(Icons.search_rounded, color: NexColors.textTertiary, size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? trailing;
  final VoidCallback? onTrailingTap;

  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.onTrailingTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: NexTypography.headlineMedium),
        if (trailing != null)
          GestureDetector(
            onTap: onTrailingTap,
            child: Text(
              trailing!,
              style: NexTypography.labelMedium.copyWith(color: NexColors.primary),
            ),
          ),
      ],
    );
  }
}

class ChipSelector<T> extends StatelessWidget {
  final List<T> items;
  final T? selected;
  final String Function(T) labelBuilder;
  final String Function(T)? emojiBuilder;
  final Color Function(T)? colorBuilder;
  final ValueChanged<T> onSelected;

  const ChipSelector({
    super.key,
    required this.items,
    required this.selected,
    required this.labelBuilder,
    this.emojiBuilder,
    this.colorBuilder,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: items.map((item) {
          final isSelected = item == selected;
          final color = colorBuilder?.call(item) ?? NexColors.primary;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                onSelected(item);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? color.withValues(alpha: 0.15) : NexColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? color.withValues(alpha: 0.4) : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (emojiBuilder != null) ...[
                      Text(emojiBuilder!(item), style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      labelBuilder(item),
                      style: NexTypography.labelMedium.copyWith(
                        color: isSelected ? color : NexColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class MemorySpaceCard extends StatelessWidget {
  final String emoji;
  final String label;
  final int count;
  final Color color;
  final VoidCallback onTap;

  const MemorySpaceCard({
    super.key,
    required this.emoji,
    required this.label,
    required this.count,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: NexColors.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
          boxShadow: NexColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(height: 12),
            Text(label, style: NexTypography.titleMedium),
            const SizedBox(height: 4),
            Text(
              '$count notes',
              style: NexTypography.caption,
            ),
          ],
        ),
      ),
    );
  }
}
