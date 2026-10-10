import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:merchant_project/main.dart';

void main() {
  testWidgets('App renders splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MerchantApp()),
    );

    expect(find.text('GNL'), findsOneWidget);
    expect(find.text('Merchant'), findsOneWidget);
    expect(find.text('Premium Nightlife Experience'), findsOneWidget);
  });
}
