// This is a basic Flutter widget test.
import 'package:flutter_test/flutter_test.dart';
import 'package:livehub/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const LiveHubApp());

    // Verify that the app starts.
    // AuthScreen should show the welcome text.
    expect(find.textContaining('HUB'), findsWidgets);
  });
}
