import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:lnmarkets_bot/services/lnmarkets_api.dart';
import 'package:lnmarkets_bot/services/settings_service.dart';
import 'package:lnmarkets_bot/src/settings/credentials_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('setStopLoss uses documented isolated futures PUT endpoint', () async {
    final settings = await _buildSettings();
    final client = RecordingClient();
    final api = LNMarketsAPI(settings, client: client);

    await api.setStopLoss('trade-id', 61000.25);

    expect(client.requests, hasLength(1));
    final request = client.requests.single;
    expect(request.method, 'PUT');
    expect(
      request.url.toString(),
      'https://api.lnmarkets.com/v3/futures/isolated/trade/stoploss',
    );
    expect(jsonDecode(request.body), {
      'id': 'trade-id',
      'value': 61000.25,
    });
    expect(request.body, isNot(contains('stoploss')));
    expect(request.headers['Content-Type'], contains('application/json'));
    expect(request.headers['LNM-ACCESS-KEY'], 'key');
    expect(request.headers['LNM-ACCESS-PASSPHRASE'], 'passphrase');
    expect(request.headers['LNM-ACCESS-SIGNATURE'], isNotEmpty);
    expect(request.headers['LNM-ACCESS-TIMESTAMP'], isNotEmpty);
  });

  test('setTakeProfit uses documented isolated futures PUT endpoint', () async {
    final settings = await _buildSettings();
    final client = RecordingClient();
    final api = LNMarketsAPI(settings, client: client);

    await api.setTakeProfit('trade-id', 63123.86);

    expect(client.requests, hasLength(1));
    final request = client.requests.single;
    expect(request.method, 'PUT');
    expect(
      request.url.toString(),
      'https://api.lnmarkets.com/v3/futures/isolated/trade/takeprofit',
    );
    expect(jsonDecode(request.body), {
      'id': 'trade-id',
      'value': 63123.86,
    });
    expect(request.body, isNot(contains('takeprofit')));
    expect(request.headers['Content-Type'], contains('application/json'));
    expect(request.headers['LNM-ACCESS-KEY'], 'key');
    expect(request.headers['LNM-ACCESS-PASSPHRASE'], 'passphrase');
    expect(request.headers['LNM-ACCESS-SIGNATURE'], isNotEmpty);
    expect(request.headers['LNM-ACCESS-TIMESTAMP'], isNotEmpty);
  });

  test('openPosition forwards sub-1000 sat margin without local clamp',
      () async {
    final settings = await _buildSettings();
    settings.leverage = 3;
    settings.marginSats = 50000;
    final client = RecordingClient();
    final api = LNMarketsAPI(settings, client: client);

    await api.openPosition('long', marginSats: 500);

    expect(client.requests, hasLength(1));
    final request = client.requests.single;
    expect(request.method, 'POST');
    expect(
      request.url.toString(),
      'https://api.lnmarkets.com/v3/futures/isolated/trade',
    );
    expect(jsonDecode(request.body), {
      'type': 'market',
      'side': 'long',
      'margin': 500,
      'leverage': 3,
    });
  });
}

Future<SettingsService> _buildSettings() async {
  SharedPreferences.setMockInitialValues({'network': 'mainnet'});
  final settings =
      SettingsService(credentialsStore: MemoryCredentialsStore());
  await settings.load();
  settings.apiKey = 'key';
  settings.apiSecret = 'secret';
  settings.apiPassphrase = 'passphrase';
  settings.network = 'mainnet';
  return settings;
}

class RecordingClient extends http.BaseClient {
  final List<http.Request> requests = [];

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final recorded = http.Request(request.method, request.url);
    recorded.headers.addAll(request.headers);
    if (request is http.Request) {
      recorded.body = request.body;
    }
    requests.add(recorded);

    return http.StreamedResponse(
      Stream<List<int>>.value(utf8.encode('{}')),
      200,
      headers: {'Content-Type': 'application/json'},
    );
  }
}
