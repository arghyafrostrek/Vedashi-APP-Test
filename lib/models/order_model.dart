/// Order model mapped from backend /api/orders responses
class Order {
  final String orderId;
  final String? orderNumber;
  final String? customerId;
  final String orderStatus;
  final String paymentStatus;
  final String? paymentMethod;
  final double totalAmount;
  final double? shippingFee;
  final double? discount;
  final double? finalTotal;
  final String? currency;
  final String? orderNotes;
  final String? createdAt;
  final String? updatedAt;
  final List<OrderItem> items;
  final Map<String, dynamic>? shippingAddress;
  final Map<String, dynamic>? billingAddress;

  Order({
    required this.orderId,
    this.orderNumber,
    this.customerId,
    required this.orderStatus,
    required this.paymentStatus,
    this.paymentMethod,
    required this.totalAmount,
    this.shippingFee,
    this.discount,
    this.finalTotal,
    this.currency = 'INR',
    this.orderNotes,
    this.createdAt,
    this.updatedAt,
    this.items = const [],
    this.shippingAddress,
    this.billingAddress,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    List<OrderItem> items = [];
    if (json['items'] is List) {
      items = (json['items'] as List).map((i) => OrderItem.fromJson(i)).toList();
    }

    return Order(
      orderId: json['order_id'] ?? '',
      orderNumber: json['order_number'],
      customerId: json['customer_id'],
      orderStatus: json['order_status'] ?? 'PENDING',
      paymentStatus: json['payment_status'] ?? 'UNPAID',
      paymentMethod: json['payment_method'],
      totalAmount: _toDouble(json['total_amount'] ?? json['grand_total']),
      shippingFee: json['shipping_fee'] != null ? _toDouble(json['shipping_fee']) : null,
      discount: json['discount'] != null ? _toDouble(json['discount']) : null,
      finalTotal: json['final_total'] != null ? _toDouble(json['final_total']) : null,
      currency: json['currency'] ?? 'INR',
      orderNotes: json['order_notes'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      items: items,
      shippingAddress: json['shipping_address'] is Map ? Map<String, dynamic>.from(json['shipping_address']) : null,
      billingAddress: json['billing_address'] is Map ? Map<String, dynamic>.from(json['billing_address']) : null,
    );
  }

  String get displayTotal => '₹${(finalTotal ?? totalAmount).toStringAsFixed(0)}';

  String get statusLabel {
    switch (orderStatus) {
      case 'PENDING': return 'Pending';
      case 'CONFIRMED': return 'Confirmed';
      case 'PROCESSING': return 'Processing';
      case 'SHIPPED': return 'Shipped';
      case 'DELIVERED': return 'Delivered';
      case 'CANCELLED': return 'Cancelled';
      case 'RETURNED': return 'Returned';
      default: return orderStatus;
    }
  }
}

class OrderItem {
  final String? orderItemId;
  final String? productId;
  final String? variantId;
  final String? productName;
  final String? variantName;
  final String? thumbnailUrl;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  OrderItem({
    this.orderItemId,
    this.productId,
    this.variantId,
    this.productName,
    this.variantName,
    this.thumbnailUrl,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      orderItemId: json['order_item_id'],
      productId: json['product_id'],
      variantId: json['variant_id'],
      productName: json['product_name'],
      variantName: json['variant_name'],
      thumbnailUrl: json['thumbnail_url'],
      quantity: json['quantity'] ?? 1,
      unitPrice: _toDouble(json['unit_price'] ?? json['price']),
      totalPrice: _toDouble(json['total_price'] ?? json['line_total']),
    );
  }
}

double _toDouble(dynamic v) {
  if (v == null) return 0;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0;
  return 0;
}
