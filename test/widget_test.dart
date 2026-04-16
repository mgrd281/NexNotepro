import 'package:flutter_test/flutter_test.dart';
import 'package:nexnote/main.dart';

void main() {
  testWidgets('NexNote app renders', (WidgetTester tester) async {
    await tester.pumpWidget(const NexNoteApp());
    expect(find.text('NexNote'), findsOneWidget);
  });
}
