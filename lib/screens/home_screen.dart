import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note_model.dart';
import '../providers/notes_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/note_card.dart';
import 'note_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotesProvider>(
      builder: (context, provider, _) {
        final pinned = provider.pinnedNotes;
        final recent = provider.filteredNotes;

        return ListView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 20, 20, 120),
          children: [
            // Header
            Text(_greeting(), style: Nex.label),
            const SizedBox(height: 4),
            Text('NexNote', style: Nex.display),

            const SizedBox(height: 20),

            // Search
            NexSearchBar(onChanged: (q) => provider.setSearchQuery(q)),

            const SizedBox(height: 28),

            // Memory Spaces (compact row)
            const SectionTitle(title: 'Spaces'),
            const SizedBox(height: 12),
            SizedBox(
              height: 72,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: MemorySpace.values.map((space) {
                  final count = provider.noteCountForSpace(space);
                  final isActive = provider.activeSpaceFilter == space;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => provider.setSpaceFilter(isActive ? null : space),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 120,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isActive ? Nex.primary.withValues(alpha: 0.08) : Nex.surface,
                          borderRadius: BorderRadius.circular(Nex.r12),
                          border: Border.all(
                            color: isActive ? Nex.primary.withValues(alpha: 0.3) : Nex.border,
                            width: 0.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(space.label, style: Nex.label.copyWith(
                              color: isActive ? Nex.primary : Nex.text,
                              fontWeight: FontWeight.w600,
                            )),
                            Text('$count notes', style: Nex.small),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Pinned
            if (pinned.isNotEmpty) ...[
              const SizedBox(height: 28),
              SectionTitle(title: 'Pinned', action: '${pinned.length}'),
              const SizedBox(height: 12),
              ...pinned.map((note) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: NoteCard(
                  note: note,
                  onTap: () => _open(context, note),
                  onLongPress: () => provider.togglePin(note.id),
                ),
              )),
            ],

            // Recent
            const SizedBox(height: 28),
            SectionTitle(title: 'Recent', action: '${recent.length}'),
            const SizedBox(height: 12),

            if (recent.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.edit_note_rounded, size: 40, color: Nex.textMuted),
                      const SizedBox(height: 12),
                      Text('No thoughts yet', style: Nex.h3.copyWith(color: Nex.textMuted)),
                      const SizedBox(height: 4),
                      Text('Tap + to start', style: Nex.caption),
                    ],
                  ),
                ),
              )
            else
              ...recent.map((note) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: NoteCard(
                  note: note,
                  onTap: () => _open(context, note),
                  onLongPress: () => provider.togglePin(note.id),
                ),
              )),
          ],
        );
      },
    );
  }

  void _open(BuildContext context, NexNote note) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => NoteDetailScreen(note: note)));
  }
}
