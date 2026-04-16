import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FocusWritingScreen extends StatefulWidget {
  final String? initialTitle;
  final String? initialContent;
  final void Function(String title, String content)? onSave;

  const FocusWritingScreen({super.key, this.initialTitle, this.initialContent, this.onSave});

  @override
  State<FocusWritingScreen> createState() => _FocusWritingScreenState();
}

class _FocusWritingScreenState extends State<FocusWritingScreen> {
  late final TextEditingController _title;
  late final TextEditingController _content;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.initialTitle ?? '');
    _content = TextEditingController(text: widget.initialContent ?? '');
  }

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    super.dispose();
  }

  void _done() {
    widget.onSave?.call(_title.text, _content.text);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Nex.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Minimal top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 12, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _done,
                    icon: const Icon(Icons.arrow_back_rounded, size: 22),
                  ),
                  const Spacer(),
                  ValueListenableBuilder(
                    valueListenable: _content,
                    builder: (_, val, __) {
                      final words = val.text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
                      return Text('$words words', style: Nex.caption);
                    },
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: _done,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: Nex.primary,
                        borderRadius: BorderRadius.circular(Nex.r8),
                      ),
                      child: Text('Done', style: Nex.label.copyWith(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),

            // Focus editor
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    TextField(
                      controller: _title,
                      style: Nex.focusTitle,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'Title',
                        hintStyle: Nex.focusTitle.copyWith(color: Nex.textMuted.withValues(alpha: 0.4)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: TextField(
                        controller: _content,
                        style: Nex.focusBody,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: InputDecoration(
                          hintText: 'Write freely…',
                          hintStyle: Nex.focusBody.copyWith(color: Nex.textMuted.withValues(alpha: 0.3)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
