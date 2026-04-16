import 'package:flutter/material.dart';
import '../models/note_model.dart';

class NotesProvider extends ChangeNotifier {
  final List<NexNote> _notes = [];
  MemorySpace? _activeSpaceFilter;
  String _searchQuery = '';

  List<NexNote> get notes => List.unmodifiable(_notes);

  List<NexNote> get filteredNotes {
    var result = List<NexNote>.from(_notes);
    if (_activeSpaceFilter != null) {
      result = result.where((n) => n.space == _activeSpaceFilter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((n) =>
        n.title.toLowerCase().contains(q) ||
        n.content.toLowerCase().contains(q) ||
        n.tags.any((t) => t.toLowerCase().contains(q))
      ).toList();
    }
    result.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return result;
  }

  List<NexNote> get pinnedNotes =>
      _notes.where((n) => n.isPinned).toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  List<NexNote> get timelineNotes =>
      List<NexNote>.from(_notes)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<NexNote> notesForSpace(MemorySpace space) =>
      _notes.where((n) => n.space == space).toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  int noteCountForSpace(MemorySpace space) =>
      _notes.where((n) => n.space == space).length;

  List<Insight> get allInsights =>
      _notes.expand((n) => n.insights).toList()
        ..sort((a, b) => b.detectedAt.compareTo(a.detectedAt));

  MemorySpace? get activeSpaceFilter => _activeSpaceFilter;
  String get searchQuery => _searchQuery;

  void setSpaceFilter(MemorySpace? space) {
    _activeSpaceFilter = space;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void addNote(NexNote note) {
    _notes.insert(0, note);
    _extractInsights(note);
    notifyListeners();
  }

  void updateNote(NexNote note) {
    final i = _notes.indexWhere((n) => n.id == note.id);
    if (i != -1) {
      _notes[i] = note;
      _extractInsights(note);
      notifyListeners();
    }
  }

  void deleteNote(String id) {
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  void togglePin(String id) {
    final i = _notes.indexWhere((n) => n.id == id);
    if (i != -1) {
      _notes[i].isPinned = !_notes[i].isPinned;
      _notes[i].updatedAt = DateTime.now();
      notifyListeners();
    }
  }

  // Insight Engine – simple keyword-based detection
  void _extractInsights(NexNote note) {
    note.insights.clear();
    final text = '${note.title} ${note.content}'.toLowerCase();

    final decisionWords = ['decide', 'decision', 'choose', 'pick', 'go with', 'settled on'];
    final taskWords = ['todo', 'to-do', 'need to', 'must', 'should', 'have to', 'remember to'];
    final followUpWords = ['follow up', 'follow-up', 'check back', 'revisit', 'come back to'];

    for (final w in decisionWords) {
      if (text.contains(w)) {
        note.insights.add(Insight(
          type: InsightType.decision,
          content: 'Decision detected in this note',
          noteId: note.id,
        ));
        break;
      }
    }
    for (final w in taskWords) {
      if (text.contains(w)) {
        note.insights.add(Insight(
          type: InsightType.task,
          content: 'Action item detected',
          noteId: note.id,
        ));
        break;
      }
    }
    for (final w in followUpWords) {
      if (text.contains(w)) {
        note.insights.add(Insight(
          type: InsightType.followUp,
          content: 'Follow-up detected',
          noteId: note.id,
        ));
        break;
      }
    }
    if (note.mode == ThoughtMode.idea) {
      note.insights.add(Insight(
        type: InsightType.idea,
        content: 'Idea captured',
        noteId: note.id,
      ));
    }
  }

  // AI-style utilities (local, no API)
  String suggestTitle(String content) {
    if (content.trim().isEmpty) return 'Untitled Thought';
    final words = content.trim().split(RegExp(r'\s+'));
    final titleWords = words.take(6).toList();
    var title = titleWords.join(' ');
    if (words.length > 6) title += '…';
    return title;
  }

  String summarize(String content) {
    if (content.trim().isEmpty) return 'Nothing to summarize.';
    final sentences = content.split(RegExp(r'[.!?]+'));
    if (sentences.length <= 2) return content;
    return '${sentences.take(2).join('. ').trim()}.';
  }

  List<String> extractTasks(String content) {
    final tasks = <String>[];
    final lines = content.split('\n');
    for (final line in lines) {
      final trimmed = line.trim().toLowerCase();
      if (trimmed.startsWith('- [ ]') || trimmed.startsWith('- todo') ||
          trimmed.contains('need to') || trimmed.contains('must ') ||
          trimmed.contains('should ') || trimmed.contains('have to')) {
        tasks.add(line.trim());
      }
    }
    return tasks;
  }

  // Seed sample data
  void seedSampleData() {
    if (_notes.isNotEmpty) return;

    addNote(NexNote(
      title: 'Reimagine the onboarding flow',
      content: 'We need to simplify the first-time experience. Users should feel guided, not overwhelmed. Consider a 3-step wizard with progressive disclosure. Must ship by next sprint.',
      mode: ThoughtMode.idea,
      emotionalTag: EmotionalTag.inspired,
      space: MemorySpace.work,
      isPinned: true,
      tags: ['product', 'ux', 'priority'],
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ));

    addNote(NexNote(
      title: 'Morning reflections',
      content: 'Feeling grateful for the progress this week. The team is aligned and the product direction is clear. Need to remember to follow up with design team about the new color system.',
      mode: ThoughtMode.reflection,
      emotionalTag: EmotionalTag.focused,
      space: MemorySpace.lifeJournal,
      tags: ['gratitude', 'growth'],
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ));

    addNote(NexNote(
      title: 'API Architecture Decision',
      content: 'Decided to go with GraphQL over REST for the new microservice. Better flexibility for mobile clients. Should document the decision rationale for the team.',
      mode: ThoughtMode.deepThinking,
      space: MemorySpace.work,
      tags: ['architecture', 'api'],
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ));

    addNote(NexNote(
      title: 'App idea: Smart plant care',
      content: 'An app that uses camera + ML to identify plants and give personalized care schedules. Could integrate with smart watering systems. Todo: research existing apps.',
      mode: ThoughtMode.idea,
      emotionalTag: EmotionalTag.inspired,
      space: MemorySpace.ideasLab,
      isPinned: true,
      tags: ['startup', 'ml', 'app-idea'],
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ));

    addNote(NexNote(
      title: 'Weekend trip checklist',
      content: 'Pack bags, book restaurant, check weather forecast. Remember to charge camera batteries.',
      mode: ThoughtMode.taskOriented,
      space: MemorySpace.personal,
      tags: ['travel', 'weekend'],
      checklist: [
        ChecklistItem(text: 'Pack bags', isCompleted: true),
        ChecklistItem(text: 'Book restaurant'),
        ChecklistItem(text: 'Check weather'),
        ChecklistItem(text: 'Charge camera'),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ));

    addNote(NexNote(
      title: 'Quick thought on focus',
      content: 'Deep work requires eliminating context switching. Block 3-hour windows. No Slack, no email.',
      mode: ThoughtMode.quickCapture,
      emotionalTag: EmotionalTag.focused,
      space: MemorySpace.personal,
      tags: ['productivity'],
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
    ));
  }
}
