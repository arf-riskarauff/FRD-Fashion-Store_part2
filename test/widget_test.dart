import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:frd_fashion_store_app/consts/consts.dart';
import 'package:frd_fashion_store_app/main.dart';
import 'package:frd_fashion_store_app/models/app_state.dart';

void main() {
  testWidgets('app shell renders', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const MyApp(),
      ),
    );

    expect(find.text(appname), findsWidgets);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.text('Sign In'), findsOneWidget);
  });
}
