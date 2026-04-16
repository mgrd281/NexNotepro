import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/note_model.dart';
import '../providers/notes_provider.dart';
import '../theme/app_theme.dart';
import 'add_note_screen.dart';

class NoteDetailScreen extends StatelessWidget {
  final NexNote note;

  const NoteDetailScreen({super.key, required this.note});

  Color get _modeColor => switch (note.mode) {
    ThoughtMode.idea => NexColors.modeIdea,
    ThoughtMode.deepThinking => NexColors.modeDeepThinking,
    ThoughtMode.quickCapture => NexColors.modeQuickCapture,
    ThoughtMode.reflection => NexColors.modeReflection,
    ThoughtMode.taskOriented => NexColors.modeTaskOriented,
  };

  Color get _moodTint {
    if (note.emotionalTag == null) return NexColors.background;
    return switch (note.emotionalTag!) {
      EmotionalTag.stressed => NexColors.moodStressed.withValues(alpha: 0.03),
      EmotionalTag.inspired => NexColors.moodInspired.withValues(alpha: 0.03),
      EmotionalTag.focused => NexColors.moodFocused.withValues(alpha: 0.03),
      EmotionalTag.confused => NexColors.moodConfused.withValues(alpha: 0.03),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _moodTint,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      context.read<NotesProvider>().togglePin(note.id);
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      note.isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                      size: 20,
                      color: note.isPinned ? NexColors.primary : NexColors.textSecondary,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddNoteScreen(existingNote: note),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit_rounded, size: 20),
                  ),
                  IconButton(
                    onPressed: () => _confirmDelete(context),
                    icon: Icon(Icons.delete_outline_rounded, size: 20, color: NexColors.moodStressed.withValues(alpha: 0.7)),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mode + mood badges
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _modeColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${note.mode.emoji} ${note.mode.label}',
                            style: NexTypography.labelMedium.copyWith(
                              color: _modeColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (note.emotionalTag != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: NexColors.surfaceSubtle,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${note.emotionalTag!.emoji} ${note.emotionalTag!.label}',
                              style: NexTypography.labelMedium,
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Title
                    Text(note.title, style: NexTypography.displayMedium),

                    const SizedBox(height: 8),

                    // Meta
                    Row(
                      children: [
                        Text(note.space.icon, style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(note.space.label, style: NexTypography.bodySmall),
                        const SizedBox(width: 16),
                        Icon(Icons.access_time_rounded, size: 14, color: NexColors.textTertiary),
                        const SizedBox(width: 4),
                        Text(
                          _formatDateTime(note.createdAt),
                          style: NexTypography.bodySmall,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Content
                    if (note.content.isNotEmpty)
                      Text(
                        note.content,
                        style: NexTypography.bodyLarge.copyWith(
                          color: NexColors.textPrimary,
                          height: 1.7,
                        ),
                      ),

                    // Checklist
                    if (note.checklist.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: NexColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: NexColors.cardShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Checklist', style: NexTypography.titleMedium),
                            const SizedBox(height: 12),
                            ...note.checklist.map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: item.isCompleted ? NexColors.modeTaskOriented : Colors.transparent,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: item.isCompleted ? NexColors.modeTaskOriented : NexColors.textTertiary,
                                        width: 2,
                                      ),
                                    ),
                                    child: item.isCompleted
                                        ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                                        : null,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    item.text,
                                    style: NexTypography.bodyMedium.copyWith(
                                      color: NexColors.textPrimary,
                                      decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                          ],
                        ),
                      ),
                    ],

                    // Tags
                    if (note.tags.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: note.tags.map((tag) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: NexColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '#$tag',
                            style: NexTypography.labelMedium.copyWith(color: NexColors.primary),
                          ),
                        )).toList(),
                      ),
                    ],

                    // Insights
                    if (note.insights.isNotEmpty) ...[
                      const SizedBox(height: 28),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              NexColors.primary.withValues(alpha: 0.06),
                              NexColors.accent.withValues(alpha: 0.03),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.auto_awesome_rounded, size: 16, color: NexColors.primary),
                                const SizedBox(width: 6),
                                Text(
                                  'Detected Insights',
                                  style: NexTypography.titleMedium.copyWith(color: NexColors.primary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ...note.insights.map((insight) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Text(insight.type.emoji, style: const TextStyle(fontSize: 16)),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${insight.type.label}: ${insight.content}',
                                    style: NexTypography.bodyMedium.copyWith(color: NexColors.textPrimary),
                                  ),
                                ],
                              ),
                            )),
                          ],
                        ),
                      ),
                    ],

                    // Mind Layers
                    if (note.layers.isNotEmpty) ...[
                      const SizedBox(height: 28),
                      Text('Mind Layers', style: NexTypography.headlineMedium),
                      const SizedBox(height: 12),
                      ...note.layers.map((layer) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: NexColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: NexColors.cardShadow,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: NexColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                layer.type.label,
                                style: NexTypography.caption.copyWith(
                                  color: NexColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                layer.content,
                                style: NexTypography.bodyMedium.copyWith(color: NexColors.textPrimary),
                              ),
                            ),
                          ],
                        ),
                      )),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: NexColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: NexColors.textTertiary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text('🗑️', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 16),
            Text('Delete this thought?', style: NexTypography.headlineLarge),
            const SizedBox(height: 8),
            Text('This action cannot be undone', style: NexTypography.bodyMedium),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: NexColors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text('Keep', style: NexTypography.titleMedium),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      context.read<NotesProvider>().deleteNote(note.id);
                      Navigator.pop(ctx);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: NexColors.moodStressed,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          'Delete',
                          style: NexTypography.titleMedium.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year} · ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
