import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:comment_corp/main.dart';

void main() {
  testWidgets('App renders menu screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: CommentCorpApp()));
    expect(find.text('Comment\nCorporation'), findsOneWidget);
    expect(find.text('댓글 주식회사'), findsOneWidget);
  });
}
