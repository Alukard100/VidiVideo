import 'package:flutter_test/flutter_test.dart';
import 'package:vidivideo_app/src/app/vidivideo_app.dart';

void main() {
  testWidgets('renders login screen', (tester) async {
    await tester.pumpWidget(const VidiVideoApp());

    expect(find.text('VidiVideo'), findsOneWidget);
    expect(find.text('Sign in as admin'), findsOneWidget);
  });
}
