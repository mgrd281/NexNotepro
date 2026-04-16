import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/note_model.dart';
import '../providers/notes_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/note_card.dart';
import 'note_detail_screen.dart';

class MemorySpacesScreen extends StatefulWidget {
  const MemorySpacesScreen({super.key});

  @override
  State<MemorySpacesScreen> createState() => _MemorySpacesScreenState();
}

class _MemorySpacesScreenState extends State<MemorySpacesScreen> {
  MemorySpace? _selected;

  IconData _icon(MemorySpace s) => switch (s) {
    MemorySpace.personal => Icons.person_rounded,
    MemorySpace.work => Icons.work_rounded,
    MemorySpace.ideasLab => Icons.palette_rounded,
    MemorySpace.lifeJournal => Icons.auto_stories_rounded,
  };

  Color _color(MemorySpace s) => switch (s) {
    MemorySpace.personal => Nex.blue,
    MemorySpace.work => Nex.green,
    MemorySpace.ideasLab => Nex.violet,
    MemorySpace.lifeJournal => Nex.amber,
  };

  @override
  Widget build(BuildContext context) {
    return Consumer<NotesProvider>(
      builder: (context, provider, _) {
        final notes = _selected != null
            ? provider.notes.where((n) => n.space == _selected).toList()
            : <NexNote>[];

        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 20, 20, 120),
          children: [
            Text('Spaces', style: Nex.display),
            const SizedBox(height: 4),
            Text('Organize your thinking', style: Nex.caption),
            const SizedBox(height: 24),

            // Grid of spaces
            GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.6,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: MemorySpace.values.map((space) {
                final count = provider.noteCountForSpace(space);
                final isActive = _selected == space;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selected = isActive ? null : space);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isActive ? _color(space).withValues(alpha: 0.08) : Nex.surface,
                      borderRadius: BorderRadius.circular(Nex.r12),
                      border: Border.all(
                        color: isActive ? _color(space).withValues(alpha: 0.3) : Nex.border,
                        width: 0.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(_icon(space), size: 22, color: _color(space)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(space.label, style: Nex.label.copyWith(fontWeight: FontWeight.w600)),
                            Text('$count notes', style: Nex.small),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            // Notes for selected space
            if (_selected != null) ...[
              const SizedBox(height: 28),
              Text('${_selected!.label} notes', style: Nex.h3),
              const SizedBox(height: 12),
              if (notes.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text('No notes in this space yet', style: Nex.bodySub),
                )
              else
                ...notes.map((note) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: NoteCard(
                    note: note,
                    onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => NoteDetailScreen(note: note))),
                  ),
                )),
            ],
          ],
        );
      },
    );
  }
}
