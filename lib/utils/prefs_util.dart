import 'package:shared_preferences/shared_preferences.dart';

class PrefsUtil {
  PrefsUtil._internal();

  static final PrefsUtil _instance = PrefsUtil._internal();
  factory PrefsUtil() => _instance;

  late SharedPreferences _prefs;
  bool _initialized = false;

  static Future<void> ensureInitialized() async {
    if (_instance._initialized) return;
    await _instance._init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    _saveBeginDate();
    _initialized = true;
  }

  void _saveBeginDate() {
    try {
      final beginDate = _prefs.getString('beginDate');
      if (beginDate == null) {
        _prefs.setString('beginDate', DateTime.now().toIso8601String());
      }
    } catch (_) {}
  }

  bool get isFirstOpen {
    if (!_initialized) return true;
    return _prefs.getBool('isFirstOpen') ?? false;
  }

  Future<bool> setIsFirstOpen(bool value) async {
    await ensureInitialized();
    return _prefs.setBool('isFirstOpen', value);
  }

  String get language {
    if (!_initialized) return 'system';
    return _prefs.getString('language') ?? 'system';
  }

  Future<bool> setLanguage(String value) async {
    await ensureInitialized();
    return _prefs.setString('language', value);
  }

  int get themeMode {
    if (!_initialized) return 0;
    return _prefs.getInt('themeMode') ?? 0;
  }

  Future<bool> setThemeMode(int value) async {
    await ensureInitialized();
    return _prefs.setInt('themeMode', value);
  }

  String get oauth {
    if (!_initialized) return '';
    return _prefs.getString('oauth') ?? '';
  }

  Future<bool> setOauth(String value) async {
    await ensureInitialized();
    return _prefs.setString('oauth', value);
  }

  DateTime? get beginDate {
    if (!_initialized) return null;
    final beginDateStr = _prefs.getString('beginDate');
    if (beginDateStr == null) return null;
    return DateTime.tryParse(beginDateStr);
  }
}
