import 'package:flutter_test/flutter_test.dart';

import 'package:spotidl/main.dart';

void main() {
  testWidgets('Tap on the search bar', (WidgetTester tester) async {
    await tester.pumpWidget(const SpotifyDownloader());

    expect(find.text('Search for a song'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    await tester.tap(find.text('Search for a song'));
    await tester.pump();

    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsNothing);
  });
}
