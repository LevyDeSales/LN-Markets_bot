const String kTelegramUrl = 'https://t.me/BrazilBelge';

class Exchange {
  final String   id;
  final String   name;
  final String   tagline;
  final String   signupUrl;    // referral link (update when partnership is set)
  final bool     live;         // true = link is a real referral, false = coming soon

  const Exchange({
    required this.id,
    required this.name,
    required this.tagline,
    required this.signupUrl,
    this.live = false,
  });
}

/// Exchange partner registry.
/// Set live: true and update signupUrl with the real referral link
/// once a partnership is established.
class SponsorService {
  static const List<Exchange> exchanges = [
    Exchange(
      id:        'binance',
      name:      'Binance',
      tagline:   'World\'s largest crypto exchange',
      signupUrl: 'https://www.binance.com/en/register',
      live:      false,
    ),
    Exchange(
      id:        'bingx',
      name:      'BingX',
      tagline:   'Copy-trading & futures platform',
      signupUrl: 'https://bingx.com/en/register',
      live:      false,
    ),
    Exchange(
      id:        'bybit',
      name:      'Bybit',
      tagline:   'Derivatives exchange — up to 100x leverage',
      signupUrl: 'https://www.bybit.com/en/register',
      live:      false,
    ),
    Exchange(
      id:        'okx',
      name:      'OKX',
      tagline:   'Spot, futures & Web3 in one app',
      signupUrl: 'https://www.okx.com/join',
      live:      false,
    ),
  ];

  static List<Exchange> get live => exchanges.where((e) => e.live).toList();

  // Legacy compat — kept so existing banner code still compiles
  static bool get hasActiveSponsors => live.isNotEmpty;
}
