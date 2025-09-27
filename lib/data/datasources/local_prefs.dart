// lib/data/datasources/local_prefs.dart
// Unified SharedPreferences wrapper for AIMentai

import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class LocalPrefs {
  LocalPrefs._();
  static final LocalPrefs instance = LocalPrefs._();

  static const String kLoggedIn = 'logged_in';
  static const String kEmail = 'email';
  static const String kPacks30 = 'packs_30';

  SharedPreferences? _sp;
  Completer<void>? _initCompleter;

  Future<void> ensureReady() async {
    if (_sp != null) return;
    if (_initCompleter != null) return _initCompleter!.future;
    _initCompleter = Completer<void>();
    _sp = await SharedPreferences.getInstance();
    _initCompleter!.complete();
  }

  // ------- Auth -------
  Future<bool> getLoggedIn() async {
    await ensureReady();
    return _sp!.getBool(kLoggedIn) ?? false;
    }

  Future<void> setLoggedIn(bool value) async {
    await ensureReady();
    await _sp!.setBool(kLoggedIn, value);
  }

  Future<String?> getEmail() async {
    await ensureReady();
    return _sp!.getString(kEmail);
  }

  Future<void> setEmail(String? email) async {
    await ensureReady();
    if (email == null) {
      await _sp!.remove(kEmail);
    } else {
      await _sp!.setString(kEmail, email);
    }
  }

  Future<void> clearAuth() async {
    await ensureReady();
    await _sp!.remove(kLoggedIn);
    await _sp!.remove(kEmail);
  }

  // ------- Packs (30-min units) -------
  Future<int> getPacks30() async {
    await ensureReady();
    return _sp!.getInt(kPacks30) ?? 0;
  }

  Future<void> setPacks30(int value) async {
    await ensureReady();
    if (value < 0) value = 0;
    await _sp!.setInt(kPacks30, value);
  }

  Future<int> addPacks30(int delta) async {
    await ensureReady();
    final cur = _sp!.getInt(kPacks30) ?? 0;
    final next = (cur + delta).clamp(0, 1<<31);
    await _sp!.setInt(kPacks30, next);
    return next;
  }

  // ------- Generic helpers (optional) -------
  Future<bool?> getBool(String key) async { await ensureReady(); return _sp!.getBool(key); }
  Future<int?> getInt(String key) async { await ensureReady(); return _sp!.getInt(key); }
  Future<String?> getString(String key) async { await ensureReady(); return _sp!.getString(key); }
  Future<void> setBool(String key, bool v) async { await ensureReady(); await _sp!.setBool(key, v); }
  Future<void> setInt(String key, int v) async { await ensureReady(); await _sp!.setInt(key, v); }
  Future<void> setString(String key, String v) async { await ensureReady(); await _sp!.setString(key, v); }
}
