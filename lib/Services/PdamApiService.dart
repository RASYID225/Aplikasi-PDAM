import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:pdam_apps/Models/User_login.dart';

class ApiService {
  // ✅ Base URL persis dari dokumen Soal UKL (Server Sekolah)
  static const String baseUrl = "https://learn.smktelkom-mlg.sch.id/pdam";

  // ⚠️ JANGAN LUPA GANTI INI dengan owner token dari Postman
  static const String appKey = "ce9c5c9467ea35aa30b6e42e81e515cf7d95fb73";

  // =================================================================
  // HELPER: Otomatis ambil token dari SharedPreferences biar UI nggak repot
  // =================================================================
  static Future<Map<String, String>> _getHeaders() async {
    final token = await UserLogin.getAuthToken();

    return {
      "Content-Type": "application/json",
      "app-key": appKey,
      if (token.isNotEmpty) "Authorization": "Bearer $token",
    };
  }

  static Map<String, dynamic> _parseJsonResponse(http.Response res) {
    try {
      final body = jsonDecode(res.body);
      if (body is Map<String, dynamic>) return body;
      return {"success": false, "message": "Format respons server tidak valid"};
    } catch (_) {
      return {
        "success": false,
        "message": "Respons server tidak valid (HTTP ${res.statusCode})",
      };
    }
  }

  static Map<String, dynamic> _authError(int statusCode, [String? action]) {
    return {
      "success": false,
      "message":
          "Akses ditolak ($statusCode)${action != null ? ': $action' : ''}. Silakan logout dan login kembali sebagai Admin.",
    };
  }

  // =================================================================
  // AUTHENTICATION & PROFILE
  // =================================================================
  static Future<Map<String, dynamic>> login(Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth'),
      headers: await _getHeaders(),
      body: jsonEncode(body),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> getAdminProfile() async {
    final res = await http.get(
      Uri.parse('$baseUrl/admins/me'),
      headers: await _getHeaders(),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> getCustomerProfile() async {
    final res = await http.get(
      Uri.parse('$baseUrl/customers/me'),
      headers: await _getHeaders(),
    );
    return jsonDecode(res.body);
  }

  static Future<void> logout() async {
    await UserLogin.clearPrefs();
  }

  // =================================================================
  // EDIT PROFILE (SERVICES)
  // =================================================================

  static Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> data,
  ) async {
    // Pastikan Anda mengambil token/user id yang tepat di sini
    // Ini contoh struktur dasarnya:
    final response = await http.patch(
      Uri.parse('$baseUrl/user/update-profile'), // Sesuaikan endpoint API Anda
      headers: {
        "Authorization": "Bearer TOKEN_ANDA",
        "Content-Type": "application/json",
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return {"success": true, "data": jsonDecode(response.body)};
    } else {
      return {"success": false, "message": "Gagal update profile"};
    }
  }

  // =================================================================
  // CRUD LAYANAN (SERVICES)
  // =================================================================
  static Future<Map<String, dynamic>> getLayanan() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/services'),
        headers: await _getHeaders(),
      );

      if (res.statusCode == 401 || res.statusCode == 403) {
        return _authError(res.statusCode, 'Gagal memuat layanan');
      }
      return _parseJsonResponse(res);
    } catch (e) {
      return {"success": false, "message": "Gagal terhubung ke server: $e"};
    }
  }

  // 2. Tambah Layanan Baru (POST)
  static Future<Map<String, dynamic>> createLayanan(
    Map<String, dynamic> body,
  ) async {
    try {
      final headers = await _getHeaders();
      final res = await http.post(
        Uri.parse('$baseUrl/services'),
        headers: headers,
        body: jsonEncode(body),
      );

      if (res.statusCode == 401 || res.statusCode == 403) {
        return _authError(res.statusCode, 'Gagal menambah layanan');
      }

      final parsed = _parseJsonResponse(res);
      if (parsed['success'] != true &&
          (res.statusCode == 200 || res.statusCode == 201)) {
        parsed['success'] = true;
      }
      return parsed;
    } catch (e) {
      return {"success": false, "message": "Gagal mengirim data ke server: $e"};
    }
  }

  // 3. Edit/Update Layanan (PUT)
  static Future<Map<String, dynamic>> updateLayanan(
    int id,
    Map<String, dynamic> body,
  ) async {
    try {
      final headers = await _getHeaders();
      final res = await http.put(
        Uri.parse('$baseUrl/services/$id'),
        headers: headers,
        body: jsonEncode(body),
      );

      if (res.statusCode == 401 || res.statusCode == 403) {
        return _authError(res.statusCode, 'Gagal memperbarui layanan');
      }

      final parsed = _parseJsonResponse(res);
      if (parsed['success'] != true &&
          (res.statusCode == 200 || res.statusCode == 201)) {
        parsed['success'] = true;
      }
      return parsed;
    } catch (e) {
      return {
        "success": false,
        "message": "Gagal memperbarui data ke server: $e",
      };
    }
  }

  // 4. Hapus Layanan (DELETE)
  static Future<Map<String, dynamic>> deleteLayanan(int id) async {
    try {
      final res = await http.delete(
        Uri.parse('$baseUrl/services/$id'),
        headers: await _getHeaders(),
      );

      if (res.statusCode == 401 || res.statusCode == 403) {
        return _authError(res.statusCode, 'Gagal menghapus layanan');
      }

      final parsed = _parseJsonResponse(res);
      if (parsed['success'] != true &&
          (res.statusCode == 200 ||
              res.statusCode == 201 ||
              res.statusCode == 204)) {
        parsed['success'] = true;
      }
      return parsed;
    } catch (e) {
      return {"success": false, "message": "Gagal menghapus data: $e"};
    }
  }

  // =================================================================
  // CRUD PELANGGAN (CUSTOMERS)
  // =================================================================
  static Future<Map<String, dynamic>> getPelanggan() async {
    final res = await http.get(
      Uri.parse('$baseUrl/customers'),
      headers: await _getHeaders(),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> createPelanggan(
    Map<String, dynamic> body,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/customers'),
      headers: await _getHeaders(),
      body: jsonEncode(body),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> updatePelanggan(
    int id,
    Map<String, dynamic> body,
  ) async {
    final res = await http.put(
      Uri.parse('$baseUrl/customers/$id'),
      headers: await _getHeaders(),
      body: jsonEncode(body),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> deletePelanggan(int id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/customers/$id'),
      headers: await _getHeaders(),
    );
    return jsonDecode(res.body);
  }

  // =================================================================
  // CRUD TAGIHAN (BILLS)
  // =================================================================
  static Future<Map<String, dynamic>> getTagihan() async {
    final res = await http.get(
      Uri.parse('$baseUrl/bills'),
      headers: await _getHeaders(),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> createTagihan(
    Map<String, dynamic> body,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/bills'),
      headers: await _getHeaders(),
      body: jsonEncode(body),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> updateTagihan(
    int id,
    Map<String, dynamic> body,
  ) async {
    final res = await http.put(
      Uri.parse('$baseUrl/bills/$id'),
      headers: await _getHeaders(),
      body: jsonEncode(body),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> deleteTagihan(int id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/bills/$id'),
      headers: await _getHeaders(),
    );
    return jsonDecode(res.body);
  }

  // Sesuai Soal No 9: GET /bills/me (Untuk Grafik & History)
  static Future<Map<String, dynamic>> getMyBills() async {
    final res = await http.get(
      Uri.parse('$baseUrl/bills/me'),
      headers: await _getHeaders(),
    );
    return jsonDecode(res.body);
  }

  // =================================================================
  // PEMBAYARAN & VERIFIKASI
  // =================================================================
  static Future<Map<String, String>> _getMultipartHeaders() async {
    final token = await UserLogin.getAuthToken();
    return {
      "app-key": appKey,
      if (token.isNotEmpty) "Authorization": "Bearer $token",
    };
  }

  static Future<Map<String, dynamic>> uploadPaymentProof(
    int billId,
    List<int> fileBytes,
    String fileName,
  ) async {
    try {
      if (billId <= 0) {
        return {"success": false, "message": "ID tagihan tidak valid"};
      }

      final uri = Uri.parse('$baseUrl/payments');
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(await _getMultipartHeaders());
      request.fields['bill_id'] = billId.toString();

      // 1. Deteksi jenis file agar server tidak menganggapnya file "sampah/mentah"
      String mimeType = 'application';
      String mimeSubtype = 'octet-stream';
      final ext = fileName.toLowerCase();

      if (ext.endsWith('.jpg') || ext.endsWith('.jpeg')) {
        mimeType = 'image';
        mimeSubtype = 'jpeg';
      } else if (ext.endsWith('.png')) {
        mimeType = 'image';
        mimeSubtype = 'png';
      } else if (ext.endsWith('.pdf')) {
        mimeType = 'application';
        mimeSubtype = 'pdf';
      }

      // 2. Masukkan file beserta MediaType-nya
      request.files.add(
        http.MultipartFile.fromBytes(
          'file', // ⚠️ PENTING: Jika masih gagal, ganti kata 'file' menjadi 'payment_proof'
          fileBytes,
          filename: fileName,
          contentType: MediaType(mimeType, mimeSubtype),
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // 3. TAMPILKAN ALASAN PENOLAKAN DARI SERVER DI TERMINAL
      print("========== DEBUG UPLOAD ==========");
      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");
      print("==================================");

      if (response.statusCode == 401 || response.statusCode == 403) {
        return _authError(
          response.statusCode,
          'Gagal mengunggah bukti pembayaran',
        );
      }

      final parsed = _parseJsonResponse(response);
      if (parsed['success'] != true &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        parsed['success'] = true;
      }
      return parsed;
    } catch (e) {
      return {
        "success": false,
        "message": "Gagal mengunggah bukti pembayaran: $e",
      };
    }
  }

  // ========== DEBUG UPLOAD ==========
  //Status Code: ...
  //Response Body: ...
  //==================================
  static Future<List<int>?> fetchPaymentProof(String fileName) async {
    if (fileName.isEmpty) return null;
    try {
      final token = await UserLogin.getAuthToken();
      final res = await http.get(
        Uri.parse('$baseUrl/payment-proof/$fileName'),
        headers: {
          "app-key": appKey,
          if (token.isNotEmpty) "Authorization": "Bearer $token",
        },
      );
      if (res.statusCode == 200) return res.bodyBytes;
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, dynamic>> getAllPayments() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/payments'),
        headers: await _getHeaders(),
      );
      if (res.statusCode == 401 || res.statusCode == 403) {
        return _authError(res.statusCode, 'Gagal memuat pembayaran');
      }
      return _parseJsonResponse(res);
    } catch (e) {
      return {"success": false, "message": "Gagal memuat pembayaran: $e"};
    }
  }

  static Future<Map<String, dynamic>> verifyPayment(int paymentId) async {
    try {
      final res = await http.patch(
        Uri.parse('$baseUrl/payments/$paymentId'),
        headers: await _getHeaders(),
      );
      if (res.statusCode == 401 || res.statusCode == 403) {
        return _authError(res.statusCode, 'Gagal verifikasi pembayaran');
      }
      final parsed = _parseJsonResponse(res);
      if (parsed['success'] != true &&
          (res.statusCode == 200 || res.statusCode == 201)) {
        parsed['success'] = true;
      }
      return parsed;
    } catch (e) {
      return {"success": false, "message": "Gagal verifikasi pembayaran: $e"};
    }
  }

  static Future<Map<String, dynamic>> rejectPayment(int paymentId) async {
    try {
      final res = await http.delete(
        Uri.parse('$baseUrl/payments/$paymentId'),
        headers: await _getHeaders(),
      );
      if (res.statusCode == 401 || res.statusCode == 403) {
        return _authError(res.statusCode, 'Gagal menolak pembayaran');
      }
      final parsed = _parseJsonResponse(res);
      if (parsed['success'] != true &&
          (res.statusCode == 200 ||
              res.statusCode == 201 ||
              res.statusCode == 204)) {
        parsed['success'] = true;
      }
      return parsed;
    } catch (e) {
      return {"success": false, "message": "Gagal menolak pembayaran: $e"};
    }
  }
}
