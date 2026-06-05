import 'package:flutter_test/flutter_test.dart';
import 'package:lnmarkets_bot/src/settings/credentials_store.dart';

void main() {
  test('memory credentials store supports read, write and delete', () async {
    final store = MemoryCredentialsStore();

    expect(await store.read('api_key'), isNull);

    await store.write('api_key', 'key-1');
    expect(await store.read('api_key'), 'key-1');

    await store.delete('api_key');
    expect(await store.read('api_key'), isNull);
  });

  test('memory credentials store deletes only the requested credential keys',
      () async {
    final store = MemoryCredentialsStore();

    await store.write('api_key', 'key');
    await store.write('api_secret', 'secret');
    await store.write('api_passphrase', 'passphrase');
    await store.write('language', 'pt_BR');

    await store.deleteAll(['api_key', 'api_secret', 'api_passphrase']);

    expect(await store.read('api_key'), isNull);
    expect(await store.read('api_secret'), isNull);
    expect(await store.read('api_passphrase'), isNull);
    expect(await store.read('language'), 'pt_BR');
  });
}
