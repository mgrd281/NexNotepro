import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note_model.dart';
import '../providers/notes_provider.dart';
import '../theme/app_theme.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<NotesProvider>(
      builder: (context, provider, _) {
        final notes = provider.notes;
        final total = notes.length;
        final thisWeek = notes.where((n) =>
          DateTime.now().difference(n.createdAt).inDays < 7).length;
        final withTasks = notes.where((n) => n.checklist.isNotEmpty).length;
        final tasksCompleted = notes.expand((n) => n.checklist).where((c) => c.isCompleted).length;
        final tasksTotal = notes.expand((n) => n.checklist).length;
        final insights = provider.allInsights;

        // Mode distribution
        final modeCounts = <ThoughtMode, int>{};
        for (final n in notes) modeCounts[n.mode] = (modeCounts[n.mode] ?? 0) + 1;

        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 20, 20, 120),
          children: [
            Text('Insights', style: Nex.display),
            const SizedBox(height: 4),
            Text('Your thinking patterns', style: Nex.caption),
            const SizedBox(height: 24),

            // Stats grid
            GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.5,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _StatCard(label: 'Total Thoughts', value: '$total', icon: Icons.edit_note_rounded, color: Nex.primary),
                _StatCard(label: 'This Week', value: '$thisWeek', icon: Icons.calendar_today_rounded, color: Nex.blue),
                _StatCard(label: 'With Tasks', value: '$withTasks', icon: Icons.checklist_rounded, color: Nex.green),
                _StatCard(label: 'Tasks Done', value: '$tasksCompleted/$tasksTotal', icon: Icons.check_circle_rounded, color: Nex.violet),
              ],
            ),

            // Mode Breakdown
            const SizedBox(height: 28),
            Text('Thinking Modes', style: Nex.h3),
            const SizedBox(height: 12),
            ...ThoughtMode.values.map((m) {
              final count = modeCounts[m] ?? 0;
              final pct = total > 0 ? count / total : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(m.label, style: Nex.label),
                        Text('$count', style: Nex.label.copyWith(color: Nex.textSub)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 6,
                        backgroundColor: Nex.surfaceDim,
                        valueColor: AlwaysStoppedAnimation(_modeColor(m)),
                      ),
                    ),
                  ],
                ),
              );
            }),

            // Smart Insights
            if (insights.isNotEmpty) ...[
              const SizedBox(height: 28),
              Text('Smart Insights', style: Nex.h3),
              const SizedBox(height: 12),
              ...insights.map((i) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Nex.surface,
                  borderRadius: BorderRadius.circular(Nex.r12),
                  border: Border.all(color: Nex.border, width: 0.5),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(_insightIcon(i.type), size: 18, color: Nex.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(i.content, style: Nex.bodySub, maxLines: 3, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              )),
            ],
          ],
        );
      },
    );
  }

  Color _modeColor(ThoughtMode m) => switch (m) {
    ThoughtMode.idea => Nex.amber,
    ThoughtMode.deepThinking => Nex.violet,
    ThoughtMode.quickCapture => Nex.cyan,
    ThoughtMode.reflection => Nex.blue,
    ThoughtMode.taskOriented => Nex.green,
  };

  IconData _insightIcon(InsightType t) => switch (t) {
    InsightType.decision => Icons.gavel_rounded,
    InsightType.idea => Icons.lightbulb_outline_rounded,
    InsightType.task => Icons.check_circle_outline_rounded,
    InsightType.followUp => Icons.replay_rounded,
  };
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Nex.surface,
        borderRadius: BorderRadius.circular(Nex.r12),
        border: Border.all(color: Nex.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 20, color: color),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: Nex.h1),
              Text(label, style: Nex.small),
            ],
          ),
        ],
      ),
    );
  }
}
