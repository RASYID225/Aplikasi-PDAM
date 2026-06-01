import 'dart:convert';
import 'package:pdam_apps/Models/User_login.dart';
import 'package:pdam_apps/Models/Response_data_map.dart';
import 'package:pdam_apps/Services/Url.dart' as url;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserService {

  // ✅ Langsung pakai OWNER_TOKEN dari Url.dart
  String get _ownerToken => url.OWNER_TOKEN;

  // -----------------------------------------------
  // REGISTER ADMIN
  // POST /admins
  // Header: app-key = owner_token
  // Body JSON: username, password, name, phone
  // -----------------------------------------------
  Future<ResponseDataMap> registerUser(Map<String, String> data) async {
    try {
      
      final uri = Uri.parse("${url.BASEURL}/admins");

      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "app-key": _ownerToken,
        },
        body: jsonEncode({
          "username": data["username"],
          "password": data["password"],
          "name":     data["name"],
          "phone":    data["phone"],
        }),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseBody['success'] == true) {
          return ResponseDataMap(
            status: true,
            message: "Sukses mendaftarkan admin",
            data: responseBody,
          );
        } else {
          return ResponseDataMap(
            status: false,
            message: responseBody['message']?.toString() ?? 'Registrasi gagal',
          );
        }
      } else if (response.statusCode == 401) {
        return ResponseDataMap(
          status: false,
          message: "Unauthorized: owner_token tidak valid atau belum disimpan.",
        );
      } else {
        return ResponseDataMap(
          status: false,
          message: "Gagal register (HTTP ${response.statusCode}): ${responseBody['message'] ?? ''}",
        );
      }
    } catch (e) {
      return ResponseDataMap(
        status: false,
        message: "Error koneksi: $e",
      );
    }
  }

  // -----------------------------------------------
  // LOGIN (Admin & Customer)
  // POST /auth
  // Header: app-key = owner_token
  // Body JSON: username, password
  // Response: { success, token, role }
  // -----------------------------------------------
  Future<ResponseDataMap> loginUser(Map<String, String> data) async {
    try {
      
      final uri = Uri.parse("${url.BASEURL}/auth");

      final response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "app-key": _ownerToken,
        },
        body: jsonEncode({
          "username": data["username"],
          "password": data["password"],
        }),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseBody['success'] == true) {
          // ✅ Simpan pakai UserLogin model baru — key sinkron!
          UserLogin userLogin = UserLogin(
            status: true,
            message: responseBody['message'],
            token: responseBody['token'],  // JWT token
            role: responseBody['role'],    // "ADMIN" atau "CUSTOMER"
          );
          await userLogin.saveToPrefs();   // ✅ key: auth_token & user_role

          return ResponseDataMap(
            status: true,
            message: "Sukses Login",
            data: responseBody,
          );
        } else {
          return ResponseDataMap(
            status: false,
            message: responseBody['message'] ?? 'Username atau password salah',
          );
        }
      } else if (response.statusCode == 401) {
        return ResponseDataMap(
          status: false,
          message: "Username atau password salah",
        );
      } else {
        return ResponseDataMap(
          status: false,
          message: "Gagal login (HTTP ${response.statusCode})",
        );
      }
    } catch (e) {
      return ResponseDataMap(
        status: false,
        message: "Error koneksi: $e",
      );
    }
  }

  // -----------------------------------------------
  // REGISTER APP OWNER (jalankan SEKALI saja!)
  // POST /app-owners
  // Body JSON: email, password
  // Simpan owner_token ke SharedPreferences
  // -----------------------------------------------
  Future<ResponseDataMap> registerAppOwner(String email, String password) async {
    try {
      final uri = Uri.parse("${url.BASEURL}/app-owners");

      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      final responseBody = jsonDecode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          responseBody['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        // ✅ Simpan dengan key 'owner_token' — khusus App Owner, tidak bentrok
        await prefs.setString('owner_token', responseBody['data']['owner_token']);

        return ResponseDataMap(
          status: true,
          message: "App Owner terdaftar",
          data: responseBody,
        );
      }

      return ResponseDataMap(
        status: false,
        message: responseBody['message']?.toString() ?? 'Gagal daftar App Owner',
      );
    } catch (e) {
      return ResponseDataMap(
        status: false,
        message: "Error: $e",
      );
    }
  }

  // -----------------------------------------------
  // LOGIN APP OWNER (kalau sudah pernah daftar)
  // POST /app-owners/auth
  // -----------------------------------------------
  Future<ResponseDataMap> loginAppOwner(String email, String password) async {
    try {
      final uri = Uri.parse("${url.BASEURL}/app-owners/auth");

      final response = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('owner_token', responseBody['data']['owner_token']);

        return ResponseDataMap(
          status: true,
          message: "Login App Owner sukses",
          data: responseBody,
        );
      }

      return ResponseDataMap(
        status: false,
        message: responseBody['message']?.toString() ?? 'Gagal login App Owner',
      );
    } catch (e) {
      return ResponseDataMap(
        status: false,
        message: "Error: $e",
      );
    }
  }
}