import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';
import 'package:russian_rock_song_book/data/cloud/repository/cloud_repository_test_impl.dart';
import 'package:russian_rock_song_book/domain/models/cloud/order_by.dart';
import 'package:russian_rock_song_book/domain/repository/cloud/cloud_repository.dart';
import 'package:russian_rock_song_book/domain/repository/local/song_repository.dart';
import 'package:russian_rock_song_book/test/test_keys.dart';
import 'package:russian_rock_song_book/main.dart' as app;
import 'package:russian_rock_song_book/ui/strings/app_strings.dart';

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
    app.testMain();

    await tester.pumpAndSettle();

    await tester.waitFor((tester) {
      final songListTitle = find.byKey(const Key(TestKeys.songListTitle));
      expect(songListTitle, findsOneWidget);
      expect(tester.widget<Text>(songListTitle).data, 'Кино');
    });
  }

  group('menu and song list', () {
    testWidgets('app is starting correctly', (tester) async {
      await launchApp(tester);
    });

    testWidgets('menu is opening and closing with drawer button correctly',
        (tester) async {
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
        final songListTitle = find.byKey(const Key(TestKeys.songListTitle));
        expect(songListTitle, findsOneWidget);
        expect(tester.widget<Text>(songListTitle).data, 'Кино');
      });
    });

    testWidgets('menu predefined artists are displaying correctly',
        (tester) async {
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

      final menuListView = find.byKey(const Key(TestKeys.menuListView));
      await tester.waitFor((tester) {
        expect(menuListView, findsOneWidget);
      });
      final scrollable = find.byWidgetPredicate((w) => w is Scrollable);
      final menuListScrollable =
          find.descendant(of: menuListView, matching: scrollable);
      final artist1GroupText = find.text(ARTIST_1.characters.first);
      await tester.scrollUntilVisible(artist1GroupText, 500,
          scrollable: menuListScrollable);
      await tester.waitFor((tester) {
        expect(artist1GroupText, findsOneWidget);
      });
      await tester.tap(artist1GroupText);
      final artist1Text = find.text(ARTIST_1);
      await tester.waitFor((tester) {
        expect(artist1Text, findsOneWidget);
      });
    });

    testWidgets('song list for artist is opening from menu correctly',
        (tester) async {
      await launchApp(tester);

      final locateDrawer = find.byTooltip('Open navigation menu');
      await tester.tap(locateDrawer);
      await tester.pumpAndSettle();

      final menuListView = find.byKey(const Key(TestKeys.menuListView));
      await tester.waitFor((tester) {
        expect(menuListView, findsOneWidget);
      });
      final scrollable = find.byWidgetPredicate((w) => w is Scrollable);
      final menuListScrollable =
          find.descendant(of: menuListView, matching: scrollable);
      final artist1GroupText = find.text(ARTIST_1.characters.first);
      await tester.scrollUntilVisible(artist1GroupText, 500,
          scrollable: menuListScrollable);
      await tester.waitFor((tester) {
        expect(artist1GroupText, findsOneWidget);
      });
      await tester.tap(artist1GroupText);
      final artist1Text = find.text(ARTIST_1);
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

      final menuListView = find.byKey(const Key(TestKeys.menuListView));
      await tester.waitFor((tester) {
        expect(menuListView, findsOneWidget);
      });
      final scrollable = find.byWidgetPredicate((w) => w is Scrollable);
      final menuListScrollable =
          find.descendant(of: menuListView, matching: scrollable);
      final artist1GroupText = find.text(ARTIST_1.characters.first);
      await tester.scrollUntilVisible(artist1GroupText, 500,
          scrollable: menuListScrollable);
      await tester.waitFor((tester) {
        expect(artist1GroupText, findsOneWidget);
      });
      await tester.tap(artist1GroupText);
      final artist1Text = find.text(ARTIST_1);
      await tester.waitFor((tester) {
        expect(artist1Text, findsOneWidget);
      });
      await tester.tap(artist1Text);
      await tester.pumpAndSettle();

      final titleListView = find.byKey(const Key(TestKeys.titleListView));
      await tester.waitFor((tester) {
        expect(titleListView, findsOneWidget);
      });
      final titleListScrollable =
          find.descendant(of: titleListView, matching: scrollable);
      final title1Text = find.text(TITLE_1_1);
      await tester.waitFor((tester) {
        expect(title1Text, findsOneWidget);
      });
      final title2Text = find.text(TITLE_1_2);
      await tester.waitFor((tester) {
        expect(title2Text, findsNothing);
      });
      await tester.scrollUntilVisible(title2Text, 300,
          scrollable: titleListScrollable);
      await tester.waitFor((tester) {
        expect(title2Text, findsOneWidget);
      });
      final title3Text = find.text(TITLE_1_3);
      await tester.waitFor((tester) {
        expect(title3Text, findsNothing);
      });
      await tester.scrollUntilVisible(title3Text, -300,
          scrollable: titleListScrollable);
      await tester.waitFor((tester) {
        expect(title3Text, findsOneWidget);
      });
      final title4Text = find.text(TITLE_1_4);
      await tester.waitFor((tester) {
        expect(title4Text, findsNothing);
      });
      await tester.scrollUntilVisible(title4Text, -300,
          scrollable: titleListScrollable);
      await tester.waitFor((tester) {
        expect(title4Text, findsOneWidget);
      });
    });
  });

  group('song text', () {
    testWidgets('song text is opening from song list correctly',
        (tester) async {
      await launchApp(tester);

      final locateDrawer = find.byTooltip('Open navigation menu');
      await tester.tap(locateDrawer);
      await tester.pumpAndSettle();

      final menuListView = find.byKey(const Key(TestKeys.menuListView));
      await tester.waitFor((tester) {
        expect(menuListView, findsOneWidget);
      });
      final scrollable = find.byWidgetPredicate((w) => w is Scrollable);
      final menuListScrollable =
          find.descendant(of: menuListView, matching: scrollable);
      final artist1GroupText = find.text(ARTIST_1.characters.first);
      await tester.scrollUntilVisible(artist1GroupText, 500,
          scrollable: menuListScrollable);
      await tester.waitFor((tester) {
        expect(artist1GroupText, findsOneWidget);
      });
      await tester.tap(artist1GroupText);
      final artist1Text = find.text(ARTIST_1);
      await tester.waitFor((tester) {
        expect(artist1Text, findsOneWidget);
      });
      await tester.tap(artist1Text);
      await tester.pumpAndSettle();

      final titleListView = find.byKey(const Key(TestKeys.titleListView));
      await tester.waitFor((tester) {
        expect(titleListView, findsOneWidget);
      });
      final titleListScrollable =
          find.descendant(of: titleListView, matching: scrollable);
      final titleText = find.text(TITLE_1_3);
      await tester.scrollUntilVisible(titleText, 300,
          scrollable: titleListScrollable);
      await tester.waitFor((tester) {
        expect(titleText, findsOneWidget);
      });
      await tester.tap(titleText);
      await tester.pumpAndSettle();
      final songs = await GetIt.I<SongRepository>().getSongsByArtist(ARTIST_1);
      final song = songs.where((element) => element.title == TITLE_1_3).first;
      await tester.waitFor((tester) {
        final songTextTitle = find.byKey(const Key(TestKeys.songTextTitle));
        expect(songTextTitle, findsOneWidget);
        expect(tester.widget<Text>(songTextTitle).data, song.title);
        final songTextText = find.byKey(const Key(TestKeys.songTextText));
        expect(songTextText, findsOneWidget);
        expect(tester.widget<RichText>(songTextText).text.toPlainText(),
            song.text);
      });
    });

    testWidgets('song text editor is opening and closing correctly',
        (tester) async {
      await launchApp(tester);

      final locateDrawer = find.byTooltip('Open navigation menu');
      await tester.tap(locateDrawer);
      await tester.pumpAndSettle();

      final menuListView = find.byKey(const Key(TestKeys.menuListView));
      await tester.waitFor((tester) {
        expect(menuListView, findsOneWidget);
      });
      final scrollable = find.byWidgetPredicate((w) => w is Scrollable);
      final menuListScrollable =
          find.descendant(of: menuListView, matching: scrollable);
      final artist1GroupText = find.text(ARTIST_1.characters.first);
      await tester.scrollUntilVisible(artist1GroupText, 500,
          scrollable: menuListScrollable);
      await tester.waitFor((tester) {
        expect(artist1GroupText, findsOneWidget);
      });
      await tester.tap(artist1GroupText);
      final artist1Text = find.text(ARTIST_1);
      await tester.waitFor((tester) {
        expect(artist1Text, findsOneWidget);
      });
      await tester.tap(artist1Text);
      await tester.pumpAndSettle();

      final titleListView = find.byKey(const Key(TestKeys.titleListView));
      await tester.waitFor((tester) {
        expect(titleListView, findsOneWidget);
      });
      final titleListScrollable =
          find.descendant(of: titleListView, matching: scrollable);
      final titleText = find.text(TITLE_1_3);
      await tester.scrollUntilVisible(titleText, 300,
          scrollable: titleListScrollable);
      await tester.waitFor((tester) {
        expect(titleText, findsOneWidget);
      });
      await tester.tap(titleText);
      await tester.pumpAndSettle();
      final songs = await GetIt.I<SongRepository>().getSongsByArtist(ARTIST_1);
      final song = songs.where((element) => element.title == TITLE_1_3).first;
      await tester.waitFor((tester) {
        final songTextTitle = find.byKey(const Key(TestKeys.songTextTitle));
        expect(songTextTitle, findsOneWidget);
        expect(tester.widget<Text>(songTextTitle).data, song.title);
        final songTextText = find.byKey(const Key(TestKeys.songTextText));
        expect(songTextText, findsOneWidget);
        expect(tester.widget<RichText>(songTextText).text.toPlainText(),
            song.text);
      });
      final editButton = find.byKey(const Key(TestKeys.editButton));
      expect(editButton, findsOneWidget);
      await tester.tap(editButton);
      await tester.waitFor((tester) {
        final songTextEditor = find.byKey(const Key(TestKeys.songTextEditor));
        expect(songTextEditor, findsOneWidget);
        expect(find.text(song.text), findsOneWidget);
      });
      final saveButton = find.byKey(const Key(TestKeys.saveButton));
      expect(saveButton, findsOneWidget);
      await tester.tap(saveButton);
      await tester.waitFor((tester) {
        final songTextText = find.byKey(const Key(TestKeys.songTextText));
        expect(songTextText, findsOneWidget);
        expect(tester.widget<RichText>(songTextText).text.toPlainText(),
            song.text);
      });
    });

    testWidgets('song text left and right buttons are working correctly',
        (tester) async {
      await launchApp(tester);

      final locateDrawer = find.byTooltip('Open navigation menu');
      await tester.tap(locateDrawer);
      await tester.pumpAndSettle();

      final menuListView = find.byKey(const Key(TestKeys.menuListView));
      await tester.waitFor((tester) {
        expect(menuListView, findsOneWidget);
      });
      final scrollable = find.byWidgetPredicate((w) => w is Scrollable);
      final menuListScrollable =
          find.descendant(of: menuListView, matching: scrollable);
      final artist1GroupText = find.text(ARTIST_1.characters.first);
      await tester.scrollUntilVisible(artist1GroupText, 500,
          scrollable: menuListScrollable);
      await tester.waitFor((tester) {
        expect(artist1GroupText, findsOneWidget);
      });
      await tester.tap(artist1GroupText);
      final artist1Text = find.text(ARTIST_1);
      await tester.waitFor((tester) {
        expect(artist1Text, findsOneWidget);
      });
      await tester.tap(artist1Text);
      await tester.pumpAndSettle();

      final titleListView = find.byKey(const Key(TestKeys.titleListView));
      await tester.waitFor((tester) {
        expect(titleListView, findsOneWidget);
      });
      final titleListScrollable =
          find.descendant(of: titleListView, matching: scrollable);
      final titleText = find.text(TITLE_1_3);
      await tester.scrollUntilVisible(titleText, 300,
          scrollable: titleListScrollable);
      await tester.waitFor((tester) {
        expect(titleText, findsOneWidget);
      });
      await tester.tap(titleText);
      await tester.pumpAndSettle();

      final songs = await GetIt.I<SongRepository>().getSongsByArtist(ARTIST_1);
      final song1 = songs.where((element) => element.title == TITLE_1_3).first;
      final songIndex1 = songs.indexOf(song1);
      final song2 = songs[songIndex1 + 1];

      final leftButton = find.byKey(const Key(TestKeys.leftButton));
      final rightButton = find.byKey(const Key(TestKeys.rightButton));

      await tester.waitFor((tester) {
        final songTextTitle = find.byKey(const Key(TestKeys.songTextTitle));
        expect(songTextTitle, findsOneWidget);
        expect(tester.widget<Text>(songTextTitle).data, song1.title);
        final songTextText = find.byKey(const Key(TestKeys.songTextText));
        expect(songTextText, findsOneWidget);
        expect(tester.widget<RichText>(songTextText).text.toPlainText(),
            song1.text);
      });

      await tester.tap(rightButton);
      await tester.waitFor((tester) {
        final songTextTitle = find.byKey(const Key(TestKeys.songTextTitle));
        expect(songTextTitle, findsOneWidget);
        expect(tester.widget<Text>(songTextTitle).data, song2.title);
        final songTextText = find.byKey(const Key(TestKeys.songTextText));
        expect(songTextText, findsOneWidget);
        expect(tester.widget<RichText>(songTextText).text.toPlainText(),
            song2.text);
      });

      await tester.tap(leftButton);
      await tester.waitFor((tester) {
        final songTextTitle = find.byKey(const Key(TestKeys.songTextTitle));
        expect(songTextTitle, findsOneWidget);
        expect(tester.widget<Text>(songTextTitle).data, song1.title);
        final songTextText = find.byKey(const Key(TestKeys.songTextText));
        expect(songTextText, findsOneWidget);
        expect(tester.widget<RichText>(songTextText).text.toPlainText(),
            song1.text);
      });
    });

    testWidgets('adding and removing from favorite is working correctly',
        (tester) async {
      await launchApp(tester);

      final locateDrawer = find.byTooltip('Open navigation menu');
      await tester.tap(locateDrawer);
      await tester.pumpAndSettle();

      final menuListView = find.byKey(const Key(TestKeys.menuListView));
      await tester.waitFor((tester) {
        expect(menuListView, findsOneWidget);
      });
      final scrollable = find.byWidgetPredicate((w) => w is Scrollable);
      final menuListScrollable =
          find.descendant(of: menuListView, matching: scrollable);
      final artist1GroupText = find.text(ARTIST_1.characters.first);
      await tester.scrollUntilVisible(artist1GroupText, 500,
          scrollable: menuListScrollable);
      await tester.waitFor((tester) {
        expect(artist1GroupText, findsOneWidget);
      });
      await tester.tap(artist1GroupText);
      final artist1Text = find.text(ARTIST_1);
      await tester.waitFor((tester) {
        expect(artist1Text, findsOneWidget);
      });
      await tester.tap(artist1Text);
      await tester.pumpAndSettle();

      final titleListView = find.byKey(const Key(TestKeys.titleListView));
      await tester.waitFor((tester) {
        expect(titleListView, findsOneWidget);
      });
      final titleListScrollable =
          find.descendant(of: titleListView, matching: scrollable);
      final titleText = find.text(TITLE_1_3);
      await tester.scrollUntilVisible(titleText, 300,
          scrollable: titleListScrollable);
      await tester.waitFor((tester) {
        expect(titleText, findsOneWidget);
      });
      await tester.tap(titleText);
      await tester.pumpAndSettle();

      await tester.waitFor((tester) {
        final songTextTitle = find.byKey(const Key(TestKeys.songTextTitle));
        expect(songTextTitle, findsOneWidget);
        expect(tester.widget<Text>(songTextTitle).data, TITLE_1_3);
      });

      final addToFavoriteButton =
          find.byKey(const Key(TestKeys.addToFavoriteButton));
      final deleteFromFavoriteButton =
          find.byKey(const Key(TestKeys.deleteFromFavoriteButton));

      expect(addToFavoriteButton, findsOneWidget);
      await tester.tap(addToFavoriteButton);

      await tester.waitFor((tester) {
        expect(addToFavoriteButton, findsNothing);
        expect(deleteFromFavoriteButton, findsOneWidget);
      });

      await tester.tap(deleteFromFavoriteButton);

      await tester.waitFor((tester) {
        expect(deleteFromFavoriteButton, findsNothing);
        expect(addToFavoriteButton, findsOneWidget);
      });
    });
  });

  group('cloud search', () {
    testWidgets('cloud search is opening from menu correctly', (tester) async {
      await launchApp(tester);

      final locateDrawer = find.byTooltip('Open navigation menu');
      await tester.tap(locateDrawer);
      await tester.pumpAndSettle();

      final menuListView = find.byKey(const Key(TestKeys.menuListView));
      await tester.waitFor((tester) {
        expect(menuListView, findsOneWidget);
      });
      final artistCloudSearchText = find.text(SongRepository.artistCloudSearch);
      await tester.waitFor((tester) {
        expect(artistCloudSearchText, findsOneWidget);
      });
      await tester.tap(artistCloudSearchText);
      await tester.pumpAndSettle();

      final cloudRepo = GetIt.I<CloudRepository>() as CloudRepositoryTestImpl;

      final songs = await cloudRepo.search('', OrderBy.byIdDesc.orderByStr);

      await tester.waitFor((tester) {
        expect(find.text(songs[0].visibleTitleWithRating(0, 0)), findsOneWidget);
        expect(find.text(songs[1].visibleTitleWithRating(0, 0)), findsOneWidget);
        expect(find.text(songs[2].visibleTitleWithRating(0, 0)), findsOneWidget);
      });
    });

    testWidgets('cloud search offline is working correctly', (tester) async {
      await launchApp(tester);

      final locateDrawer = find.byTooltip('Open navigation menu');
      await tester.tap(locateDrawer);
      await tester.pumpAndSettle();

      final menuListView = find.byKey(const Key(TestKeys.menuListView));
      await tester.waitFor((tester) {
        expect(menuListView, findsOneWidget);
      });
      final artistCloudSearchText = find.text(SongRepository.artistCloudSearch);
      await tester.waitFor((tester) {
        expect(artistCloudSearchText, findsOneWidget);
      });
      await tester.tap(artistCloudSearchText);
      await tester.pumpAndSettle();

      final cloudRepo = GetIt.I<CloudRepository>() as CloudRepositoryTestImpl;

      final songs = await cloudRepo.search('', OrderBy.byIdDesc.orderByStr);

      await tester.waitFor((tester) {
        expect(find.text(songs[0].visibleTitleWithRating(0, 0)), findsOneWidget);
        expect(find.text(songs[1].visibleTitleWithRating(0, 0)), findsOneWidget);
        expect(find.text(songs[2].visibleTitleWithRating(0, 0)), findsOneWidget);
      });

      cloudRepo.isOnline = false;

      final cloudSearchButton = find.byKey(const Key(TestKeys.cloudSearchButton));
      await tester.tap(cloudSearchButton);
      await tester.pumpAndSettle();

      await tester.waitFor((tester) {
        expect(find.text(AppStrings.strErrorFetchData), findsOneWidget);
      });

      cloudRepo.isOnline = true;
    });

    testWidgets('cloud search normal query is working correctly', (tester) async {
      await launchApp(tester);

      final locateDrawer = find.byTooltip('Open navigation menu');
      await tester.tap(locateDrawer);
      await tester.pumpAndSettle();

      final menuListView = find.byKey(const Key(TestKeys.menuListView));
      await tester.waitFor((tester) {
        expect(menuListView, findsOneWidget);
      });
      final artistCloudSearchText = find.text(SongRepository.artistCloudSearch);
      await tester.waitFor((tester) {
        expect(artistCloudSearchText, findsOneWidget);
      });
      await tester.tap(artistCloudSearchText);
      await tester.pumpAndSettle();

      final cloudRepo = GetIt.I<CloudRepository>() as CloudRepositoryTestImpl;

      final songs = await cloudRepo.search('', OrderBy.byIdDesc.orderByStr);

      await tester.waitFor((tester) {
        expect(find.text(songs[0].visibleTitleWithRating(0, 0)), findsOneWidget);
        expect(find.text(songs[1].visibleTitleWithRating(0, 0)), findsOneWidget);
        expect(find.text(songs[2].visibleTitleWithRating(0, 0)), findsOneWidget);
      });

      final cloudSearchTextField = find.byKey(const Key(TestKeys.cloudSearchTextField));
      await tester.enterText(cloudSearchTextField, 'Ло');
      final cloudSearchButton = find.byKey(const Key(TestKeys.cloudSearchButton));
      await tester.tap(cloudSearchButton);
      await tester.pumpAndSettle();

      final songs2 = await cloudRepo.search('Ло', OrderBy.byIdDesc.orderByStr);

      await tester.waitFor((tester) {
        expect(find.text(songs2[0].visibleTitleWithRating(0, 0)), findsOneWidget);
        expect(find.text(songs2[1].visibleTitleWithRating(0, 0)), findsOneWidget);
        expect(find.text(songs2[2].visibleTitleWithRating(0, 0)), findsOneWidget);
      });
    });

    testWidgets('cloud search ordering by title is working correctly', (tester) async {
      await launchApp(tester);

      final locateDrawer = find.byTooltip('Open navigation menu');
      await tester.tap(locateDrawer);
      await tester.pumpAndSettle();

      final menuListView = find.byKey(const Key(TestKeys.menuListView));
      await tester.waitFor((tester) {
        expect(menuListView, findsOneWidget);
      });
      final artistCloudSearchText = find.text(SongRepository.artistCloudSearch);
      await tester.waitFor((tester) {
        expect(artistCloudSearchText, findsOneWidget);
      });
      await tester.tap(artistCloudSearchText);
      await tester.pumpAndSettle();

      final cloudRepo = GetIt.I<CloudRepository>() as CloudRepositoryTestImpl;

      final songs = await cloudRepo.search('', OrderBy.byIdDesc.orderByStr);

      await tester.waitFor((tester) {
        expect(find.text(songs[0].visibleTitleWithRating(0, 0)), findsOneWidget);
        expect(find.text(songs[1].visibleTitleWithRating(0, 0)), findsOneWidget);
        expect(find.text(songs[2].visibleTitleWithRating(0, 0)), findsOneWidget);
      });

      final orderByIdDesc = find.text(OrderBy.byIdDesc.orderByRus);
      await tester.tap(orderByIdDesc);
      await tester.pumpAndSettle();
      final orderByTitle = find.text(OrderBy.byTitle.orderByRus);
      await tester.waitFor((tester) {
        expect(orderByTitle, findsOneWidget);
      });
      await tester.tap(orderByTitle);
      await tester.pumpAndSettle();

      final songs2 = await cloudRepo.search('', OrderBy.byTitle.orderByStr);

      await tester.waitFor((tester) {
        expect(find.text(songs2[0].visibleTitleWithRating(0, 0)), findsOneWidget);
        expect(find.text(songs2[1].visibleTitleWithRating(0, 0)), findsOneWidget);
        expect(find.text(songs2[2].visibleTitleWithRating(0, 0)), findsOneWidget);
      });
    });

    testWidgets('cloud search ordering by artist is working correctly', (tester) async {
      await launchApp(tester);

      final locateDrawer = find.byTooltip('Open navigation menu');
      await tester.tap(locateDrawer);
      await tester.pumpAndSettle();

      final menuListView = find.byKey(const Key(TestKeys.menuListView));
      await tester.waitFor((tester) {
        expect(menuListView, findsOneWidget);
      });
      final artistCloudSearchText = find.text(SongRepository.artistCloudSearch);
      await tester.waitFor((tester) {
        expect(artistCloudSearchText, findsOneWidget);
      });
      await tester.tap(artistCloudSearchText);
      await tester.pumpAndSettle();

      final cloudRepo = GetIt.I<CloudRepository>() as CloudRepositoryTestImpl;

      final songs = await cloudRepo.search('', OrderBy.byIdDesc.orderByStr);

      await tester.waitFor((tester) {
        expect(find.text(songs[0].visibleTitleWithRating(0, 0)), findsOneWidget);
        expect(find.text(songs[1].visibleTitleWithRating(0, 0)), findsOneWidget);
        expect(find.text(songs[2].visibleTitleWithRating(0, 0)), findsOneWidget);
      });

      final orderByIdDesc = find.text(OrderBy.byIdDesc.orderByRus);
      await tester.tap(orderByIdDesc);
      await tester.pumpAndSettle();
      final orderByArtist = find.text(OrderBy.byArtist.orderByRus);
      await tester.waitFor((tester) {
        expect(orderByArtist, findsOneWidget);
      });
      await tester.tap(orderByArtist);
      await tester.pumpAndSettle();

      final songs2 = await cloudRepo.search('', OrderBy.byArtist.orderByStr);

      await tester.waitFor((tester) {
        expect(find.text(songs2[0].visibleTitleWithRating(0, 0)), findsOneWidget);
        expect(find.text(songs2[1].visibleTitleWithRating(0, 0)), findsOneWidget);
        expect(find.text(songs2[2].visibleTitleWithRating(0, 0)), findsOneWidget);
      });
    });

    testWidgets('cloud search query with empty result is working correctly', (tester) async {
      await launchApp(tester);

      final locateDrawer = find.byTooltip('Open navigation menu');
      await tester.tap(locateDrawer);
      await tester.pumpAndSettle();

      final menuListView = find.byKey(const Key(TestKeys.menuListView));
      await tester.waitFor((tester) {
        expect(menuListView, findsOneWidget);
      });
      final artistCloudSearchText = find.text(SongRepository.artistCloudSearch);
      await tester.waitFor((tester) {
        expect(artistCloudSearchText, findsOneWidget);
      });
      await tester.tap(artistCloudSearchText);
      await tester.pumpAndSettle();

      final cloudRepo = GetIt.I<CloudRepository>() as CloudRepositoryTestImpl;

      final songs = await cloudRepo.search('', OrderBy.byIdDesc.orderByStr);

      await tester.waitFor((tester) {
        expect(find.text(songs[0].visibleTitleWithRating(0, 0)), findsOneWidget);
        expect(find.text(songs[1].visibleTitleWithRating(0, 0)), findsOneWidget);
        expect(find.text(songs[2].visibleTitleWithRating(0, 0)), findsOneWidget);
      });

      final cloudSearchTextField = find.byKey(const Key(TestKeys.cloudSearchTextField));
      await tester.enterText(cloudSearchTextField, 'Хзщшг');
      final cloudSearchButton = find.byKey(const Key(TestKeys.cloudSearchButton));
      await tester.tap(cloudSearchButton);
      await tester.pumpAndSettle();

      await tester.waitFor((tester) {
        expect(find.text(AppStrings.strListIsEmpty), findsOneWidget);
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
