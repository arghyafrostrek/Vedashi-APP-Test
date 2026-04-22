/// Category model from /api/categories
class Category {
  final String categoryId;
  final String name;
  final String? slug;
  final String? description;
  final String? imageUrl;
  final String? parentId;
  final int? productCount;
  final List<Category> children;

  Category({
    required this.categoryId,
    required this.name,
    this.slug,
    this.description,
    this.imageUrl,
    this.parentId,
    this.productCount,
    this.children = const [],
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    List<Category> children = [];
    if (json['children'] is List) {
      children = (json['children'] as List).map((c) => Category.fromJson(c)).toList();
    }

    return Category(
      categoryId: json['category_id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'],
      description: json['description'],
      imageUrl: json['image_url'],
      parentId: json['parent_id'],
      productCount: json['product_count'],
      children: children,
    );
  }
}

/// Address model for customer addresses
class Address {
  final String? addressId;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String pincode;
  final String country;
  final String? label;
  final bool isDefault;

  Address({
    this.addressId,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.pincode,
    this.country = 'India',
    this.label,
    this.isDefault = false,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      addressId: json['address_id'],
      addressLine1: json['address_line1'] ?? json['line1'] ?? '',
      addressLine2: json['address_line2'] ?? json['line2'],
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pincode: (json['pincode'] ?? json['zip'] ?? json['postal_code'] ?? '').toString(),
      country: json['country'] ?? 'India',
      label: json['label'] ?? json['address_type'],
      isDefault: json['is_default'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    if (addressId != null) 'address_id': addressId,
    'address_line1': addressLine1,
    'address_line2': addressLine2,
    'city': city,
    'state': state,
    'pincode': pincode,
    'country': country,
    'label': label,
    'is_default': isDefault,
  };

  String get formatted => '$addressLine1${addressLine2 != null ? ', $addressLine2' : ''}, $city, $state - $pincode, $country';
}

/// Hero slide model from /api/media/hero/active
class HeroSlide {
  final String id;
  final String imageUrl;
  final List<dynamic>? headings;
  final List<dynamic>? subheadings;
  final List<dynamic>? buttons;
  final double overlayOpacity;

  HeroSlide({
    required this.id,
    required this.imageUrl,
    this.headings,
    this.subheadings,
    this.buttons,
    this.overlayOpacity = 0.5,
  });

  factory HeroSlide.fromJson(Map<String, dynamic> json) {
    return HeroSlide(
      id: (json['id'] ?? '').toString(),
      imageUrl: json['image_url'] ?? '',
      headings: json['headings'] is List ? json['headings'] : null,
      subheadings: json['subheadings'] is List ? json['subheadings'] : null,
      buttons: json['buttons'] is List ? json['buttons'] : null,
      overlayOpacity: (json['overlay_opacity'] ?? 0.5).toDouble(),
    );
  }
}

/// Wishlist item from /api/wishlist
class WishlistItem {
  final String? wishlistId;
  final String productId;
  final String? variantId;
  final String? productName;
  final String? thumbnailUrl;
  final double? price;
  final double? salePrice;
  final String? brand;
  final String? addedAt;

  WishlistItem({
    this.wishlistId,
    required this.productId,
    this.variantId,
    this.productName,
    this.thumbnailUrl,
    this.price,
    this.salePrice,
    this.brand,
    this.addedAt,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      wishlistId: json['wishlist_id'],
      productId: json['product_id'] ?? '',
      variantId: json['variant_id'],
      productName: json['product_name'],
      thumbnailUrl: json['thumbnail_url'],
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      salePrice: json['sale_price'] != null ? (json['sale_price'] as num).toDouble() : null,
      brand: json['brand'],
      addedAt: json['added_at'] ?? json['created_at'],
    );
  }
}
