import 'package:shared_preferences/shared_preferences.dart';

/// Where the save lives between runs.
///
/// The only part of saving that touches the platform, so it stays as thin as a
/// string in and a string out. Everything that can go wrong with the contents
/// is dealt with above it, in plain Dart.
abstract interface class SaveStore {
  /// The stored document, or null if nothing has been saved yet.
  Future<String?> read();

  Future<void> write(String document);
}

/// Keeps the save in memory, so nothing outlives the game. What tests use.
class InMemorySaveStore implements SaveStore {
  InMemorySaveStore([this.document]);

  /// The stored document, open to tests to seed and inspect.
  String? document;

  @override
  Future<String?> read() async => document;

  @override
  Future<void> write(String document) async => this.document = document;
}

/// Keeps the save on the device, in the platform's own preferences storage
/// through `shared_preferences` -- on Windows, a JSON file under %APPDATA%.
class SharedPreferencesSaveStore implements SaveStore {
  /// The key the whole save document is stored under.
  static const key = 'save';

  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();

  @override
  Future<String?> read() => _preferences.getString(key);

  @override
  Future<void> write(String document) => _preferences.setString(key, document);
}
