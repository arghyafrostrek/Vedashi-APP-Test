/// Product variant model from backend
class ProductVariant {
  final String? variantId;
  final String? variantSku;
  final String? variantName;
  final double price;
  final double? salePrice;
  final int stockQuantity;
  final bool isDefault;
  final bool isActive;
  final Map<String, dynamic>? attributes;

  ProductVariant({
    this.variantId,
    this.variantSku,
    this.variantName,
    required this.price,
    this.salePrice,
    this.stockQuantity = 0,
    this.isDefault = false,
    this.isActive = true,
    this.attributes,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      variantId: json['variant_id'],
      variantSku: json['variant_sku'],
      variantName: json['variant_name'],
      price: _parseDouble(json['price']),
      salePrice: json['sale_price'] != null ? _parseDouble(json['sale_price']) : null,
      stockQuantity: _parseInt(json['stock_quantity'] ?? json['stock']),
      isDefault: json['is_default'] ?? false,
      isActive: json['is_active'] ?? true,
      attributes: json['attributes'] is Map ? Map<String, dynamic>.from(json['attributes']) : null,
    );
  }

  bool get isOnSale => salePrice != null && salePrice! > 0 && salePrice! < price;

  double get effectivePrice => isOnSale ? salePrice! : price;

  int get discountPercent {
    if (!isOnSale) return 0;
    return (((price - salePrice!) / price) * 100).round();
  }
}

/// Product model mapped from backend /api/products responses
class Product {
  final String productId;
  final String productName;
  final String? sku;
  final String? slug;
  final String? brand;
  final String? category;
  final String? categoryId;
  final String? description;
  final String? shortDescription;
  final String? thumbnailUrl;
  final double price;
  final double? salePrice;
  final int quantity;
  final String status;
  final bool isOnSale;
  final bool isEditorPick;
  final bool isTrending;
  final String? countryOfOrigin;
  final String? form;
  final String? unitOfMeasure;
  final double? averageRating;
  final int? reviewCount;
  final int? totalSold;
  final List<ProductVariant> variants;
  final List<String> images;
  final Map<String, dynamic>? specifications;
  final Map<String, dynamic>? seo;
  final String? createdAt;

  Product({
    required this.productId,
    required this.productName,
    this.sku,
    this.slug,
    this.brand,
    this.category,
    this.categoryId,
    this.description,
    this.shortDescription,
    this.thumbnailUrl,
    required this.price,
    this.salePrice,
    this.quantity = 0,
    this.status = 'active',
    this.isOnSale = false,
    this.isEditorPick = false,
    this.isTrending = false,
    this.countryOfOrigin,
    this.form,
    this.unitOfMeasure,
    this.averageRating,
    this.reviewCount,
    this.totalSold,
    this.variants = const [],
    this.images = const [],
    this.specifications,
    this.seo,
    this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    List<ProductVariant> variants = [];
    if (json['variants'] is List) {
      variants = (json['variants'] as List)
          .map((v) => ProductVariant.fromJson(v))
          .toList();
    }

    List<String> imageList = [];
    if (json['thumbnail_url'] != null) {
      imageList.add(json['thumbnail_url']);
    }
    if (json['images'] is List) {
      for (var img in json['images']) {
        if (img is String) imageList.add(img);
        if (img is Map && img['image_url'] != null) imageList.add(img['image_url']);
      }
    }
    if (json['assets'] is List) {
      for (var asset in json['assets']) {
        if (asset is Map && asset['asset_url'] != null) {
          imageList.add(asset['asset_url']);
        }
      }
    }

    return Product(
      productId: json['product_id'] ?? '',
      productName: json['product_name'] ?? '',
      sku: json['sku'],
      slug: json['slug'],
      brand: json['brand'],
      category: json['category'],
      categoryId: json['category_id'],
      description: json['description'],
      shortDescription: json['short_description'],
      thumbnailUrl: json['thumbnail_url'],
      price: _parseDouble(json['price']),
      salePrice: json['sale_price'] != null ? _parseDouble(json['sale_price']) : null,
      quantity: _parseInt(json['quantity'] ?? json['stock_quantity']),
      status: json['status'] ?? 'active',
      isOnSale: json['is_on_sale'] ?? false,
      isEditorPick: json['is_editor_pick'] ?? false,
      isTrending: json['is_trending'] ?? false,
      countryOfOrigin: json['country_of_origin'],
      form: json['form'],
      unitOfMeasure: json['unit_of_measure'],
      averageRating: json['average_rating'] != null ? _parseDouble(json['average_rating']) : null,
      reviewCount: json['review_count'] != null ? _parseInt(json['review_count']) : null,
      totalSold: json['total_sold'] != null ? _parseInt(json['total_sold']) : null,
      variants: variants,
      images: imageList,
      specifications: json['specifications'] is Map ? Map<String, dynamic>.from(json['specifications']) : null,
      seo: json['seo'] is Map ? Map<String, dynamic>.from(json['seo']) : null,
      createdAt: json['created_at'],
    );
  }

  ProductVariant? get defaultVariant =>
      variants.isNotEmpty ? (variants.firstWhere((v) => v.isDefault, orElse: () => variants.first)) : null;

  double get effectivePrice {
    if (defaultVariant != null) return defaultVariant!.effectivePrice;
    if (salePrice != null && salePrice! > 0 && salePrice! < price) return salePrice!;
    return price;
  }

  double get originalPrice {
    if (defaultVariant != null) return defaultVariant!.price;
    return price;
  }

  bool get hasDiscount => effectivePrice < originalPrice;

  int get discountPercent {
    if (!hasDiscount) return 0;
    return (((originalPrice - effectivePrice) / originalPrice) * 100).round();
  }

  bool get inStock {
    if (variants.isNotEmpty) return variants.any((v) => v.stockQuantity > 0 && v.isActive);
    return quantity > 0;
  }
}

double _parseDouble(dynamic value) {
  if (value == null) return 0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
