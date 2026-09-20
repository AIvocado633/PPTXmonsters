import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The game is laid out as a 16:9 slide, so portrait is never a valid state.
///
/// Locking it takes three independent settings, and re-running `flutter create`
/// regenerates the two platform files from templates that allow portrait. These
/// tests fail loudly when that happens.
void main() {
  group('landscape lock', () {
    test('Android pins the activity, not just the Flutter runtime', () {
      // Without this the launch theme can render portrait before Dart starts.
      final manifest = File(
        'android/app/src/main/AndroidManifest.xml',
      ).readAsStringSync();
      expect(
        manifest,
        contains('android:screenOrientation="sensorLandscape"'),
        reason: 'AndroidManifest.xml lost its screenOrientation attribute',
      );
    });

    test('iOS declares no portrait orientation, on phone or iPad', () {
      final plist = File('ios/Runner/Info.plist').readAsStringSync();
      // Also catches UIInterfaceOrientationPortraitUpsideDown.
      expect(
        plist,
        isNot(contains('UIInterfaceOrientationPortrait')),
        reason: 'Info.plist lists portrait as a supported orientation',
      );
    });

    test('the app requests landscape at startup', () {
      final main = File('lib/main.dart').readAsStringSync();
      expect(main, contains('setLandscape()'));
    });
  });
}
