import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:russian_rock_song_book/main.dart' as app;

const ARTIST_1 = "Немного Нервно";
const ARTIST_2 = "Чайф";
const ARTIST_3 = "ДДТ";

const TITLE_1_1 = "Santa Maria";
const TITLE_1_2 = "Яблочный остров";
const TITLE_1_3 = "Над мертвым городом сон";
const TITLE_1_4 = "Atlantica";
const TITLE_2_1 = "17 лет";
const TITLE_2_2 = "Поплачь о нем";
const TITLE_3_1 = "Белая ночь";

void main() {
  testWidgets('app is starting correctly', (tester) async {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    app.main();

    await tester.pumpAndSettle();

    await tester.waitFor((tester) {
      final songListTitle = find.byKey(const Key('song_list_title'));
      expect(songListTitle, findsOneWidget);
      expect(tester.widget<Text>(songListTitle).data, 'Кино');
    });
  });

  testWidgets('menu is opening and closing with drawer button correctly', (tester) async {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    app.main();

    await tester.pumpAndSettle();

    final locateDrawer = find.byTooltip('Open navigation menu');
    await tester.tap(locateDrawer);
    await tester.pumpAndSettle();
    await tester.waitFor((tester) {
      expect(find.text('Меню'), findsOneWidget);
    });
    await tester.drag(locateDrawer, const Offset(-300, 0));
    await tester.pumpAndSettle();
    await tester.waitFor((tester) {
      final songListTitle = find.byKey(const Key('song_list_title'));
      expect(songListTitle, findsOneWidget);
      expect(tester.widget<Text>(songListTitle).data, 'Кино');
    });
  });

  // group('0', () {
  //
  // });

  // group('0', () {
  //   late FlutterDriver driver;
  //
  //   setUpAll(() async {
  //     driver = await FlutterDriver.connect();
  //   });
  //
  //   tearDownAll(() {
  //     driver.close();
  //   });
  //
  //   test('app is starting correctly', () async {
  //     final songListTitle = find.byValueKey('song_list_title');
  //     driver.waitForText(songListTitle, 'Кино');
  //     await Future.delayed(const Duration(seconds: 3), (){});
  //   });
  //
  //   test('menu is opening and closing with drawer button correctly', () async {
  //     final locateDrawer = find.byTooltip('Open navigation menu');
  //     await driver.tap(locateDrawer);
  //     await driver.waitFor(find.text('Меню'), timeout: const Duration(seconds: 3));
  //     await driver.scroll(locateDrawer, -300, 0, const Duration(milliseconds: 500));
  //     await driver.waitFor(find.text('Кино'), timeout: const Duration(seconds: 3));
  //   });
  //
  //   test('menu predefined artists are displaying correctly', () async {
  //     final locateDrawer = find.byTooltip('Open navigation menu');
  //     await driver.tap(locateDrawer);
  //     for (final artist in SongRepository.predefinedArtists) {
  //       await driver.waitFor(find.text(artist), timeout: const Duration(seconds: 3));
  //     }
  //     await driver.scroll(locateDrawer, -300, 0, const Duration(milliseconds: 500));
  //   });
  //
  //   test('menu is scrolling correctly', () async {
  //     final locateDrawer = find.byTooltip('Open navigation menu');
  //     await driver.tap(locateDrawer);
  //     final menuListView = find.byValueKey('menu_list_view');
  //     driver.waitFor(menuListView, timeout: const Duration(seconds: 3));
  //     final artist1Text = find.text(ARTIST_1);
  //     await driver.scrollUntilVisible(menuListView, artist1Text, dyScroll: -500);
  //     await Future.delayed(const Duration(seconds: 3), (){});
  //     await driver.scroll(locateDrawer, -300, 0, const Duration(milliseconds: 500));
  //   });
  // });
  //
  // group('1', () {
  //   late FlutterDriver driver;
  //
  //   setUpAll(() async {
  //     driver = await FlutterDriver.connect();
  //   });
  //
  //   tearDownAll(() {
  //     driver.close();
  //   });
  //
  //   test('song list for artist is opening from menu correctly', () async {
  //     final locateDrawer = find.byTooltip('Open navigation menu');
  //     await driver.tap(locateDrawer);
  //     final menuListView = find.byValueKey('menu_list_view');
  //     driver.waitFor(menuListView, timeout: const Duration(seconds: 3));
  //     final artist1Text = find.text(ARTIST_1);
  //     await driver.scrollUntilVisible(menuListView, artist1Text, dyScroll: -500);
  //     driver.tap(artist1Text);
  //     await Future.delayed(const Duration(seconds: 3), (){});
  //     // final songs = await songRepo.getSongsByArtist(ARTIST_1);
  //     // await driver.waitFor(find.text(songs[0].title));
  //     // await driver.waitFor(find.text(songs[1].title));
  //     // await driver.waitFor(find.text(songs[2].title));
  //   });
  // });
}

// extension WaitForText on FlutterDriver {
//   Future<void> waitForText(SerializableFinder finder, String text,
//       {int retries = 30}) async {
//     try {
//       expect(await getText(finder), equals(text));
//     } catch (_) {
//       if (retries == 0) {
//         rethrow;
//       }
//       await Future.delayed(const Duration(milliseconds: 100), () {});
//       await waitForText(finder, text, retries: retries - 1);
//     }
//   }
// }

extension WaitFor on WidgetTester {
  Future<void> waitFor(void Function(WidgetTester tester) toTry) async {
    var done = false;
    while (!done) {
      try {
        await pumpAndSettle();
        toTry(this);
        done = true;
      } catch (e) {
        // print(e);
      }
    }
  }
}