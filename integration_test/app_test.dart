import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';
import 'package:russian_rock_song_book/domain/repository/local/song_repository.dart';
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

  testWidgets('menu predefined artists are displaying correctly', (tester) async {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    app.main();

    await tester.pumpAndSettle();

    final locateDrawer = find.byTooltip('Open navigation menu');
    await tester.tap(locateDrawer);
    await tester.pumpAndSettle();
    for (final artist in SongRepository.predefinedArtists) {
      await tester.waitFor((tester) {
        expect(find.text(artist), findsOneWidget);
      });
    }
  });

  testWidgets('menu is scrolling correctly', (tester) async {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    app.main();

    await tester.pumpAndSettle();

    final locateDrawer = find.byTooltip('Open navigation menu');
    await tester.tap(locateDrawer);
    await tester.pumpAndSettle();

    final menuListView = find.byKey(const Key('menu_list_view'));
    await tester.waitFor((tester) {
      expect(menuListView, findsOneWidget);
    });
    final scrollable = find.byWidgetPredicate((w) => w is Scrollable);
    final menuListScrollable = find.descendant(of: menuListView, matching: scrollable);
    final artist1Text = find.text(ARTIST_1);
    await tester.scrollUntilVisible(artist1Text, 500, scrollable: menuListScrollable);
    await tester.waitFor((tester) {
      expect(artist1Text, findsOneWidget);
    });
  });

  testWidgets('song list for artist is opening from menu correctly', (tester) async {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    app.main();

    await tester.pumpAndSettle();

    final locateDrawer = find.byTooltip('Open navigation menu');
    await tester.tap(locateDrawer);
    await tester.pumpAndSettle();

    final menuListView = find.byKey(const Key('menu_list_view'));
    await tester.waitFor((tester) {
      expect(menuListView, findsOneWidget);
    });
    final scrollable = find.byWidgetPredicate((w) => w is Scrollable);
    final menuListScrollable = find.descendant(of: menuListView, matching: scrollable);
    final artist1Text = find.text(ARTIST_1);
    await tester.scrollUntilVisible(artist1Text, 500, scrollable: menuListScrollable);
    await tester.waitFor((tester) {
      expect(artist1Text, findsOneWidget);
    });
    await tester.tap(artist1Text);
    await tester.pumpAndSettle();
    final songs = await GetIt.I<SongRepository>().getSongsByArtist(ARTIST_1);
    await tester.waitFor((tester) {
      expect(find.text(songs[0].title), findsOneWidget);
      expect(find.text(songs[1].title), findsOneWidget);
      expect(find.text(songs[2].title), findsOneWidget);
    });
  });
}

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