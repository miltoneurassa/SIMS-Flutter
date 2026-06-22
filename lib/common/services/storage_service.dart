import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import '../models/user_model.dart';

class StorageService {
  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();
  StorageService._();

  Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConfig.simsPreference, jsonEncode(user.toMap()));
  }

  Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(AppConfig.simsPreference);
    if (data == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(data));
    } catch (_) {
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    final user = await getUser();
    return user != null && user.userId.isNotEmpty;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConfig.simsPreference);
  }

  Future<void> setSiteUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConfig.siteUrlKey, url);
  }

  Future<String> getSiteUrl() async {
    final prefs = await SharedPreferences.getInstance();
    String url = prefs.getString(AppConfig.siteUrlKey) ?? '';
    if (url.trim().isEmpty) return '';
    url = url.trim();
    if (!url.endsWith('/')) url = '$url/';
    if (!url.contains('index.php')) url = '${url}index.php/';
    return url;
  }

  Future<void> setCollegeName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConfig.collegeNameKey, name);
  }

  Future<String> getCollegeName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConfig.collegeNameKey) ?? '';
  }
}
