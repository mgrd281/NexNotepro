import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note_model.dart';
import '../providers/notes_provider.dart';
import '../theme/app_theme.dart';
import 'note_detail_screen.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotesProvider>(
      builder: (context, provider, _) {
        final insights = provider.allInsights;
        final notes = provider.notes;

        // Stats
        final decisions = insights.where((i) => i.type == InsightType.decision).length;
        final ideas = insights.where((i) => i.type == InsightType.idea).length;
        final tasks = insights.where((i) => i.type == InsightType.task).length;
        final followUps = insights.where((i) => i.type == InsightType.followUp).length;

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
                    Text('Insight Engine', style: NexTypography.displayMedium),
                    const SizedBox(height: 4),
                    Text(
                      'Patterns from your thinking',
                      style: NexTypography.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Stats grid
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    _StatCard(emoji: '⚖️', label: 'Decisions', count: decisions, color: const Color(0xFF8B5CF6)),
                    const SizedBox(width: 12),
                    _StatCard(emoji: '💡', label: 'Ideas', count: ideas, color: NexColors.modeIdea),
                    const SizedBox(width: 12),
                    _StatCard(emoji: '☑️', label: 'Tasks', count: tasks, color: NexColors.modeTaskOriented),
                    const SizedBox(width: 12),
                    _StatCard(emoji: '🔄', label: 'Follow-ups', count: followUps, color: const Color(0xFF3B82F6)),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 28)),

            // Thinking overview
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        NexColors.primary.withValues(alpha: 0.08),
                        NexColors.accent.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome_rounded, color: NexColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Text('Thinking Overview', style: NexTypography.titleLarge.copyWith(color: NexColors.primary)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _generateOverview(notes, insights),
                        style: NexTypography.bodyMedium.copyWith(
                          color: NexColors.textPrimary,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Insights list
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text('Detected Insights', style: NexTypography.headlineMedium),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            if (insights.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        const Text('🔍', style: TextStyle(fontSize: 40)),
                        const SizedBox(height: 12),
                        Text('No insights yet', style: NexTypography.headlineMedium),
                        const SizedBox(height: 8),
                        Text(
                          'Write more notes and I\'ll find patterns',
                          style: NexTypography.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverList.separated(
                  itemCount: insights.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final insight = insights[i];
                    final relatedNote = notes.where((n) => n.id == insight.noteId).firstOrNull;
                    return GestureDetector(
                      onTap: () {
                        if (relatedNote != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => NoteDetailScreen(note: relatedNote),
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: NexColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: NexColors.cardShadow,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: NexColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(insight.type.emoji, style: const TextStyle(fontSize: 18)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(insight.type.label, style: NexTypography.titleMedium),
                                  const SizedBox(height: 2),
                                  Text(
                                    relatedNote?.title ?? insight.content,
                                    style: NexTypography.bodySmall,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded, color: NexColors.textTertiary, size: 20),
                          ],
                        ),
                      ),
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

  String _generateOverview(List<NexNote> notes, List<Insight> insights) {
    if (notes.isEmpty) return 'Start capturing thoughts to see your thinking patterns here.';

    final buffer = StringBuffer();
    buffer.write('You have ${notes.length} thought${notes.length == 1 ? '' : 's'} across your spaces. ');

    final modeCount = <ThoughtMode, int>{};
    for (final n in notes) {
      modeCount[n.mode] = (modeCount[n.mode] ?? 0) + 1;
    }
    final topMode = modeCount.entries.reduce((a, b) => a.value >= b.value ? a : b);
    buffer.write('Most of your thinking is in ${topMode.key.label} mode ${topMode.key.emoji}. ');

    if (insights.isNotEmpty) {
      buffer.write('${insights.length} insight${insights.length == 1 ? '' : 's'} detected from your notes.');
    }

    return buffer.toString();
  }
}

class _StatCard extends StatelessWidget {
  final String emoji;
  final String label;
  final int count;
  final Color color;

  const _StatCard({
    required this.emoji,
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: NexColors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          boxShadow: NexColors.cardShadow,
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 6),
            Text(
              '$count',
              style: NexTypography.headlineLarge.copyWith(
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: NexTypography.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
