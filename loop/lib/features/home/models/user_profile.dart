import 'package:flutter/foundation.dart';

/// The signed-in person.
///
/// [avatarUrl] is nullable on purpose: the Home has to render for someone who
/// has never uploaded a picture, which is most people on day one.
@immutable
class UserProfile {
  const UserProfile({
    required this.id,
    required this.displayName,
    this.avatarUrl,
    this.isOnline = false,
  });

  /// Someone the app does not know yet: the first frame, before the profile
  /// has loaded. Named rather than nullable so the header has one state to
  /// render instead of a null check.
  static const UserProfile anonymous = UserProfile(id: '', displayName: '');

  final String id;
  final String displayName;
  final String? avatarUrl;
  final bool isOnline;

  /// What the greeting uses. "Jorge Silva" greets as "Jorge"; a single-word
  /// name greets as itself.
  String get firstName {
    final String trimmed = displayName.trim();
    if (trimmed.isEmpty) return '';
    return trimmed.split(RegExp(r'\s+')).first;
  }

  /// Fallback for the avatar when there is no image. One letter, not two:
  /// a surname is not always present and "J" reads better than "J?". Taken as
  /// a rune rather than a code unit so a name outside the BMP does not come
  /// back as half a character.
  String get initial => firstName.isEmpty
      ? '?'
      : String.fromCharCodes(firstName.runes.take(1)).toUpperCase();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          other.id == id &&
          other.displayName == displayName &&
          other.avatarUrl == avatarUrl &&
          other.isOnline == isOnline;

  @override
  int get hashCode => Object.hash(id, displayName, avatarUrl, isOnline);
}
