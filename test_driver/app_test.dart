import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

// Тесты можно сгруппировать с помощью функции group ()
void main() {
  group('My App', () {
    late FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() {
      driver.close();
    });

    // Описываем тест, в данном случае тест ищет текст, содержащий "0"

    test('starting ok', () async {
      final songListTitle = find.byValueKey('song_list_title');
      driver.waitForText(songListTitle, "Кино");
      await Future.delayed(const Duration(seconds: 10), (){});
      // Описываем действия с элементами интерфейса
      // expect(await driver.getText(counterTextFinder), "0");
    });

    test('drawer ok', () async {
      final drawerOpenButton = find.byTooltip('Open navigation menu');
      await driver.tap(drawerOpenButton);
      await Future.delayed(const Duration(seconds: 10), (){});
      // Описываем действия с элементами интерфейса
      // expect(await driver.getText(counterTextFinder), "0");
    });
  });
}

extension WaitForText on FlutterDriver {
  Future<void> waitForText(SerializableFinder finder, String text,
      {int retries = 10}) async {
    try {
      expect(await getText(finder), equals(text));
    } catch (_) {
      if (retries == 0) {
        rethrow;
      }
      await Future.delayed(const Duration(milliseconds: 17), () {});
      await waitForText(finder, text, retries: retries - 1);
    }
  }
}