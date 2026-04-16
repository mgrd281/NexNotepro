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
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotesProvider>(
      builder: (context, provider, _) {
        final pinnedNotes = provider.pinnedNotes;
        final recentNotes = provider.filteredNotes;

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Top safe area
            SliverToBoxAdapter(child: SizedBox(height: MediaQuery.of(context).padding.top + 16)),

            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting(),
                      style: NexTypography.bodyMedium.copyWith(
                        color: NexColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const GradientLogo(fontSize: 32),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Search
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SearchField(
                  onChanged: (q) => provider.setSearchQuery(q),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // Memory Spaces
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 24, right: 24, bottom: 16),
                child: const SectionHeader(title: 'Memory Spaces'),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 140,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    _SpaceCardBuilder(space: MemorySpace.work, color: NexColors.spaceWork, provider: provider),
                    const SizedBox(width: 12),
                    _SpaceCardBuilder(space: MemorySpace.personal, color: NexColors.spacePersonal, provider: provider),
                    const SizedBox(width: 12),
                    _SpaceCardBuilder(space: MemorySpace.ideasLab, color: NexColors.spaceIdeasLab, provider: provider),
                    const SizedBox(width: 12),
                    _SpaceCardBuilder(space: MemorySpace.lifeJournal, color: NexColors.spaceLifeJournal, provider: provider),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Pinned Thoughts
            if (pinnedNotes.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SectionHeader(
                    title: 'Pinned Thoughts',
                    trailing: '${pinnedNotes.length}',
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 180,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: pinnedNotes.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, i) => SizedBox(
                      width: MediaQuery.of(context).size.width * 0.78,
                      child: NoteCard(
                        note: pinnedNotes[i],
                        onTap: () => _openNote(context, pinnedNotes[i]),
                        onLongPress: () => provider.togglePin(pinnedNotes[i].id),
                      ),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],

            // Recent Thoughts
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SectionHeader(
                  title: 'Recent Thoughts',
                  trailing: '${recentNotes.length} notes',
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            if (recentNotes.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(48),
                  child: Column(
                    children: [
                      const Text('🧘', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 16),
                      Text(
                        'Your mind is clear',
                        style: NexTypography.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap + to capture your first thought',
                        style: NexTypography.bodyMedium,
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList.separated(
                  itemCount: recentNotes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) => NoteCard(
                    note: recentNotes[i],
                    onTap: () => _openNote(context, recentNotes[i]),
                    onLongPress: () => provider.togglePin(recentNotes[i].id),
                  ),
                ),
              ),

            // Bottom padding for nav bar
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        );
      },
    );
  }

  void _openNote(BuildContext context, NexNote note) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NoteDetailScreen(note: note)),
    );
  }
}

class _SpaceCardBuilder extends StatelessWidget {
  final MemorySpace space;
  final Color color;
  final NotesProvider provider;

  const _SpaceCardBuilder({
    required this.space,
    required this.color,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return MemorySpaceCard(
      emoji: space.icon,
      label: space.label,
      count: provider.noteCountForSpace(space),
      color: color,
      onTap: () => provider.setSpaceFilter(
        provider.activeSpaceFilter == space ? null : space,
      ),
    );
  }
}
