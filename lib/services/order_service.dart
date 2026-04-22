import '../core/network/api_client.dart';
import '../core/constants/api_constants.dart';
import '../models/order_model.dart';

class OrderService {
  final ApiClient _api = ApiClient();

  /// POST /api/orders/checkout
  Future<Map<String, dynamic>> checkout({
    required String cartId,
    required String customerId,
    Map<String, dynamic>? shippingAddress,
    String? shippingAddressId,
    Map<String, dynamic>? billingAddress,
    String? billingAddressId,
    String? couponCode,
    String? paymentMethod,
    String? orderNotes,
  }) async {
    final response = await _api.post(ApiConstants.checkout, data: {
      'cart_id': cartId,
      'customer_id': customerId,
      if (shippingAddress != null) 'shipping_address': shippingAddress,
      if (shippingAddressId != null) 'shipping_address_id': shippingAddressId,
      if (billingAddress != null) 'billing_address': billingAddress,
      if (billingAddressId != null) 'billing_address_id': billingAddressId,
      if (couponCode != null) 'coupon_code': couponCode,
      'payment_method': paymentMethod ?? 'cod',
      if (orderNotes != null) 'order_notes': orderNotes,
    });
    return response.data;
  }

  /// POST /api/orders/direct
  Future<Map<String, dynamic>> directOrder({
    required List<Map<String, dynamic>> items,
    Map<String, dynamic>? shippingAddress,
    String? shippingAddressId,
    Map<String, dynamic>? billingAddress,
    String? billingAddressId,
    String? paymentMethod,
    String? couponCode,
  }) async {
    final response = await _api.post(ApiConstants.directOrder, data: {
      'items': items,
      if (shippingAddress != null) 'shipping_address': shippingAddress,
      if (shippingAddressId != null) 'shipping_address_id': shippingAddressId,
      if (billingAddress != null) 'billing_address': billingAddress,
      if (billingAddressId != null) 'billing_address_id': billingAddressId,
      'payment_method': paymentMethod ?? 'cod',
      if (couponCode != null) 'coupon_code': couponCode,
    });
    return response.data;
  }

  /// GET /api/orders/my
  Future<List<Order>> getMyOrders({int limit = 50, int offset = 0}) async {
    final response = await _api.get(ApiConstants.myOrders, queryParameters: {
      'limit': limit,
      'offset': offset,
    });

    if (response.data['success'] == true) {
      final data = response.data['data'];
      final orders = data['orders'] ?? data;
      if (orders is List) {
        return orders.map((o) => Order.fromJson(o)).toList();
      }
    }
    return [];
  }

  /// GET /api/orders/:id
  Future<Order?> getOrderById(String id) async {
    final response = await _api.get(ApiConstants.orderById(id));
    if (response.data['success'] == true) {
      return Order.fromJson(response.data['data']);
    }
    return null;
  }

  /// GET /api/orders/:id/track
  Future<Map<String, dynamic>> trackOrder(String id) async {
    final response = await _api.get(ApiConstants.trackOrder(id));
    return response.data;
  }

  /// POST /api/orders/:id/cancel
  Future<Map<String, dynamic>> cancelOrder(String id, {String? reason}) async {
    final response = await _api.post(ApiConstants.cancelOrder(id), data: {
      if (reason != null) 'reason': reason,
    });
    return response.data;
  }
}
