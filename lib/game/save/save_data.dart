import 'dart:convert';

/// Everything the game keeps between runs, as one versioned document.
///
/// One JSON document rather than a scatter of keys, so the save is read and
/// written whole, and [currentVersion] can turn a later change of shape into a
/// migration instead of a wipe.
class SaveData {
  const SaveData({this.progress = const Progress()});

  /// The shape [encode] writes and [SaveData.decode] reads.
  ///
  /// Bump it, with a migration from the old shape, when an existing field
  /// changes meaning. Adding a section needs no bump: a save written before the
  /// section existed loads it with its defaults.
  static const int currentVersion = 1;

  final Progress progress;

  SaveData copyWith({Progress? progress}) =>
      SaveData(progress: progress ?? this.progress);

  String encode() =>
      jsonEncode({'version': currentVersion, 'progress': progress.toJson()});

  /// Reads a document written by [encode].
  ///
  /// Throws a [FormatException] for anything else -- a save from a newer build
  /// of the game included -- and leaves it to the caller what to fall back to.
  factory SaveData.decode(String document) {
    final json = jsonDecode(document);
    if (json is! Map<String, Object?>) {
      throw const FormatException('A save is a JSON object');
    }
    final version = json['version'];
    if (version != currentVersion) {
      throw FormatException(
        'Save version $version; this build reads version $currentVersion',
      );
    }
    return SaveData(progress: Progress.fromJson(json['progress']));
  }
}

/// How far through the deck the player has got.
class Progress {
  const Progress({this.beaten = const <int>{}});

  /// The numbers of the slides the player has won.
  final Set<int> beaten;

  bool hasBeaten(int slide) => beaten.contains(slide);

  Progress withBeaten(int slide) =>
      Progress(beaten: Set.unmodifiable({...beaten, slide}));

  Map<String, Object?> toJson() => {'beaten': beaten.toList()..sort()};

  /// Reads what [toJson] wrote. A missing section is a fresh start; anything
  /// else unexpected is a [FormatException].
  factory Progress.fromJson(Object? json) => switch (json) {
    null => const Progress(),
    {'beaten': final List<Object?> beaten}
        when beaten.every((slide) => slide is int) =>
      Progress(beaten: Set.unmodifiable(beaten.cast<int>())),
    _ => throw FormatException('Unreadable progress: ${jsonEncode(json)}'),
  };
}
