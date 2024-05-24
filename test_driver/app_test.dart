import 'package:flutter_driver/flutter_driver.dart';
import 'package:russian_rock_song_book/domain/repository/local/song_repository.dart';
import 'package:test/test.dart';

void main() {
  group('My App', () {
    late FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() {
      driver.close();
    });

    test('app is starting correctly', () async {
      final songListTitle = find.byValueKey('song_list_title');
      driver.waitForText(songListTitle, 'Кино');
      await Future.delayed(const Duration(seconds: 3), (){});
    });

    test('menu is opening and closing with drawer button correctly', () async {
      final locateDrawer = find.byTooltip('Open navigation menu');
      await driver.tap(locateDrawer);
      await driver.waitFor(find.text('Меню'), timeout: const Duration(seconds: 3));
      await driver.scroll(locateDrawer, -300, 0, const Duration(milliseconds: 500));
      await driver.waitFor(find.text('Кино'), timeout: const Duration(seconds: 3));
    });

    test('menu predefined artists are displaying correctly', () async {
      final locateDrawer = find.byTooltip('Open navigation menu');
      await driver.tap(locateDrawer);
      for (final artist in SongRepository.predefinedArtists) {
        await driver.waitFor(find.text(artist), timeout: const Duration(seconds: 3));
      }
    });
  });
}

extension WaitForText on FlutterDriver {
  Future<void> waitForText(SerializableFinder finder, String text,
      {int retries = 30}) async {
    try {
      expect(await getText(finder), equals(text));
    } catch (_) {
      if (retries == 0) {
        rethrow;
      }
      await Future.delayed(const Duration(milliseconds: 100), () {});
      await waitForText(finder, text, retries: retries - 1);
    }
  }
}