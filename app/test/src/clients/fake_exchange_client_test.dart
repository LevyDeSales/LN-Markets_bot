import 'package:flutter_test/flutter_test.dart';
import 'package:lnmarkets_bot/src/clients/fake_exchange_client.dart';

void main() {
  test('fake exchange opens and closes positions without network', () async {
    final client = FakeExchangeClient(balanceSats: 100000);

    final user = await client.getUser();
    expect(user['balance'], 100000);
    expect(user['username'], 'mock-user');

    final opened = await client.openPosition('long', marginSats: 1000);
    expect(opened['side'], 'long');
    expect(opened['margin'], 1000);
    expect(await client.getOpenPositions(), hasLength(1));

    final closeResult = await client.closePosition(opened['id'] as String);
    expect(closeResult['pl'], 0);
    expect(await client.getOpenPositions(), isEmpty);
  });

  test('fake exchange records TP and SL updates on the open position',
      () async {
    final client = FakeExchangeClient();
    final opened = await client.openPosition('buy', marginSats: 5000);
    final id = opened['id'] as String;

    await client.setTakeProfit(id, 110000);
    await client.setStopLoss(id, 90000);

    final position = (await client.getOpenPositions()).single;
    expect(position['takeprofit'], 110000);
    expect(position['stoploss'], 90000);
  });
}
