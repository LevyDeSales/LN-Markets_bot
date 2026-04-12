import 'dart:async';
import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../i18n.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onDone;
  const SplashScreen({super.key, required this.onDone});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  int _count = 5;
  late final AnimationController _barCtrl;
  late final Animation<double>   _barAnim;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _barCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 5));
    _barAnim = Tween<double>(begin: 0, end: 1).animate(_barCtrl);
    _barCtrl.forward();

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => _count--);
      if (_count <= 0) {
        t.cancel();
        widget.onDone();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _barCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Logo ──
                const Text('⚡',
                    style: TextStyle(fontSize: 80)),
                const SizedBox(height: 8),
                const Text(
                  'LN Markets\nTrend Tabajara 3.0',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.orange),
                ),
                const SizedBox(height: 4),
                Text('v2.1  ·  by unknown_BTC_usr  ·  Made with ❤️ in Flutter with Claude',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.textMuted)),

                const SizedBox(height: 36),

                // ── Aviso API ──
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D2010),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppColors.green.withOpacity(.3), width: 1),
                  ),
                  child: Text(
                    t('splash_warning'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF7EDD7E),
                        height: 1.5),
                  ),
                ),

                const SizedBox(height: 32),

                // ── Countdown ──
                Text(
                  '${t('splash_start')} $_count ${t('splash_secs')}...',
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textMuted),
                ),
                const SizedBox(height: 10),

                // ── Progress bar ──
                AnimatedBuilder(
                  animation: _barAnim,
                  builder: (_, __) => ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _barAnim.value,
                      minHeight: 6,
                      backgroundColor: AppColors.card,
                      valueColor: const AlwaysStoppedAnimation(AppColors.orange),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
