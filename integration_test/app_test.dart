import 'dart:async';

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
  Future<void> launchApp(WidgetTester tester) async {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    app.main();

    await tester.pumpAndSettle();

    await tester.waitFor((tester) {
      final songListTitle = find.byKey(const Key('song_list_title'));
      expect(songListTitle, findsOneWidget);
      expect(tester.widget<Text>(songListTitle).data, 'Кино');
    });
  }

  group('menu and song list', () {
    testWidgets('app is starting correctly', (tester) async {
      await launchApp(tester);
    });

    testWidgets('menu is opening and closing with drawer button correctly', (tester) async {
      await launchApp(tester);

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
      await launchApp(tester);

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
      await launchApp(tester);

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
      await launchApp(tester);

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
      await tester.scrollUntilVisible(artist1Text, 300, scrollable: menuListScrollable);
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

    testWidgets('song list is scrolling correctly', (tester) async {
      await launchApp(tester);

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
      await tester.scrollUntilVisible(artist1Text, 300, scrollable: menuListScrollable);
      await tester.waitFor((tester) {
        expect(artist1Text, findsOneWidget);
      });
      await tester.tap(artist1Text);
      await tester.pumpAndSettle();

      final titleListView = find.byKey(const Key('title_list_view'));
      await tester.waitFor((tester) {
        expect(titleListView, findsOneWidget);
      });
      final titleListScrollable = find.descendant(of: titleListView, matching: scrollable);
      final title1Text = find.text(TITLE_1_1);
      await tester.waitFor((tester) {
        expect(title1Text, findsOneWidget);
      });
      final title2Text = find.text(TITLE_1_2);
      await tester.waitFor((tester) {
        expect(title2Text, findsNothing);
      });
      await tester.scrollUntilVisible(title2Text, 300, scrollable: titleListScrollable);
      await tester.waitFor((tester) {
        expect(title2Text, findsOneWidget);
      });
      final title3Text = find.text(TITLE_1_3);
      await tester.waitFor((tester) {
        expect(title3Text, findsNothing);
      });
      await tester.scrollUntilVisible(title3Text, -300, scrollable: titleListScrollable);
      await tester.waitFor((tester) {
        expect(title3Text, findsOneWidget);
      });
      final title4Text = find.text(TITLE_1_4);
      await tester.waitFor((tester) {
        expect(title4Text, findsNothing);
      });
      await tester.scrollUntilVisible(title4Text, -300, scrollable: titleListScrollable);
      await tester.waitFor((tester) {
        expect(title4Text, findsOneWidget);
      });
    });
  });

  group('song text', () {
    testWidgets('song text is opening from song list correctly', (tester) async {
      await launchApp(tester);

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
      await tester.scrollUntilVisible(artist1Text, 300, scrollable: menuListScrollable);
      await tester.waitFor((tester) {
        expect(artist1Text, findsOneWidget);
      });
      await tester.tap(artist1Text);
      await tester.pumpAndSettle();

      final titleListView = find.byKey(const Key('title_list_view'));
      await tester.waitFor((tester) {
        expect(titleListView, findsOneWidget);
      });
      final titleListScrollable = find.descendant(of: titleListView, matching: scrollable);
      final titleText = find.text(TITLE_1_3);
      await tester.scrollUntilVisible(titleText, 300, scrollable: titleListScrollable);
      await tester.waitFor((tester) {
        expect(titleText, findsOneWidget);
      });
      await tester.waitFor((tester) {
        expect(titleText, findsOneWidget);
      });
      await tester.tap(titleText);
      await tester.pumpAndSettle();
      final songs = await GetIt.I<SongRepository>().getSongsByArtist(ARTIST_1);
      final song = songs.where((element) => element.title == TITLE_1_3).first;
      await tester.waitFor((tester) {
        final songTextTitle = find.byKey(const Key('song_text_title'));
        expect(songTextTitle, findsOneWidget);
        expect(tester.widget<Text>(songTextTitle).data, song.title);
        final songTextText = find.byKey(const Key('song_text_text'));
        expect(songTextText, findsOneWidget);
        expect(tester.widget<Text>(songTextText).data, song.text);
      });
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