import 'package:flutter_test/flutter_test.dart';
import 'package:lnmarkets_bot/src/platform/macos/macos_bot_runtime_controller.dart';

void main() {
  test('macOS runtime controller keeps explicit in-app runtime state',
      () async {
    final controller = MacosBotRuntimeController();

    expect(controller.supportsPersistentBackground, isFalse);
    expect(controller.running, isFalse);
    expect(controller.lastTitle, isNull);
    expect(controller.lastText, isNull);

    await controller.start(
      title: 'LN Markets Bot',
      text: 'Running',
    );

    expect(controller.running, isTrue);
    expect(controller.lastTitle, 'LN Markets Bot');
    expect(controller.lastText, 'Running');

    await controller.update(
      title: 'LN Markets Bot',
      text: 'Still running',
    );

    expect(controller.running, isTrue);
    expect(controller.lastTitle, 'LN Markets Bot');
    expect(controller.lastText, 'Still running');

    await controller.stop();

    expect(controller.running, isFalse);
    expect(controller.lastTitle, isNull);
    expect(controller.lastText, isNull);
  });
}
