import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pdam_apps/Models/User_login.dart';
import 'package:pdam_apps/Services/Url.dart' as url;

class ApiService {
  // ─── HEADERS ───────────────────────────────────────────
  static Future<Map<String, String>> _headers() async {
    final token = await UserLogin.getAuthToken();
    return {
      "Content-Type": "application/json",
      "app-key": url.OWNER_TOKEN,
      "Authorization": "Bearer $token",
    };
  }

  // ─── BASE HTTP METHODS ──────────────────────────────────
  static Future<Map<String, dynamic>> get(String path) async {
    try {
      final h = await _headers();
      final res = await http.get(Uri.parse("${url.BASEURL}$path"), headers: h);
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (e) {
      return {"success": false, "message": "Error koneksi: $e"};
    }
  }

  static Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    try {
      final h = await _headers();
      final res = await http.post(Uri.parse("${url.BASEURL}$path"), headers: h, body: jsonEncode(body));
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (e) {
      return {"success": false, "message": "Error koneksi: $e"};
    }
  }

  static Future<Map<String, dynamic>> patch(String path, Map<String, dynamic> body) async {
    try {
      final h = await _headers();
      final res = await http.patch(Uri.parse("${url.BASEURL}$path"), headers: h, body: jsonEncode(body));
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (e) {
      return {"success": false, "message": "Error koneksi: $e"};
    }
  }

  static Future<Map<String, dynamic>> delete(String path) async {
    try {
      final h = await _headers();
      final res = await http.delete(Uri.parse("${url.BASEURL}$path"), headers: h);
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (e) {
      return {"success": false, "message": "Error koneksi: $e"};
    }
  }

  static Future<Map<String, dynamic>> uploadFile(String path, Map<String, String> fields, String fileKey, String filePath) async {
    try {
      final token = await UserLogin.getAuthToken();
      final request = http.MultipartRequest("POST", Uri.parse("${url.BASEURL}$path"));
      request.headers.addAll({"app-key": url.OWNER_TOKEN, "Authorization": "Bearer $token"});
      request.fields.addAll(fields);
      request.files.add(await http.MultipartFile.fromPath(fileKey, filePath));
      final streamed = await request.send();
      final res = await http.Response.fromStream(streamed);
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (e) {
      return {"success": false, "message": "Error upload: $e"};
    }
  }

  // ─── PROFILE ───────────────────────────────────────────
  // Soal 3: GET /admins/me | GET /customers/me
  static Future<Map<String, dynamic>> getAdminProfile() => get("/admins/me");
  static Future<Map<String, dynamic>> getCustomerProfile() => get("/customers/me");

  // ─── LAYANAN / SERVICES ─────────────────────────────────
  // Soal 4: CRUD /services
  static Future<Map<String, dynamic>> getLayanan() => get("/services");
  static Future<Map<String, dynamic>> getLayananById(int id) => get("/services/$id");
  static Future<Map<String, dynamic>> createLayanan(Map<String, dynamic> data) => post("/services", data);
  static Future<Map<String, dynamic>> updateLayanan(int id, Map<String, dynamic> data) => patch("/services/$id", data);
  static Future<Map<String, dynamic>> deleteLayanan(int id) => delete("/services/$id");

  // ─── PELANGGAN / CUSTOMERS ──────────────────────────────
  // Soal 5: CRUD /customers
  static Future<Map<String, dynamic>> getPelanggan() => get("/customers");
  static Future<Map<String, dynamic>> getPelangganById(int id) => get("/customers/$id");
  static Future<Map<String, dynamic>> createPelanggan(Map<String, dynamic> data) => post("/customers", data);
  static Future<Map<String, dynamic>> updatePelanggan(int id, Map<String, dynamic> data) => patch("/customers/$id", data);
  static Future<Map<String, dynamic>> deletePelanggan(int id) => delete("/customers/$id");

  // ─── TAGIHAN / BILLS ────────────────────────────────────
  // Soal 6: CRUD /bills
  static Future<Map<String, dynamic>> getTagihan() => get("/bills");
  static Future<Map<String, dynamic>> getTagihanById(int id) => get("/bills/$id");
  static Future<Map<String, dynamic>> createTagihan(Map<String, dynamic> data) => post("/bills", data);
  static Future<Map<String, dynamic>> updateTagihan(int id, Map<String, dynamic> data) => patch("/bills/$id", data);
  static Future<Map<String, dynamic>> deleteTagihan(int id) => delete("/bills/$id");

  // ─── PAYMENTS ────────────────────────────────────────────
  // Soal 6: Verify/Reject
  static Future<Map<String, dynamic>> getPayments() => get("/payments");
  static Future<Map<String, dynamic>> verifyPayment(int paymentId) => patch("/payments/$paymentId", {});
  static Future<Map<String, dynamic>> rejectPayment(int paymentId) => delete("/payments/$paymentId");

  // Soal 7: Customer payments
  static Future<Map<String, dynamic>> getMyPayments() => get("/payments/me");
  static Future<Map<String, dynamic>> getMyPaymentById(int id) => get("/payments/me/$id");
  static Future<Map<String, dynamic>> uploadPayment(int billId, String filePath) =>
      uploadFile("/payments", {"bill_id": billId.toString()}, "file", filePath);

  // ─── BILLS/ME ─────────────────────────────────────────
  // Soal 9: Customer dashboard + history
  static Future<Map<String, dynamic>> getMyBills() => get("/bills/me");
}