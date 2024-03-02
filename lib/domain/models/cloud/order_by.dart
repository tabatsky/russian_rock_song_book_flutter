enum OrderBy { byIdDesc, byArtist, byTitle }

extension ToStringExtension on OrderBy {
  String get orderByStr {
    switch (this) {
      case OrderBy.byIdDesc:
        return 'byIdDesc';
      case OrderBy.byArtist:
        return 'byArtist';
      case OrderBy.byTitle:
        return 'byTitle';
    }
  }

  String get orderByRus {
    switch (this) {
      case OrderBy.byIdDesc:
        return 'Последние добавленные';
      case OrderBy.byArtist:
        return 'По исполнителю';
      case OrderBy.byTitle:
        return 'По названию';
    }
  }
}

class OrderByStrings {
  static OrderBy parseFromString(String orderByStr) =>
    OrderBy.values.firstWhere((element) => element.orderByStr == orderByStr);

  static List<String> rusValues() => OrderBy.values.map((e) => e.orderByRus).toList();
}