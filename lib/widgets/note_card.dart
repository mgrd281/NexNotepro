import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/note_model.dart';
import '../theme/app_theme.dart';

class NoteCard extends StatelessWidget {
  final NexNote note;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    this.onLongPress,
  });

  Color get _modeAccent => switch (note.mode) {
    ThoughtMode.idea => NexColors.modeIdea,
    ThoughtMode.deepThinking => NexColors.modeDeepThinking,
    ThoughtMode.quickCapture => NexColors.modeQuickCapture,
    ThoughtMode.reflection => NexColors.modeReflection,
    ThoughtMode.taskOriented => NexColors.modeTaskOriented,
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      onLongPress: () {
        HapticFeedback.mediumImpact();
        onLongPress?.call();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: NexColors.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
          boxShadow: NexColors.cardShadow,
          border: Border(
            left: BorderSide(color: _modeAccent, width: 3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: mode badge + pin
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _modeAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${note.mode.emoji} ${note.mode.label}',
                    style: NexTypography.caption.copyWith(
                      color: _modeAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (note.emotionalTag != null) ...[
                  const SizedBox(width: 8),
                  Text(note.emotionalTag!.emoji, style: const TextStyle(fontSize: 14)),
                ],
                const Spacer(),
                if (note.isPinned)
                  Icon(Icons.push_pin_rounded, size: 16, color: NexColors.primary.withValues(alpha: 0.6)),
              ],
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              note.title,
              style: NexTypography.titleLarge,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            if (note.content.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                note.preview,
                style: NexTypography.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            // Tags
            if (note.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: note.tags.take(3).map((tag) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: NexColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '#$tag',
                    style: NexTypography.caption.copyWith(
                      color: NexColors.textSecondary,
                    ),
                  ),
                )).toList(),
              ),
            ],

            // Bottom: space + time
            const SizedBox(height: 12),
            Row(
              children: [
                Text(note.space.icon, style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 4),
                Text(
                  note.space.label,
                  style: NexTypography.caption,
                ),
                const Spacer(),
                Text(
                  _formatTime(note.updatedAt),
                  style: NexTypography.caption,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
