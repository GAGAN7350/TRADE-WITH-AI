import 'package:flutter_test/flutter_test.dart';
import 'package:trade_with_ai/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TradeWithAIApp());

    // Verify that app title is displayed
    expect(find.text('Trade With AI'), findsOneWidget);
    
    // Verify that welcome message is displayed
    expect(find.text('Welcome to Trade With AI'), findsOneWidget);
  });
}
