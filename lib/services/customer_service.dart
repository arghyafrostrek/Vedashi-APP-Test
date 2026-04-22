import '../core/network/api_client.dart';
import '../core/constants/api_constants.dart';
import '../models/category_model.dart';

class CustomerService {
  final ApiClient _api = ApiClient();

  /// GET /api/customers/:id
  Future<Map<String, dynamic>> getProfile(String customerId) async {
    final response = await _api.get(ApiConstants.customerProfile(customerId));
    return response.data;
  }

  /// PATCH /api/customers/:id
  Future<Map<String, dynamic>> updateProfile(String customerId, Map<String, dynamic> data) async {
    final response = await _api.patch(ApiConstants.customerProfile(customerId), data: data);
    return response.data;
  }

  /// GET /api/customers/:id/addresses
  Future<List<Address>> getAddresses(String customerId) async {
    final response = await _api.get(ApiConstants.customerAddresses(customerId));
    if (response.data['success'] == true && response.data['data'] is List) {
      return (response.data['data'] as List).map((a) => Address.fromJson(a)).toList();
    }
    return [];
  }

  /// POST /api/customers/:id/addresses
  Future<Map<String, dynamic>> addAddress(String customerId, Address address) async {
    final response = await _api.post(ApiConstants.customerAddresses(customerId), data: address.toJson());
    return response.data;
  }

  /// PATCH /api/customers/:id/addresses/:addressId
  Future<Map<String, dynamic>> updateAddress(String customerId, String addressId, Map<String, dynamic> data) async {
    final response = await _api.patch(ApiConstants.customerAddress(customerId, addressId), data: data);
    return response.data;
  }

  /// DELETE /api/customers/:id/addresses/:addressId
  Future<Map<String, dynamic>> deleteAddress(String customerId, String addressId) async {
    final response = await _api.delete(ApiConstants.customerAddress(customerId, addressId));
    return response.data;
  }
}

class WishlistService {
  final ApiClient _api = ApiClient();

  /// GET /api/wishlist
  Future<List<WishlistItem>> getWishlist() async {
    final response = await _api.get(ApiConstants.wishlist);
    if (response.data['success'] == true) {
      final data = response.data['data'];
      final items = data['items'] ?? data;
      if (items is List) {
        return items.map((i) => WishlistItem.fromJson(i)).toList();
      }
    }
    return [];
  }

  /// POST /api/wishlist
  Future<Map<String, dynamic>> addToWishlist(String productId, {String? variantId}) async {
    final response = await _api.post(ApiConstants.wishlist, data: {
      'product_id': productId,
      if (variantId != null) 'variant_id': variantId,
    });
    return response.data;
  }

  /// DELETE /api/wishlist/:productId
  Future<Map<String, dynamic>> removeFromWishlist(String productId) async {
    final response = await _api.delete(ApiConstants.wishlistRemove(productId));
    return response.data;
  }

  /// GET /api/wishlist/check/:productId
  Future<bool> isInWishlist(String productId) async {
    try {
      final response = await _api.get(ApiConstants.wishlistCheck(productId));
      if (response.data['success'] == true) {
        return response.data['data']?['in_wishlist'] ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
