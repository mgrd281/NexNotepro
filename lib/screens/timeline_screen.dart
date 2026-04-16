import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/note_model.dart';
import '../providers/notes_provider.dart';
import '../theme/app_theme.dart';
import 'note_detail_screen.dart';

class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotesProvider>(
      builder: (context, provider, _) {
        final notes = provider.timelineNotes;

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: SizedBox(height: MediaQuery.of(context).padding.top + 16)),

            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Timeline', style: NexTypography.displayMedium),
                    const SizedBox(height: 4),
                    Text(
                      'Your thinking journey',
                      style: NexTypography.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            if (notes.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(48),
                  child: Column(
                    children: [
                      const Text('🕐', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 16),
                      Text('No thoughts yet', style: NexTypography.headlineMedium),
                      const SizedBox(height: 8),
                      Text('Your timeline will grow as you think', style: NexTypography.bodyMedium),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, i) {
                    final note = notes[i];
                    final showDateHeader = i == 0 ||
                        !_isSameDay(notes[i - 1].createdAt, note.createdAt);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showDateHeader)
                          Padding(
                            padding: const EdgeInsets.only(top: 16, bottom: 12),
                            child: Text(
                              _formatDateHeader(note.createdAt),
                              style: NexTypography.labelLarge.copyWith(
                                color: NexColors.primary,
                              ),
                            ),
                          ),
                        _TimelineItem(
                          note: note,
                          isLast: i == notes.length - 1,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => NoteDetailScreen(note: note),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        );
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _formatDateHeader(DateTime dt) {
    final now = DateTime.now();
    if (_isSameDay(dt, now)) return 'Today';
    if (_isSameDay(dt, now.subtract(const Duration(days: 1)))) return 'Yesterday';
    return DateFormat('EEEE, MMM d').format(dt);
  }
}

class _TimelineItem extends StatelessWidget {
  final NexNote note;
  final bool isLast;
  final VoidCallback onTap;

  const _TimelineItem({
    required this.note,
    required this.isLast,
    required this.onTap,
  });

  Color get _modeColor => switch (note.mode) {
    ThoughtMode.idea => NexColors.modeIdea,
    ThoughtMode.deepThinking => NexColors.modeDeepThinking,
    ThoughtMode.quickCapture => NexColors.modeQuickCapture,
    ThoughtMode.reflection => NexColors.modeReflection,
    ThoughtMode.taskOriented => NexColors.modeTaskOriented,
  };

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line + dot
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _modeColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _modeColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: NexColors.surfaceSubtle,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GestureDetector(
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: NexColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: NexColors.cardShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(note.mode.emoji, style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              note.title,
                              style: NexTypography.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            DateFormat('HH:mm').format(note.createdAt),
                            style: NexTypography.caption,
                          ),
                        ],
                      ),
                      if (note.content.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          note.preview,
                          style: NexTypography.bodySmall.copyWith(
                            color: NexColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (note.insights.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          children: note.insights.map((insight) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: NexColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${insight.type.emoji} ${insight.type.label}',
                              style: NexTypography.caption.copyWith(
                                color: NexColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
