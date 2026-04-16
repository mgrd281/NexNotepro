import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/note_model.dart';
import '../theme/app_theme.dart';

class NoteCard extends StatelessWidget {
  final NexNote note;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const NoteCard({super.key, required this.note, required this.onTap, this.onLongPress});

  Color get _modeColor => switch (note.mode) {
    ThoughtMode.idea => Nex.amber,
    ThoughtMode.deepThinking => Nex.violet,
    ThoughtMode.quickCapture => Nex.cyan,
    ThoughtMode.reflection => Nex.blue,
    ThoughtMode.taskOriented => Nex.green,
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () { HapticFeedback.lightImpact(); onTap(); },
      onLongPress: () { HapticFeedback.mediumImpact(); onLongPress?.call(); },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Nex.surface,
          borderRadius: BorderRadius.circular(Nex.r12),
          border: Border.all(color: Nex.border, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: mode dot + title + pin
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: _modeColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    note.title,
                    style: Nex.h3,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (note.isPinned)
                  Icon(Icons.push_pin_rounded, size: 14, color: Nex.textMuted),
              ],
            ),

            // Preview
            if (note.content.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                note.preview,
                style: Nex.bodySub,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            // Footer: space + time
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Nex.surfaceDim,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(note.space.label, style: Nex.small),
                ),
                if (note.tags.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Text('#${note.tags.first}', style: Nex.small.copyWith(color: Nex.primary)),
                ],
                const Spacer(),
                Text(_timeAgo(note.updatedAt), style: Nex.small),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${dt.day}/${dt.month}';
  }
}
