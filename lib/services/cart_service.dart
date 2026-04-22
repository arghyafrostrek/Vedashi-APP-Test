import '../core/network/api_client.dart';
import '../core/constants/api_constants.dart';
import '../models/cart_model.dart';

class CartService {
  final ApiClient _api = ApiClient();

  /// POST /api/cart — Create or get existing cart
  Future<Cart?> createOrGetCart({String? customerId}) async {
    final response = await _api.post(ApiConstants.cart, data: {
      if (customerId != null) 'customer_id': customerId,
    });
    if (response.data['success'] == true) {
      return Cart.fromJson(response.data['data']);
    }
    return null;
  }

  /// GET /api/cart?cart_id= or /api/cart/:cartId
  Future<Cart?> getCart({String? cartId, String? customerId}) async {
    String path = ApiConstants.cart;
    Map<String, dynamic> params = {};

    if (cartId != null) {
      path = ApiConstants.cartById(cartId);
    } else if (customerId != null) {
      params['customer_id'] = customerId;
    }

    final response = await _api.get(path, queryParameters: params.isNotEmpty ? params : null);
    if (response.data['success'] == true) {
      return Cart.fromJson(response.data['data']);
    }
    return null;
  }

  /// POST /api/cart/items — Add item to cart
  Future<Map<String, dynamic>> addItem({
    required String cartId,
    String? variantId,
    String? productId,
    int quantity = 1,
  }) async {
    final response = await _api.post(ApiConstants.cartItems, data: {
      'cart_id': cartId,
      if (variantId != null) 'variant_id': variantId,
      if (productId != null) 'product_id': productId,
      'quantity': quantity,
    });
    return response.data;
  }

  /// PATCH /api/cart/items/:itemId — Update quantity
  Future<Map<String, dynamic>> updateItemQuantity(String itemId, int quantity) async {
    final response = await _api.patch(ApiConstants.cartItem(itemId), data: {
      'quantity': quantity,
    });
    return response.data;
  }

  /// DELETE /api/cart/items/:itemId — Remove item
  Future<Map<String, dynamic>> removeItem(String itemId) async {
    final response = await _api.delete(ApiConstants.cartItem(itemId));
    return response.data;
  }

  /// POST /api/cart/merge — Merge guest cart into customer cart
  Future<Cart?> mergeGuestCart(String guestCartId, String customerId) async {
    final response = await _api.post(ApiConstants.cartMerge, data: {
      'guest_cart_id': guestCartId,
      'customer_id': customerId,
    });
    if (response.data['success'] == true) {
      return Cart.fromJson(response.data['data']);
    }
    return null;
  }
}
