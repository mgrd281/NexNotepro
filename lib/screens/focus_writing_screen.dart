import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FocusWritingScreen extends StatefulWidget {
  final String initialTitle;
  final String initialContent;
  final void Function(String title, String content) onSave;

  const FocusWritingScreen({
    super.key,
    this.initialTitle = '',
    this.initialContent = '',
    required this.onSave,
  });

  @override
  State<FocusWritingScreen> createState() => _FocusWritingScreenState();
}

class _FocusWritingScreenState extends State<FocusWritingScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  late final FocusNode _contentFocus;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _contentController = TextEditingController(text: widget.initialContent);
    _contentFocus = FocusNode();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _contentFocus.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _done() {
    widget.onSave(_titleController.text, _contentController.text);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final wordCount = _contentController.text
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFFFCFBFF),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: Column(
            children: [
              // Minimal top bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'Back',
                        style: NexTypography.labelMedium.copyWith(
                          color: NexColors.textTertiary,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: NexColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '🧘  Focus Mode',
                        style: NexTypography.caption.copyWith(
                          color: NexColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _done,
                      child: Text(
                        'Done',
                        style: NexTypography.labelMedium.copyWith(
                          color: NexColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Writing area
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
                  child: Column(
                    children: [
                      TextField(
                        controller: _titleController,
                        style: NexTypography.focusTitle,
                        maxLines: null,
                        textAlign: TextAlign.center,
                        onSubmitted: (_) => _contentFocus.requestFocus(),
                        decoration: InputDecoration(
                          hintText: 'What\'s on your mind?',
                          hintStyle: NexTypography.focusTitle.copyWith(
                            color: NexColors.textTertiary.withValues(alpha: 0.4),
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 40,
                        height: 2,
                        decoration: BoxDecoration(
                          color: NexColors.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _contentController,
                        focusNode: _contentFocus,
                        style: NexTypography.focusBody,
                        maxLines: null,
                        minLines: 12,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Let your thoughts flow…',
                          hintStyle: NexTypography.focusBody.copyWith(
                            color: NexColors.textTertiary.withValues(alpha: 0.35),
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Minimal footer
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 16),
                child: Text(
                  '$wordCount words',
                  style: NexTypography.caption.copyWith(
                    color: NexColors.textTertiary.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
