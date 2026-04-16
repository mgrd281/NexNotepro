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
  late final TextEditingController _title;
  late final TextEditingController _content;
  late final TextEditingController _tagInput;

  ThoughtMode _mode = ThoughtMode.quickCapture;
  EmotionalTag? _mood;
  MemorySpace _space = MemorySpace.personal;
  List<String> _tags = [];
  List<ChecklistItem> _checklist = [];
  bool _showOptions = false;

  bool get _isEditing => widget.existingNote != null;

  @override
  void initState() {
    super.initState();
    final n = widget.existingNote;
    _title = TextEditingController(text: n?.title ?? '');
    _content = TextEditingController(text: n?.content ?? '');
    _tagInput = TextEditingController();
    if (n != null) {
      _mode = n.mode;
      _mood = n.emotionalTag;
      _space = n.space;
      _tags = List.from(n.tags);
      _checklist = n.checklist.map((c) => ChecklistItem(id: c.id, text: c.text, isCompleted: c.isCompleted)).toList();
      _showOptions = true;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    _tagInput.dispose();
    super.dispose();
  }

  void _save() {
    final title = _title.text.trim();
    final content = _content.text.trim();
    if (title.isEmpty && content.isEmpty) { Navigator.pop(context); return; }

    final provider = context.read<NotesProvider>();
    final finalTitle = title.isNotEmpty ? title : provider.suggestTitle(content);

    if (_isEditing) {
      provider.updateNote(widget.existingNote!.copyWith(
        title: finalTitle, content: content, mode: _mode,
        emotionalTag: _mood, space: _space, tags: _tags, checklist: _checklist,
      ));
    } else {
      provider.addNote(NexNote(
        title: finalTitle, content: content, mode: _mode,
        emotionalTag: _mood, space: _space, tags: _tags, checklist: _checklist,
      ));
    }
    Navigator.pop(context);
  }

  void _addTag() {
    final t = _tagInput.text.trim().replaceAll('#', '');
    if (t.isNotEmpty && !_tags.contains(t)) setState(() => _tags.add(t));
    _tagInput.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Nex.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 12, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, size: 22),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => FocusWritingScreen(
                          initialTitle: _title.text,
                          initialContent: _content.text,
                          onSave: (t, c) => setState(() { _title.text = t; _content.text = c; }),
                        ),
                      ));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: Nex.surfaceDim,
                        borderRadius: BorderRadius.circular(Nex.r8),
                      ),
                      child: Text('Focus', style: Nex.label.copyWith(color: Nex.primary)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _save,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Nex.primary,
                        borderRadius: BorderRadius.circular(Nex.r8),
                      ),
                      child: Text(_isEditing ? 'Update' : 'Save', style: Nex.label.copyWith(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),

            // ── Editor ──
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                children: [
                  // Title
                  TextField(
                    controller: _title,
                    style: Nex.h1,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Title',
                      hintStyle: Nex.h1.copyWith(color: Nex.textMuted.withValues(alpha: 0.5)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Content
                  TextField(
                    controller: _content,
                    style: Nex.body,
                    maxLines: null,
                    minLines: 8,
                    decoration: InputDecoration(
                      hintText: 'Start writing…',
                      hintStyle: Nex.body.copyWith(color: Nex.textMuted.withValues(alpha: 0.4)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),

                  // Checklist (if any)
                  if (_checklist.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    ..._checklist.asMap().entries.map((e) {
                      final item = e.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() => item.isCompleted = !item.isCompleted);
                              },
                              child: Container(
                                width: 20, height: 20,
                                decoration: BoxDecoration(
                                  color: item.isCompleted ? Nex.primary : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: item.isCompleted ? Nex.primary : Nex.border, width: 1.5),
                                ),
                                child: item.isCompleted ? const Icon(Icons.check_rounded, size: 14, color: Colors.white) : null,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                onChanged: (v) => item.text = v,
                                controller: TextEditingController(text: item.text),
                                style: Nex.body.copyWith(
                                  decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                                  color: item.isCompleted ? Nex.textMuted : Nex.text,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Task…',
                                  hintStyle: Nex.body.copyWith(color: Nex.textMuted),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(vertical: 6),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _checklist.removeAt(e.key)),
                              child: const Icon(Icons.close_rounded, size: 16, color: Nex.textMuted),
                            ),
                          ],
                        ),
                      );
                    }),
                    GestureDetector(
                      onTap: () => setState(() => _checklist.add(ChecklistItem(text: ''))),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            const Icon(Icons.add_rounded, size: 18, color: Nex.primary),
                            const SizedBox(width: 8),
                            Text('Add item', style: Nex.label.copyWith(color: Nex.primary)),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // ── Options panel (toggle) ──
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => setState(() => _showOptions = !_showOptions),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Icon(
                            _showOptions ? Icons.expand_less_rounded : Icons.tune_rounded,
                            size: 18, color: Nex.textMuted,
                          ),
                          const SizedBox(width: 8),
                          Text(_showOptions ? 'Hide options' : 'More options',
                            style: Nex.label.copyWith(color: Nex.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (_showOptions) ...[
                    const SizedBox(height: 12),

                    // Thought Mode
                    Text('Mode', style: Nex.label),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: ThoughtMode.values.map((m) => ModeChip(
                        label: m.label,
                        color: _modeColor(m),
                        selected: _mode == m,
                        onTap: () => setState(() => _mode = m),
                      )).toList(),
                    ),

                    const SizedBox(height: 20),

                    // Space
                    Text('Space', style: Nex.label),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: MemorySpace.values.map((s) => ModeChip(
                        label: s.label,
                        color: Nex.blue,
                        selected: _space == s,
                        onTap: () => setState(() => _space = s),
                      )).toList(),
                    ),

                    const SizedBox(height: 20),

                    // Mood
                    Text('Mood', style: Nex.label),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        ModeChip(label: 'None', color: Nex.textMuted, selected: _mood == null,
                          onTap: () => setState(() => _mood = null)),
                        ...EmotionalTag.values.map((t) => ModeChip(
                          label: t.label,
                          color: _moodColor(t),
                          selected: _mood == t,
                          onTap: () => setState(() => _mood = t),
                        )),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Tags
                    Text('Tags', style: Nex.label),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Nex.surfaceDim,
                              borderRadius: BorderRadius.circular(Nex.r8),
                            ),
                            child: TextField(
                              controller: _tagInput,
                              style: Nex.body,
                              onSubmitted: (_) => _addTag(),
                              decoration: InputDecoration(
                                hintText: 'Add tag',
                                hintStyle: Nex.body.copyWith(color: Nex.textMuted),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _addTag,
                          child: Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: Nex.surfaceDim,
                              borderRadius: BorderRadius.circular(Nex.r8),
                            ),
                            child: const Icon(Icons.add_rounded, size: 20, color: Nex.primary),
                          ),
                        ),
                      ],
                    ),
                    if (_tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6, runSpacing: 6,
                        children: _tags.map((t) => GestureDetector(
                          onTap: () => setState(() => _tags.remove(t)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Nex.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('#$t', style: Nex.label.copyWith(color: Nex.primary)),
                                const SizedBox(width: 4),
                                Icon(Icons.close_rounded, size: 12, color: Nex.primary.withValues(alpha: 0.5)),
                              ],
                            ),
                          ),
                        )).toList(),
                      ),
                    ],
                  ],
                ],
              ),
            ),

            // ── Bottom toolbar ──
            Container(
              decoration: const BoxDecoration(
                color: Nex.surface,
                border: Border(top: BorderSide(color: Nex.border, width: 0.5)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    children: [
                      _ToolBtn(Icons.checklist_rounded, () {
                        setState(() => _checklist.add(ChecklistItem(text: '')));
                      }),
                      _ToolBtn(Icons.schedule_rounded, () async {
                        await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().add(const Duration(days: 1)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                      }),
                      _ToolBtn(Icons.auto_awesome_outlined, () {
                        final p = context.read<NotesProvider>();
                        final suggestion = p.suggestTitle(_content.text);
                        setState(() => _title.text = suggestion);
                        HapticFeedback.lightImpact();
                      }),
                      const Spacer(),
                      ValueListenableBuilder(
                        valueListenable: _content,
                        builder: (_, value, __) {
                          final words = value.text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
                          return Text('$words words', style: Nex.small);
                        },
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

  Color _modeColor(ThoughtMode m) => switch (m) {
    ThoughtMode.idea => Nex.amber,
    ThoughtMode.deepThinking => Nex.violet,
    ThoughtMode.quickCapture => Nex.cyan,
    ThoughtMode.reflection => Nex.blue,
    ThoughtMode.taskOriented => Nex.green,
  };

  Color _moodColor(EmotionalTag t) => switch (t) {
    EmotionalTag.stressed => Nex.red,
    EmotionalTag.inspired => Nex.amber,
    EmotionalTag.focused => Nex.green,
    EmotionalTag.confused => Nex.textMuted,
  };
}

class _ToolBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ToolBtn(this.icon, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () { HapticFeedback.lightImpact(); onTap(); },
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Icon(icon, size: 22, color: Nex.textSub),
      ),
    );
  }
}
