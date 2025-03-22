import 'package:indent/indent.dart';

class AppStrings {
  static const strMenu = 'Меню';
  static const strToastAddedToFavorite = 'Добавлено в избранное';
  static const strToastDeletedFromFavorite = 'Удалено из избранного';
  static const strToastCannotOpenUrl = 'Не получается открыть ссылку';
  static const strListIsEmpty = 'Список пуст';
  static const strWarningDialogTitle = 'Отправить уведомление';
  static const strToastWarningSendSuccess = 'Уведомление отправлено';
  static const strToastWarningSendError = 'Ошибка отправки уведомления';
  static const strClose = 'Закрыть';
  static const strSend = 'Отправить';
  static const strCancel = 'Отмена';
  static const strAreYouSure = 'Вы уверены?';
  static const strWillBeRemoved = 'Песня будет удалена';
  static const strYes = 'Да';
  static const strNo = 'Нет';
  static const strToastDeleted = 'Удалено';
  static const strToastDownloadSuccess = 'Аккорды сохранены в локальной базе данных и добавлены в избранное';
  static const strToastUploadDuplicate = 'Нельзя залить в облако: данный вариант аккордов поставляется вместе с приложением либо был сохранен из облака';
  static const strToastUploadSuccess = 'Успешно добавлено в облако';
  static const strToastVoteSuccess = 'Ваш голос засчитан';
  static const strStartPleaseWait = 'ПОДОЖДИТЕ…';
  static const strStartDbBuilding = 'Построение базы данных';
  static const strToastInAppError = 'Ошибка в приложении';
  static const strErrorFetchData = 'Возникла ошибка';
  static const strSettings = 'Настройки';
  static const strSave = 'Сохранить';
  static const strTheme = 'Тема:';
  static const strListenToMusic = 'Слушать музыку:';
  static const strFontScale = 'Размер шрифта:';
  static const strToastSongsNotFound = 'Песен не найдено';
  static const strToastError = 'Возникла ошибка';
  static final strAddArtistManual = """
        Чтобы добавить нового исполнителя, нажмите кнопку \"Выбрать\" и выберите папку, содержащую аккорды песен.
        Название папки должно совпадать с названием исполнителя.
        Аккорды должны находиться в текстовых файлах, названия которых совпадают с названиями песен.
        Файлы должны иметь расширение .txt
        Файлы должны находиться в корне папки.
        Все прочие файлы и подпапки будут проигнорированы.
        Пример: папка с названием \"Наутилус Помпилиус\" и внутри 2 файла: \"Крылья.txt\" и \"Матерь богов.txt\". Будут добавлены 2 песни.
        В случае, если песня с некоторым названием и исполнителем уже существует в базе приложения, она будет перезаписана.
  """.indent(4);
  static const strChoose = 'Выбрать';
  static const strSongArtist = 'Исполнитель';
  static const strSongTitle = 'Название';
  static const strSongText = 'Текст песни';
  static const strToastFillAllFields = 'Заполните все поля';

  static String strFrom(int done, int total) => "$done из $total";
}