import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
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
        final notes = List<NexNote>.from(provider.notes)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        // Group by day
        final Map<String, List<NexNote>> grouped = {};
        for (final note in notes) {
          final key = DateFormat('EEEE, MMM d').format(note.createdAt);
          (grouped[key] ??= []).add(note);
        }

        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 20, 20, 120),
          children: [
            Text('Timeline', style: Nex.display),
            const SizedBox(height: 4),
            Text('${notes.length} thoughts', style: Nex.caption),
            const SizedBox(height: 28),

            if (notes.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.timeline_rounded, size: 40, color: Nex.textMuted),
                      const SizedBox(height: 12),
                      Text('Your timeline is empty', style: Nex.h3.copyWith(color: Nex.textMuted)),
                    ],
                  ),
                ),
              )
            else
              ...grouped.entries.expand((entry) => [
                // Day header
                Padding(
                  padding: const EdgeInsets.only(bottom: 12, top: 8),
                  child: Text(entry.key, style: Nex.label.copyWith(fontWeight: FontWeight.w600)),
                ),
                // Notes for this day
                ...entry.value.map((note) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: _TimelineItem(
                    note: note,
                    onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => NoteDetailScreen(note: note))),
                  ),
                )),
              ]),
          ],
        );
      },
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final NexNote note;
  final VoidCallback onTap;

  const _TimelineItem({required this.note, required this.onTap});

  Color get _color => switch (note.mode) {
    ThoughtMode.idea => Nex.amber,
    ThoughtMode.deepThinking => Nex.violet,
    ThoughtMode.quickCapture => Nex.cyan,
    ThoughtMode.reflection => Nex.blue,
    ThoughtMode.taskOriented => Nex.green,
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Timeline rail
            SizedBox(
              width: 28,
              child: Column(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: 1.5,
                      color: Nex.border,
                    ),
                  ),
                ],
              ),
            ),

            // Card content
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Nex.surface,
                  borderRadius: BorderRadius.circular(Nex.r12),
                  border: Border.all(color: Nex.border, width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(note.title, style: Nex.h3, maxLines: 1, overflow: TextOverflow.ellipsis)),
                        Text(DateFormat('HH:mm').format(note.createdAt), style: Nex.small),
                      ],
                    ),
                    if (note.content.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(note.preview, style: Nex.bodySub, maxLines: 2, overflow: TextOverflow.ellipsis),
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
}
