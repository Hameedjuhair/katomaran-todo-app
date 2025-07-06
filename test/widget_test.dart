import 'package:flutter_test/flutter_test.dart';

import 'package:katomaran_todo_app/main.dart';

void main() {
  testWidgets('App launches and shows login screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Welcome to Katomaran Todo'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
  });
}
