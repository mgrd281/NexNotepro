import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/note_model.dart';
import '../providers/notes_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'focus_writing_screen.dart';

class AddNoteScreen extends StatefulWidget {
  final NexNote? existingNote;

  const AddNoteScreen({super.key, this.existingNote});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final TextEditingController _tagController;

  ThoughtMode _mode = ThoughtMode.quickCapture;
  EmotionalTag? _emotionalTag;
  MemorySpace _space = MemorySpace.personal;
  List<String> _tags = [];
  List<ChecklistItem> _checklist = [];
  bool _showChecklist = false;

  bool get _isEditing => widget.existingNote != null;

  @override
  void initState() {
    super.initState();
    final note = widget.existingNote;
    _titleController = TextEditingController(text: note?.title ?? '');
    _contentController = TextEditingController(text: note?.content ?? '');
    _tagController = TextEditingController();
    if (note != null) {
      _mode = note.mode;
      _emotionalTag = note.emotionalTag;
      _space = note.space;
      _tags = List.from(note.tags);
      _checklist = note.checklist.map((c) =>
        ChecklistItem(id: c.id, text: c.text, isCompleted: c.isCompleted)
      ).toList();
      _showChecklist = _checklist.isNotEmpty;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty && content.isEmpty) {
      Navigator.pop(context);
      return;
    }

    final provider = context.read<NotesProvider>();
    final finalTitle = title.isNotEmpty ? title : provider.suggestTitle(content);

    if (_isEditing) {
      provider.updateNote(widget.existingNote!.copyWith(
        title: finalTitle,
        content: content,
        mode: _mode,
        emotionalTag: _emotionalTag,
        space: _space,
        tags: _tags,
        checklist: _checklist,
      ));
    } else {
      provider.addNote(NexNote(
        title: finalTitle,
        content: content,
        mode: _mode,
        emotionalTag: _emotionalTag,
        space: _space,
        tags: _tags,
        checklist: _checklist,
      ));
    }
    Navigator.pop(context);
  }

  void _addTag() {
    final tag = _tagController.text.trim().replaceAll('#', '');
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() => _tags.add(tag));
      _tagController.clear();
    }
  }

  void _addChecklistItem() {
    setState(() {
      _checklist.add(ChecklistItem(text: ''));
      _showChecklist = true;
    });
  }

  void _openFocusMode() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FocusWritingScreen(
          initialTitle: _titleController.text,
          initialContent: _contentController.text,
          onSave: (title, content) {
            setState(() {
              _titleController.text = title;
              _contentController.text = content;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NexColors.background,
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
                    icon: const Icon(Icons.close_rounded, size: 24),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _openFocusMode,
                    child: Row(
                      children: [
                        Icon(Icons.edit_note_rounded, size: 18, color: NexColors.primary),
                        const SizedBox(width: 4),
                        Text('Focus', style: NexTypography.labelMedium.copyWith(color: NexColors.primary)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: _save,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: NexColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _isEditing ? 'Update' : 'Save',
                        style: NexTypography.labelMedium.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    TextField(
                      controller: _titleController,
                      style: NexTypography.displayMedium,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'Title your thought…',
                        hintStyle: NexTypography.displayMedium.copyWith(
                          color: NexColors.textTertiary.withValues(alpha: 0.5),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Content
                    TextField(
                      controller: _contentController,
                      style: NexTypography.bodyLarge.copyWith(color: NexColors.textPrimary),
                      maxLines: null,
                      minLines: 6,
                      decoration: InputDecoration(
                        hintText: 'Start writing…',
                        hintStyle: NexTypography.bodyLarge.copyWith(
                          color: NexColors.textTertiary.withValues(alpha: 0.5),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Thought Mode
                    Text('Thought Mode', style: NexTypography.labelLarge),
                    const SizedBox(height: 10),
                    ChipSelector<ThoughtMode>(
                      items: ThoughtMode.values,
                      selected: _mode,
                      labelBuilder: (m) => m.label,
                      emojiBuilder: (m) => m.emoji,
                      colorBuilder: (m) => switch (m) {
                        ThoughtMode.idea => NexColors.modeIdea,
                        ThoughtMode.deepThinking => NexColors.modeDeepThinking,
                        ThoughtMode.quickCapture => NexColors.modeQuickCapture,
                        ThoughtMode.reflection => NexColors.modeReflection,
                        ThoughtMode.taskOriented => NexColors.modeTaskOriented,
                      },
                      onSelected: (m) => setState(() => _mode = m),
                    ),

                    const SizedBox(height: 24),

                    // Mood
                    Text('How do you feel?', style: NexTypography.labelLarge),
                    const SizedBox(height: 10),
                    ChipSelector<EmotionalTag?>(
                      items: [null, ...EmotionalTag.values],
                      selected: _emotionalTag,
                      labelBuilder: (t) => t?.label ?? 'None',
                      emojiBuilder: (t) => t?.emoji ?? '😌',
                      colorBuilder: (t) => switch (t) {
                        EmotionalTag.stressed => NexColors.moodStressed,
                        EmotionalTag.inspired => NexColors.moodInspired,
                        EmotionalTag.focused => NexColors.moodFocused,
                        EmotionalTag.confused => NexColors.moodConfused,
                        null => NexColors.textTertiary,
                      },
                      onSelected: (t) => setState(() => _emotionalTag = t),
                    ),

                    const SizedBox(height: 24),

                    // Memory Space
                    Text('Memory Space', style: NexTypography.labelLarge),
                    const SizedBox(height: 10),
                    ChipSelector<MemorySpace>(
                      items: MemorySpace.values,
                      selected: _space,
                      labelBuilder: (s) => s.label,
                      emojiBuilder: (s) => s.icon,
                      colorBuilder: (s) => switch (s) {
                        MemorySpace.work => NexColors.spaceWork,
                        MemorySpace.personal => NexColors.spacePersonal,
                        MemorySpace.ideasLab => NexColors.spaceIdeasLab,
                        MemorySpace.lifeJournal => NexColors.spaceLifeJournal,
                      },
                      onSelected: (s) => setState(() => _space = s),
                    ),

                    const SizedBox(height: 24),

                    // Tags
                    Text('Tags', style: NexTypography.labelLarge),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: NexColors.surfaceSubtle,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              controller: _tagController,
                              style: NexTypography.bodyMedium.copyWith(color: NexColors.textPrimary),
                              onSubmitted: (_) => _addTag(),
                              decoration: InputDecoration(
                                hintText: 'Add tag…',
                                hintStyle: NexTypography.bodyMedium,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _addTag,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: NexColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.add_rounded, color: NexColors.primary, size: 20),
                          ),
                        ),
                      ],
                    ),
                    if (_tags.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: _tags.map((tag) => GestureDetector(
                          onTap: () => setState(() => _tags.remove(tag)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: NexColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('#$tag', style: NexTypography.labelMedium.copyWith(color: NexColors.primary)),
                                const SizedBox(width: 4),
                                Icon(Icons.close_rounded, size: 14, color: NexColors.primary.withValues(alpha: 0.6)),
                              ],
                            ),
                          ),
                        )).toList(),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Checklist
                    if (_showChecklist) ...[
                      Text('Checklist', style: NexTypography.labelLarge),
                      const SizedBox(height: 10),
                      ..._checklist.asMap().entries.map((entry) {
                        final i = entry.key;
                        final item = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(() => item.isCompleted = !item.isCompleted);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: item.isCompleted ? NexColors.primary : Colors.transparent,
                                    borderRadius: BorderRadius.circular(7),
                                    border: Border.all(
                                      color: item.isCompleted ? NexColors.primary : NexColors.textTertiary,
                                      width: 2,
                                    ),
                                  ),
                                  child: item.isCompleted
                                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                                    : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  onChanged: (v) => item.text = v,
                                  controller: TextEditingController(text: item.text),
                                  style: NexTypography.bodyMedium.copyWith(
                                    color: NexColors.textPrimary,
                                    decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Task item…',
                                    hintStyle: NexTypography.bodyMedium,
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => setState(() => _checklist.removeAt(i)),
                                child: Icon(Icons.close_rounded, size: 18, color: NexColors.textTertiary),
                              ),
                            ],
                          ),
                        );
                      }),
                      GestureDetector(
                        onTap: _addChecklistItem,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Icon(Icons.add_rounded, size: 20, color: NexColors.primary),
                              const SizedBox(width: 8),
                              Text('Add item', style: NexTypography.labelMedium.copyWith(color: NexColors.primary)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // AI Tools (subtle)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: NexColors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.auto_awesome_rounded, size: 18, color: NexColors.primary),
                              const SizedBox(width: 8),
                              Text('AI Thinking Tools', style: NexTypography.labelLarge.copyWith(color: NexColors.primary)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _AiToolChip(
                                label: 'Suggest Title',
                                icon: Icons.title_rounded,
                                onTap: () {
                                  final provider = context.read<NotesProvider>();
                                  final suggestion = provider.suggestTitle(_contentController.text);
                                  setState(() => _titleController.text = suggestion);
                                },
                              ),
                              _AiToolChip(
                                label: 'Summarize',
                                icon: Icons.compress_rounded,
                                onTap: () {
                                  final provider = context.read<NotesProvider>();
                                  final summary = provider.summarize(_contentController.text);
                                  _showInfoSheet(context, 'Summary', summary);
                                },
                              ),
                              _AiToolChip(
                                label: 'Extract Tasks',
                                icon: Icons.checklist_rounded,
                                onTap: () {
                                  final provider = context.read<NotesProvider>();
                                  final tasks = provider.extractTasks(_contentController.text);
                                  if (tasks.isEmpty) {
                                    _showInfoSheet(context, 'Tasks', 'No tasks detected.');
                                  } else {
                                    setState(() {
                                      _showChecklist = true;
                                      for (final t in tasks) {
                                        _checklist.add(ChecklistItem(text: t));
                                      }
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),

            // Bottom toolbar
            Container(
              decoration: BoxDecoration(
                color: NexColors.surfaceElevated,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      _ToolbarButton(
                        icon: Icons.checklist_rounded,
                        onTap: _addChecklistItem,
                      ),
                      _ToolbarButton(
                        icon: Icons.image_rounded,
                        onTap: () {
                          // Image picker placeholder
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Image picker coming soon', style: NexTypography.bodyMedium.copyWith(color: Colors.white)),
                              backgroundColor: NexColors.primary,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        },
                      ),
                      _ToolbarButton(
                        icon: Icons.schedule_rounded,
                        onTap: () async {
                          // Date picker for reminder
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().add(const Duration(days: 1)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Reminder set for ${date.day}/${date.month}', style: NexTypography.bodyMedium.copyWith(color: Colors.white)),
                                backgroundColor: NexColors.primary,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                          }
                        },
                      ),
                      const Spacer(),
                      Text(
                        '${_contentController.text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length} words',
                        style: NexTypography.caption,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoSheet(BuildContext context, String title, String content) {
    showModalBottomSheet(
      context: context,
      backgroundColor: NexColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: NexColors.textTertiary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(title, style: NexTypography.headlineLarge),
            const SizedBox(height: 12),
            Text(content, style: NexTypography.bodyLarge),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _AiToolChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _AiToolChip({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: NexColors.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: NexColors.primary),
            const SizedBox(width: 6),
            Text(label, style: NexTypography.labelMedium.copyWith(color: NexColors.primary)),
          ],
        ),
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ToolbarButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Icon(icon, size: 22, color: NexColors.textSecondary),
      ),
    );
  }
}
