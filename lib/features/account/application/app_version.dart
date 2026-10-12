import 'package:flutter/foundation.dart';

/// The version of the installed build (pano 9.1 kare 2: "Sürüm 3.0.0
/// (300)"), read from the package info at run time and never typed in.
@immutable
class AppVersion {
  const AppVersion({required this.version, this.build = ''});

  /// "3.0.0".
  final String version;

  /// "300"; empty when the platform gives none.
  final String build;

  /// Whether there is a build number to write in brackets.
  bool get hasBuild => build.isNotEmpty;

  /// `3.0.0 (300)`, or `3.0.0` without a build: what a support mail and the
  /// copied version carry.
  String get plain => hasBuild ? '$version ($build)' : version;

  @override
  bool operator ==(Object other) =>
      other is AppVersion && other.version == version && other.build == build;

  @override
  int get hashCode => Object.hash(version, build);
}
