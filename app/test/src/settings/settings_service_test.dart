import 'package:flutter_test/flutter_test.dart';
import 'package:lnmarkets_bot/services/settings_service.dart';
import 'package:lnmarkets_bot/src/settings/credentials_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('defaults to testnet when no network preference exists', () async {
    SharedPreferences.setMockInitialValues({});
    final service = SettingsService(credentialsStore: MemoryCredentialsStore());

    await service.load();

    expect(service.network, 'testnet');
    expect(service.baseUrl, 'https://api.testnet4.lnmarkets.com');
  });

  test('load migrates legacy plaintext credentials and removes them from prefs',
      () async {
    SharedPreferences.setMockInitialValues({
      'api_key': 'legacy-key',
      'api_secret': 'legacy-secret',
      'api_passphrase': 'legacy-passphrase',
      'network': 'testnet',
    });
    final credentialsStore = MemoryCredentialsStore();
    final service = SettingsService(credentialsStore: credentialsStore);

    await service.load();

    expect(service.apiKey, 'legacy-key');
    expect(service.apiSecret, 'legacy-secret');
    expect(service.apiPassphrase, 'legacy-passphrase');
    expect(await credentialsStore.read('api_key'), 'legacy-key');
    expect(await credentialsStore.read('api_secret'), 'legacy-secret');
    expect(await credentialsStore.read('api_passphrase'), 'legacy-passphrase');

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('api_key'), isNull);
    expect(prefs.getString('api_secret'), isNull);
    expect(prefs.getString('api_passphrase'), isNull);
    expect(prefs.getString('network'), 'testnet');
  });

  test(
      'load removes legacy plaintext credentials even when secure values exist',
      () async {
    SharedPreferences.setMockInitialValues({
      'api_key': 'legacy-key',
      'api_secret': 'legacy-secret',
      'api_passphrase': 'legacy-passphrase',
    });
    final credentialsStore = MemoryCredentialsStore({
      'api_key': 'secure-key',
      'api_secret': 'secure-secret',
      'api_passphrase': 'secure-passphrase',
    });
    final service = SettingsService(credentialsStore: credentialsStore);

    await service.load();

    expect(service.apiKey, 'secure-key');
    expect(service.apiSecret, 'secure-secret');
    expect(service.apiPassphrase, 'secure-passphrase');

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('api_key'), isNull);
    expect(prefs.getString('api_secret'), isNull);
    expect(prefs.getString('api_passphrase'), isNull);
  });

  test('save removes any legacy plaintext credential values from prefs',
      () async {
    SharedPreferences.setMockInitialValues({
      'api_key': 'legacy-key',
      'api_secret': 'legacy-secret',
      'api_passphrase': 'legacy-passphrase',
    });
    final credentialsStore = MemoryCredentialsStore();
    final service = SettingsService(credentialsStore: credentialsStore);

    await service.load();
    service.apiKey = 'new-key';
    service.apiSecret = 'new-secret';
    service.apiPassphrase = 'new-passphrase';

    await service.save();

    expect(await credentialsStore.read('api_key'), 'new-key');
    expect(await credentialsStore.read('api_secret'), 'new-secret');
    expect(await credentialsStore.read('api_passphrase'), 'new-passphrase');

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('api_key'), isNull);
    expect(prefs.getString('api_secret'), isNull);
    expect(prefs.getString('api_passphrase'), isNull);
  });
}
