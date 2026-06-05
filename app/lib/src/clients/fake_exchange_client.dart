import 'exchange_client.dart';

class FakeExchangeClient implements ExchangeClient {
  int balanceSats;
  int _nextId = 1;
  final List<Map<String, dynamic>> _positions = [];

  FakeExchangeClient({this.balanceSats = 100000});

  @override
  Future<Map<String, dynamic>> getUser() async => {
        'username': 'mock-user',
        'balance': balanceSats,
      };

  @override
  Future<List<dynamic>> getOpenPositions() async =>
      _positions.map(Map<String, dynamic>.from).toList();

  @override
  Future<Map<String, dynamic>> openPosition(String side,
      {int? marginSats}) async {
    final normalizedSide = switch (side) {
      'buy' => 'long',
      'sell' => 'short',
      _ => side,
    };
    final position = <String, dynamic>{
      'id': 'mock-${_nextId++}',
      'side': normalizedSide,
      'entryPrice': 50000.0,
      'entry_price': 50000.0,
      'margin': marginSats ?? 1000,
      'pl': 0,
    };
    _positions.add(position);
    return Map<String, dynamic>.from(position);
  }

  @override
  Future<Map<String, dynamic>> closePosition(String id) async {
    final index = _positions.indexWhere((position) => position['id'] == id);
    if (index < 0) {
      throw Exception('Fake position not found: $id');
    }
    final position = _positions.removeAt(index);
    return {
      'id': id,
      'pl': position['pl'] ?? 0,
    };
  }

  @override
  Future<void> setTakeProfit(String id, double price) async {
    _updatePosition(id, 'takeprofit', price);
  }

  @override
  Future<void> setStopLoss(String id, double price) async {
    _updatePosition(id, 'stoploss', price);
  }

  @override
  Future<void> applyTpSl(String id, String side, double entryPrice) async {}

  void _updatePosition(String id, String key, double value) {
    final position = _positions.firstWhere(
      (position) => position['id'] == id,
      orElse: () => throw Exception('Fake position not found: $id'),
    );
    position[key] = value;
  }
}
