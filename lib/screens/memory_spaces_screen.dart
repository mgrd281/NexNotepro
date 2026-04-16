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
  MemorySpace? _selectedSpace;

  @override
  Widget build(BuildContext context) {
    return Consumer<NotesProvider>(
      builder: (context, provider, _) {
        final notes = _selectedSpace != null
            ? provider.notesForSpace(_selectedSpace!)
            : provider.filteredNotes;

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
                    Text('Memory Spaces', style: NexTypography.displayMedium),
                    const SizedBox(height: 4),
                    Text(
                      'Your organized thinking areas',
                      style: NexTypography.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Space grid
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  children: MemorySpace.values.map((space) {
                    final isActive = _selectedSpace == space;
                    final color = _spaceColor(space);
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          _selectedSpace = isActive ? null : space;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isActive ? color.withValues(alpha: 0.12) : NexColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isActive ? color.withValues(alpha: 0.4) : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: NexColors.cardShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(space.icon, style: const TextStyle(fontSize: 20)),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(space.label, style: NexTypography.titleMedium),
                                Text(
                                  '${provider.noteCountForSpace(space)} thoughts',
                                  style: NexTypography.caption,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Notes list
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  _selectedSpace != null ? '${_selectedSpace!.label} Notes' : 'All Notes',
                  style: NexTypography.headlineMedium,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            if (notes.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      _selectedSpace != null
                          ? 'No thoughts in ${_selectedSpace!.label} yet'
                          : 'No notes yet',
                      style: NexTypography.bodyMedium,
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList.separated(
                  itemCount: notes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) => NoteCard(
                    note: notes[i],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NoteDetailScreen(note: notes[i]),
                        ),
                      );
                    },
                    onLongPress: () => provider.togglePin(notes[i].id),
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        );
      },
    );
  }

  Color _spaceColor(MemorySpace space) => switch (space) {
    MemorySpace.work => NexColors.spaceWork,
    MemorySpace.personal => NexColors.spacePersonal,
    MemorySpace.ideasLab => NexColors.spaceIdeasLab,
    MemorySpace.lifeJournal => NexColors.spaceLifeJournal,
  };
}
