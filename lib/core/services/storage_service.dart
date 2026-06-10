import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/stream_model.dart';
import '../../data/models/user_model.dart';
import '../constants/app_constants.dart';

/// Local persistence for the user, saved streams, and app settings.
class StorageService {
  static final StorageService _instance = StorageService._();
  factory StorageService() => _instance;
  StorageService._();

  late final SharedPreferences _prefs;

  /// Must be called once before any read/write.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveUser(UserModel user) =>
      _prefs.setString(AppConstants.keyUser, jsonEncode(user.toJson()));

  UserModel? getUser() {
    final raw = _prefs.getString(AppConstants.keyUser);
    if (raw == null) return null;
    return UserModel.fromJson(jsonDecode(raw));
  }

  Future<void> clearUser() => _prefs.remove(AppConstants.keyUser);

  bool get isLoggedIn => _prefs.containsKey(AppConstants.keyUser);

  Future<void> saveStreamConfig(StreamModel stream) async {
    final list = getStreamConfigs();
    final idx = list.indexWhere((s) => s.id == stream.id);
    if (idx >= 0) {
      list[idx] = stream;
    } else {
      list.add(stream);
    }
    await _prefs.setString(AppConstants.keyStreamConfigs,
        jsonEncode(list.map((s) => s.toJson()).toList()));
  }

  List<StreamModel> getStreamConfigs() {
    final raw = _prefs.getString(AppConstants.keyStreamConfigs);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => StreamModel.fromJson(e)).toList();
  }

  Future<void> deleteStreamConfig(String id) async {
    final list = getStreamConfigs()..removeWhere((s) => s.id == id);
    await _prefs.setString(AppConstants.keyStreamConfigs,
        jsonEncode(list.map((s) => s.toJson()).toList()));
  }

  Future<void> saveActiveStreams(List<StreamModel> streams) =>
      _prefs.setString(AppConstants.keyStreams,
          jsonEncode(streams.map((s) => s.toJson()).toList()));

  List<StreamModel> getActiveStreams() {
    final raw = _prefs.getString(AppConstants.keyStreams);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list.map((e) => StreamModel.fromJson(e)).toList();
  }

  bool get isDarkMode => _prefs.getBool(AppConstants.keyThemeMode) ?? true;
  Future<void> setDarkMode(bool val) =>
      _prefs.setBool(AppConstants.keyThemeMode, val);
}
