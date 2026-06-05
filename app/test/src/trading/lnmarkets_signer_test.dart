import 'package:flutter_test/flutter_test.dart';
import 'package:lnmarkets_bot/src/trading/lnmarkets_signer.dart';

void main() {
  test('signs LN Markets requests with lower-case method and raw params', () {
    final signature = signLnMarketsRequest(
      timestamp: '1700000000000',
      method: 'GET',
      path: '/v3/account',
      params: '',
      secret: 'secret',
    );

    expect(signature, 'MkxMnlrxd+xEj70B3RIzQO0/SGjkHDO2BFE7vEmGMnY=');
  });

  test('builds POST signature payload from timestamp method path and body', () {
    final payload = buildLnMarketsSignaturePayload(
      timestamp: '1700000000000',
      method: 'POST',
      path: '/v2/futures',
      params: '{"type":"m"}',
    );

    expect(payload, '1700000000000post/v2/futures{"type":"m"}');
    expect(payload, isNot(contains('secret')));

    final signature = signLnMarketsRequest(
      timestamp: '1700000000000',
      method: 'POST',
      path: '/v2/futures',
      params: '{"type":"m"}',
      secret: 'secret',
    );

    expect(signature, 'FulL7oF8BXsZYV4ZQvmvTFD1DonFwZ8wmwxvIi3sRM0=');
  });
}
