import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

Future<void> loadHtmlFromAssets(WebViewController controller, String assetPath) async {
  final fileText = await rootBundle.loadString(assetPath);
  await controller.loadHtmlString(fileText);
}

ProfileData? userFromPrefs(SharedPreferences prefs) {
  final String? jsonString = prefs.getString('avatar');
  if (jsonString == null || jsonString.isEmpty) return null;

  final Map<String, dynamic> json = jsonDecode(jsonString);
  if (json.isNotEmpty) {
    final avatarUrl = json['data']['url'];
    final avatarId = avatarUrl?.split('/').last.replaceAll('.glb', '').trim();
    return ProfileData(avatarId, avatarUrl: avatarUrl);
  }
  return null;
}

class ProfileData {
  ProfileData(this.avatarId, {this.name, this.avatarUrl, this.email});
  final String? avatarId;
  final String? name;
  final String? email;
  final String? avatarUrl;
}
