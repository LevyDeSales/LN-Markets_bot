class PositionStateSnapshot {
  final String? id;
  final String? side;
  final double? entryPrice;
  final double? tpPrice;
  final double? slPrice;
  final double? trailSlPrice;
  final DateTime? openedAt;

  const PositionStateSnapshot({
    this.id,
    this.side,
    this.entryPrice,
    this.tpPrice,
    this.slPrice,
    this.trailSlPrice,
    this.openedAt,
  });

  bool get hasPosition => id != null;

  static const empty = PositionStateSnapshot();

  factory PositionStateSnapshot.fromJson(Map<String, dynamic> json) =>
      PositionStateSnapshot(
        id: json['id'] as String?,
        side: json['side'] as String?,
        entryPrice: (json['entry_price'] as num?)?.toDouble(),
        tpPrice: (json['tp_price'] as num?)?.toDouble(),
        slPrice: (json['sl_price'] as num?)?.toDouble(),
        trailSlPrice: (json['trail_sl_price'] as num?)?.toDouble(),
        openedAt: json['opened_at'] != null
            ? DateTime.tryParse(json['opened_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'side': side,
        'entry_price': entryPrice,
        'tp_price': tpPrice,
        'sl_price': slPrice,
        'trail_sl_price': trailSlPrice,
        'opened_at': openedAt?.toIso8601String(),
      };
}
