import 'package:uuid/uuid.dart';

const _uuid = Uuid();

// ───── Enums ─────

enum ThoughtMode {
  idea,
  deepThinking,
  quickCapture,
  reflection,
  taskOriented,
}

enum EmotionalTag {
  stressed,
  inspired,
  focused,
  confused,
}

enum MemorySpace {
  work,
  personal,
  ideasLab,
  lifeJournal,
}

enum InsightType {
  decision,
  idea,
  task,
  followUp,
}

// ───── Extensions ─────

extension ThoughtModeX on ThoughtMode {
  String get label => switch (this) {
    ThoughtMode.idea => 'Idea',
    ThoughtMode.deepThinking => 'Deep Thinking',
    ThoughtMode.quickCapture => 'Quick Capture',
    ThoughtMode.reflection => 'Reflection',
    ThoughtMode.taskOriented => 'Task-Oriented',
  };

  String get emoji => switch (this) {
    ThoughtMode.idea => '💡',
    ThoughtMode.deepThinking => '🧠',
    ThoughtMode.quickCapture => '⚡',
    ThoughtMode.reflection => '🌙',
    ThoughtMode.taskOriented => '✅',
  };
}

extension EmotionalTagX on EmotionalTag {
  String get label => switch (this) {
    EmotionalTag.stressed => 'Stressed',
    EmotionalTag.inspired => 'Inspired',
    EmotionalTag.focused => 'Focused',
    EmotionalTag.confused => 'Confused',
  };

  String get emoji => switch (this) {
    EmotionalTag.stressed => '😰',
    EmotionalTag.inspired => '✨',
    EmotionalTag.focused => '🎯',
    EmotionalTag.confused => '🤔',
  };
}

extension MemorySpaceX on MemorySpace {
  String get label => switch (this) {
    MemorySpace.work => 'Work Space',
    MemorySpace.personal => 'Personal Space',
    MemorySpace.ideasLab => 'Ideas Lab',
    MemorySpace.lifeJournal => 'Life Journal',
  };

  String get icon => switch (this) {
    MemorySpace.work => '💼',
    MemorySpace.personal => '🏡',
    MemorySpace.ideasLab => '🔬',
    MemorySpace.lifeJournal => '📖',
  };
}

// ───── Models ─────

class MindLayer {
  final String id;
  final String content;
  final LayerType type;

  MindLayer({
    String? id,
    required this.content,
    required this.type,
  }) : id = id ?? _uuid.v4();
}

enum LayerType { mainThought, subThought, insight, action }

extension LayerTypeX on LayerType {
  String get label => switch (this) {
    LayerType.mainThought => 'Main Thought',
    LayerType.subThought => 'Sub-thought',
    LayerType.insight => 'Insight',
    LayerType.action => 'Action',
  };
}

class ChecklistItem {
  final String id;
  String text;
  bool isCompleted;

  ChecklistItem({
    String? id,
    required this.text,
    this.isCompleted = false,
  }) : id = id ?? _uuid.v4();
}

class Insight {
  final String id;
  final InsightType type;
  final String content;
  final String noteId;
  final DateTime detectedAt;

  Insight({
    String? id,
    required this.type,
    required this.content,
    required this.noteId,
    DateTime? detectedAt,
  })  : id = id ?? _uuid.v4(),
        detectedAt = detectedAt ?? DateTime.now();
}

extension InsightTypeX on InsightType {
  String get label => switch (this) {
    InsightType.decision => 'Decision',
    InsightType.idea => 'Idea',
    InsightType.task => 'Task',
    InsightType.followUp => 'Follow-up',
  };

  String get emoji => switch (this) {
    InsightType.decision => '⚖️',
    InsightType.idea => '💡',
    InsightType.task => '☑️',
    InsightType.followUp => '🔄',
  };
}

class NexNote {
  final String id;
  String title;
  String content;
  ThoughtMode mode;
  EmotionalTag? emotionalTag;
  MemorySpace space;
  List<MindLayer> layers;
  List<ChecklistItem> checklist;
  List<String> tags;
  List<Insight> insights;
  String? imagePath;
  DateTime? reminder;
  bool isPinned;
  final DateTime createdAt;
  DateTime updatedAt;

  NexNote({
    String? id,
    required this.title,
    this.content = '',
    this.mode = ThoughtMode.quickCapture,
    this.emotionalTag,
    this.space = MemorySpace.personal,
    List<MindLayer>? layers,
    List<ChecklistItem>? checklist,
    List<String>? tags,
    List<Insight>? insights,
    this.imagePath,
    this.reminder,
    this.isPinned = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? _uuid.v4(),
        layers = layers ?? [],
        checklist = checklist ?? [],
        tags = tags ?? [],
        insights = insights ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  String get preview {
    if (content.length <= 120) return content;
    return '${content.substring(0, 120)}…';
  }

  NexNote copyWith({
    String? title,
    String? content,
    ThoughtMode? mode,
    EmotionalTag? emotionalTag,
    MemorySpace? space,
    List<MindLayer>? layers,
    List<ChecklistItem>? checklist,
    List<String>? tags,
    List<Insight>? insights,
    String? imagePath,
    DateTime? reminder,
    bool? isPinned,
  }) {
    return NexNote(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      mode: mode ?? this.mode,
      emotionalTag: emotionalTag ?? this.emotionalTag,
      space: space ?? this.space,
      layers: layers ?? this.layers,
      checklist: checklist ?? this.checklist,
      tags: tags ?? this.tags,
      insights: insights ?? this.insights,
      imagePath: imagePath ?? this.imagePath,
      reminder: reminder ?? this.reminder,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
