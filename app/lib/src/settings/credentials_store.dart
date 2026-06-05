import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class CredentialsStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
  Future<void> deleteAll(Iterable<String> keys);
}

class SecureCredentialsStore implements CredentialsStore {
  final FlutterSecureStorage _storage;

  SecureCredentialsStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);

  @override
  Future<void> deleteAll(Iterable<String> keys) async {
    for (final key in keys) {
      await delete(key);
    }
  }
}

class MemoryCredentialsStore implements CredentialsStore {
  final Map<String, String> _values;

  MemoryCredentialsStore([Map<String, String>? initial])
      : _values = Map<String, String>.from(initial ?? const {});

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async {
    _values[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _values.remove(key);
  }

  @override
  Future<void> deleteAll(Iterable<String> keys) async {
    for (final key in keys) {
      _values.remove(key);
    }
  }

  Map<String, String> snapshot() => Map<String, String>.unmodifiable(_values);
}
