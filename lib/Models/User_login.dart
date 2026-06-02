import 'package:shared_preferences/shared_preferences.dart';

class UserLogin {
  bool? status;
  String? message;
  String? token;
  String? role;
  UserLogin({this.status, this.message, this.token, this.role});

  Future<void> saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("login_status", status ?? false);
    await prefs.setString("login_message", message ?? '');
    await prefs.setString("auth_token", token ?? '');
    await prefs.setString("user_role", role ?? '');
  }

  // Baca data login dari SharedPreferences
  static Future<UserLogin> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return UserLogin(
      status: prefs.getBool("login_status"),
      message: prefs.getString("login_message"),
      token: prefs.getString("auth_token"),
      role: prefs.getString("user_role"),
    );
  }

  // Hapus data login (saat logout)
  static Future<void> clearPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("login_status");
    await prefs.remove("login_message");
    await prefs.remove("auth_token");
    await prefs.remove("user_role");
  }

  // Cek apakah user sudah login
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("auth_token") ?? '';
    return token.isNotEmpty;
  }

  // Ambil token JWT (untuk header Authorization request lain)
  static Future<String> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("auth_token") ?? '';
  }

  // Ambil role user
  static Future<String> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("user_role") ?? '';
  }

  Future getUserLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return UserLogin(
      status: prefs.getBool("login_status"),
      message: prefs.getString("login_message"),
      token: prefs.getString("auth_token"),
      role: prefs.getString("user_role"),
    );
  }
}
