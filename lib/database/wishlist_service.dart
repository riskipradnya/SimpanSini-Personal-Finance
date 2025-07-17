import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wishlist_model.dart';

class WishlistService {
  // Change localhost to your actual IP address
  final String _baseUrl =
      "http://localhost/api_keuangan"; // Replace with your IP

  Future<List<WishlistItem>> getAllWishlistItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id') ?? 0;

      if (userId == 0) {
        return _getDummyWishlistItems();
      }

      final response = await http
          .get(
            Uri.parse('$_baseUrl/wishlist.php?user_id=$userId'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        // Check if response is JSON
        if (response.body.trim().startsWith('{') ||
            response.body.trim().startsWith('[')) {
          final data = json.decode(response.body);
          if (data['status'] == 'success') {
            return (data['data'] as List)
                .map((item) => WishlistItem.fromJson(item))
                .toList();
          }
        }
      }
      return _getDummyWishlistItems();
    } catch (e) {
      print('Error fetching wishlist: $e');
      return _getDummyWishlistItems();
    }
  }

  Future<Map<String, dynamic>> addWishlistItem(WishlistItem item) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/wishlist.php'),
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: {
              'user_id': item.userId.toString(),
              'title': item.title,
              'target_amount': item.targetAmount.toString(),
              'current_amount': item.currentAmount.toString(),
              'description': item.description,
              'is_priority': item.isPriority ? '1' : '0',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        // Check if response is JSON
        if (response.body.trim().startsWith('{')) {
          final data = json.decode(response.body);
          return data;
        } else {
          return {
            'status': 'error',
            'message': 'Server error: ${response.body.substring(0, 100)}',
          };
        }
      }
      return {
        'status': 'error',
        'message': 'HTTP Error: ${response.statusCode}',
      };
    } catch (e) {
      print('Error adding wishlist item: $e');
      // Return dummy success for testing
      return {
        'status': 'success',
        'message': 'Item berhasil ditambahkan (mode offline)',
      };
    }
  }

  Future<Map<String, dynamic>> updateWishlistItem(WishlistItem item) async {
    try {
      final response = await http
          .put(
            Uri.parse('$_baseUrl/wishlist.php'),
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: {
              'id': item.id.toString(),
              'title': item.title,
              'target_amount': item.targetAmount.toString(),
              'current_amount': item.currentAmount.toString(),
              'description': item.description,
              'is_priority': item.isPriority ? '1' : '0',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        // Check if response is JSON
        if (response.body.trim().startsWith('{')) {
          final data = json.decode(response.body);
          return data;
        } else {
          return {
            'status': 'error',
            'message': 'Server error: ${response.body.substring(0, 100)}',
          };
        }
      }
      return {
        'status': 'error',
        'message': 'HTTP Error: ${response.statusCode}',
      };
    } catch (e) {
      return {'status': 'error', 'message': 'Terjadi kesalahan: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteWishlistItem(int id) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$_baseUrl/wishlist.php?id=$id'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        // Check if response is JSON
        if (response.body.trim().startsWith('{')) {
          final data = json.decode(response.body);
          return data;
        } else {
          return {
            'status': 'error',
            'message': 'Server error: ${response.body.substring(0, 100)}',
          };
        }
      }
      return {
        'status': 'error',
        'message': 'HTTP Error: ${response.statusCode}',
      };
    } catch (e) {
      return {'status': 'error', 'message': 'Terjadi kesalahan: $e'};
    }
  }

  List<WishlistItem> _getDummyWishlistItems() {
    return [
      WishlistItem(
        id: 1,
        userId: 1,
        title: 'Iphone 16 Pro Max',
        targetAmount: 15000000,
        currentAmount: 5000000,
        description: 'Smartphone terbaru',
        isPriority: true,
        createdAt: DateTime.now(),
      ),
      WishlistItem(
        id: 2,
        userId: 1,
        title: 'Alphard',
        targetAmount: 1670000000,
        currentAmount: 500000000,
        description: 'Mobil keluarga',
        isPriority: true,
        createdAt: DateTime.now(),
      ),
      WishlistItem(
        id: 3,
        userId: 1,
        title: 'Rumah-Pondok Indah',
        targetAmount: 3670000000,
        currentAmount: 1000000000,
        description: 'Perkiraan Budget',
        isPriority: false,
        createdAt: DateTime.now(),
      ),
      WishlistItem(
        id: 4,
        userId: 1,
        title: 'Motor Vespa Matic',
        targetAmount: 80000000,
        currentAmount: 20000000,
        description: 'Perkiraan Budget',
        isPriority: false,
        createdAt: DateTime.now(),
      ),
    ];
  }
}
