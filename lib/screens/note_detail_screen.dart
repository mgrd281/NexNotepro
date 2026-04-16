import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/note_model.dart';
import '../providers/notes_provider.dart';
import '../theme/app_theme.dart';
import 'add_note_screen.dart';

class NoteDetailScreen extends StatelessWidget {
  final NexNote note;
  const NoteDetailScreen({super.key, required this.note});

  Color _modeColor(ThoughtMode m) => switch (m) {
    ThoughtMode.idea => Nex.amber,
    ThoughtMode.deepThinking => Nex.violet,
    ThoughtMode.quickCapture => Nex.cyan,
    ThoughtMode.reflection => Nex.blue,
    ThoughtMode.taskOriented => Nex.green,
  };

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotesProvider>();
    // Get fresh note from provider
    final current = provider.notes.where((n) => n.id == note.id).firstOrNull ?? note;

    return Scaffold(
      backgroundColor: Nex.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 12, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded, size: 22),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      provider.togglePin(current.id);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        current.isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                        size: 20,
                        color: current.isPinned ? Nex.primary : Nex.textSub,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => AddNoteScreen(existingNote: current))),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(Icons.edit_rounded, size: 20, color: Nex.textSub),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _confirmDelete(context, provider, current),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(Icons.delete_outline_rounded, size: 20, color: Nex.red),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                children: [
                  // Mode + Space badges
                  Row(
                    children: [
                      Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(color: _modeColor(current.mode), shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Text(current.mode.label, style: Nex.label.copyWith(color: _modeColor(current.mode))),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Nex.surfaceDim,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(current.space.label, style: Nex.small),
                      ),
                      if (current.emotionalTag != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Nex.surfaceDim,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(current.emotionalTag!.label, style: Nex.small),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Title
                  Text(current.title, style: Nex.display),

                  const SizedBox(height: 8),

                  // Timestamp
                  Text(
                    'Created ${DateFormat('MMM d, yyyy · HH:mm').format(current.createdAt)}',
                    style: Nex.caption,
                  ),

                  const SizedBox(height: 24),

                  // Content
                  SelectableText(current.content, style: Nex.body.copyWith(height: 1.65)),

                  // Checklist
                  if (current.checklist.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text('Checklist', style: Nex.h3),
                    const SizedBox(height: 10),
                    ...current.checklist.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 20, height: 20,
                            decoration: BoxDecoration(
                              color: item.isCompleted ? Nex.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: item.isCompleted ? Nex.primary : Nex.border, width: 1.5),
                            ),
                            child: item.isCompleted ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              item.text,
                              style: Nex.body.copyWith(
                                decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                                color: item.isCompleted ? Nex.textMuted : Nex.text,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],

                  // Tags
                  if (current.tags.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 6, runSpacing: 6,
                      children: current.tags.map((t) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Nex.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('#$t', style: Nex.label.copyWith(color: Nex.primary)),
                      )).toList(),
                    ),
                  ],

                  // AI Summary
                  if (current.layers.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text('Layers', style: Nex.h3),
                    const SizedBox(height: 10),
                    ...current.layers.map((layer) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Nex.surfaceDim,
                        borderRadius: BorderRadius.circular(Nex.r8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(layer.type.name.toUpperCase(), style: Nex.small.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(layer.content, style: Nex.bodySub),
                        ],
                      ),
                    )),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, NotesProvider provider, NexNote n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete note?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () { provider.deleteNote(n.id); Navigator.pop(ctx); Navigator.pop(context); },
            child: Text('Delete', style: TextStyle(color: Nex.red)),
          ),
        ],
      ),
    );
  }
}
