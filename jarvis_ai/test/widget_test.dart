import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jarvis_ai/main.dart';

void main() {
  testWidgets('Onboarding screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: JarvisAI(),
      ),
    );

    // Verify that onboarding screen elements are rendered.
    expect(find.text('Meet Sundae!'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
  });
}
