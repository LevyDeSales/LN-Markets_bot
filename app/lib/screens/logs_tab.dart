import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../i18n.dart';
import '../services/log_service.dart';

class LogsTab extends StatefulWidget {
  final LogService logService;
  const LogsTab({super.key, required this.logService});

  @override
  State<LogsTab> createState() => _LogsTabState();
}

class _LogsTabState extends State<LogsTab> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.logService.stream.listen((_) {
      if (mounted) {
        setState(() {});
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scroll.hasClients) {
            _scroll.jumpTo(_scroll.position.maxScrollExtent);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Color _levelColor(LogLevel level) {
    switch (level) {
      case LogLevel.info:
        return AppColors.textMain;
      case LogLevel.warning:
        return AppColors.yellow;
      case LogLevel.error:
        return AppColors.red;
      case LogLevel.debug:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries = widget.logService.history;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(t('log_title')),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.delete_outline,
                size: 18, color: AppColors.textMuted),
            label: Text(t('log_clear'),
                style: const TextStyle(color: AppColors.textMuted)),
            onPressed: () {
              widget.logService.clear();
              setState(() {});
            },
          ),
        ],
      ),
      body: entries.isEmpty
          ? const Center(
              child: Text('—', style: TextStyle(color: AppColors.textMuted)))
          : ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(10),
              itemCount: entries.length,
              itemBuilder: (_, i) {
                final e = entries[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1),
                  child: RichText(
                    text: TextSpan(
                      style:
                          const TextStyle(fontFamily: 'Courier', fontSize: 11),
                      children: [
                        TextSpan(
                            text: '${e.timeStr} ',
                            style: const TextStyle(color: AppColors.textMuted)),
                        TextSpan(
                            text: e.prefix,
                            style: TextStyle(color: _levelColor(e.level))),
                        TextSpan(
                            text: e.message,
                            style: TextStyle(color: _levelColor(e.level))),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
