import 'package:flutter_test/flutter_test.dart';
import 'package:ict107_group_project/main.dart';

void main() {
  testWidgets('App opens successfully', (tester) async {
    await tester.pumpWidget(const MeetingModeApp());

    expect(find.text('Home'), findsOneWidget);
  });
}