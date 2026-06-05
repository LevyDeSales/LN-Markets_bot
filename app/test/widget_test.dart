import 'package:flutter_test/flutter_test.dart';
import 'package:lnmarkets_bot/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('app renders home shell in mock-safe mode', (tester) async {
    SharedPreferences.setMockInitialValues({'network': 'testnet'});

    await tester.pumpWidget(await buildMockSafeApp());
    await tester.pump();

    expect(find.textContaining('LN Markets'), findsWidgets);
    expect(find.textContaining('API'), findsWidgets);
  });
}
