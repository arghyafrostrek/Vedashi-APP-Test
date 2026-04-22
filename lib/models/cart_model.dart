/// Cart item model from backend
class CartItem {
  final String cartItemId;
  final String? variantId;
  final String? productId;
  final int quantity;
  final String? productName;
  final String? variantName;
  final String? thumbnailUrl;
  final double price;
  final double? salePrice;
  final String? sku;
  final bool savedForLater;

  CartItem({
    required this.cartItemId,
    this.variantId,
    this.productId,
    required this.quantity,
    this.productName,
    this.variantName,
    this.thumbnailUrl,
    required this.price,
    this.salePrice,
    this.sku,
    this.savedForLater = false,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      cartItemId: json['cart_item_id'] ?? '',
      variantId: json['variant_id'],
      productId: json['product_id'],
      quantity: json['quantity'] ?? 1,
      productName: json['product_name'],
      variantName: json['variant_name'],
      thumbnailUrl: json['thumbnail_url'],
      price: _toDouble(json['price']),
      salePrice: json['sale_price'] != null ? _toDouble(json['sale_price']) : null,
      sku: json['sku'] ?? json['variant_sku'],
      savedForLater: json['saved_for_later'] ?? false,
    );
  }

  double get effectivePrice => (salePrice != null && salePrice! > 0 && salePrice! < price) ? salePrice! : price;
  double get lineTotal => effectivePrice * quantity;
}

/// Cart model from backend /api/cart response
class Cart {
  final String cartId;
  final String? customerId;
  final List<CartItem> items;
  final double subtotal;
  final double total;
  final int itemCount;

  Cart({
    required this.cartId,
    this.customerId,
    this.items = const [],
    this.subtotal = 0,
    this.total = 0,
    this.itemCount = 0,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    List<CartItem> items = [];
    if (json['items'] is List) {
      items = (json['items'] as List).map((i) => CartItem.fromJson(i)).toList();
    }

    return Cart(
      cartId: json['cart_id'] ?? '',
      customerId: json['customer_id'],
      items: items,
      subtotal: _toDouble(json['subtotal']),
      total: _toDouble(json['total'] ?? json['grand_total']),
      itemCount: json['item_count'] ?? items.length,
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
