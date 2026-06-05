import '../../services/lnmarkets_api.dart';

abstract class ExchangeClient {
  Future<Map<String, dynamic>> getUser();
  Future<List<dynamic>> getOpenPositions();
  Future<Map<String, dynamic>> openPosition(String side, {int? marginSats});
  Future<Map<String, dynamic>> closePosition(String id);
  Future<void> setTakeProfit(String id, double price);
  Future<void> setStopLoss(String id, double price);
  Future<void> applyTpSl(String id, String side, double entryPrice);
}

class LiveExchangeClient implements ExchangeClient {
  final LNMarketsAPI _api;

  LiveExchangeClient(this._api);

  @override
  Future<Map<String, dynamic>> getUser() => _api.getUser();

  @override
  Future<List<dynamic>> getOpenPositions() => _api.getOpenPositions();

  @override
  Future<Map<String, dynamic>> openPosition(String side, {int? marginSats}) =>
      _api.openPosition(side, marginSats: marginSats);

  @override
  Future<Map<String, dynamic>> closePosition(String id) =>
      _api.closePosition(id);

  @override
  Future<void> setTakeProfit(String id, double price) =>
      _api.setTakeProfit(id, price);

  @override
  Future<void> setStopLoss(String id, double price) =>
      _api.setStopLoss(id, price);

  @override
  Future<void> applyTpSl(String id, String side, double entryPrice) =>
      _api.applyTpSl(id, side, entryPrice);
}
