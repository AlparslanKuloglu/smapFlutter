import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smap/app/app_theme_mode.dart';

void main() {
  test('THEME_MODE names the three modes and nothing else', () {
    expect(AppThemeMode.of('dark'), ThemeMode.dark);
    expect(AppThemeMode.of('light'), ThemeMode.light);
    expect(AppThemeMode.of('system'), ThemeMode.system);
    expect(AppThemeMode.of(''), isNull);
    expect(AppThemeMode.of('Dark'), isNull);
  });

  test('without the define the app stays light (K9)', () {
    expect(AppThemeMode.current, ThemeMode.light);
  });
}
