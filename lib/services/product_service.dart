import '../core/network/api_client.dart';
import '../core/constants/api_constants.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';

class ProductService {
  final ApiClient _api = ApiClient();

  /// GET /api/products
  Future<List<Product>> getProducts({int limit = 20, int offset = 0, String? category, String? brand, String? sort}) async {
    final response = await _api.get(ApiConstants.products, queryParameters: {
      'limit': limit,
      'offset': offset,
      if (category != null) 'category': category,
      if (brand != null) 'brand': brand,
      if (sort != null) 'sort': sort,
    });

    if (response.data['success'] == true) {
      final data = response.data['data'];
      List products = data is List ? data : (data['products'] ?? []);
      return products.map((p) => Product.fromJson(p)).toList();
    }
    return [];
  }

  /// GET /api/products/:id
  Future<Product?> getProductById(String id) async {
    final response = await _api.get(ApiConstants.productById(id));
    if (response.data['success'] == true) {
      return Product.fromJson(response.data['data']);
    }
    return null;
  }

  /// GET /api/products/:id/details
  Future<Product?> getProductDetails(String id) async {
    final response = await _api.get(ApiConstants.productDetails(id));
    if (response.data['success'] == true) {
      return Product.fromJson(response.data['data']);
    }
    return null;
  }

  /// GET /api/products/search?q=
  Future<List<Product>> searchProducts(String query) async {
    final response = await _api.get(ApiConstants.productSearch, queryParameters: {'q': query});
    if (response.data['success'] == true && response.data['data'] is List) {
      return (response.data['data'] as List).map((p) => Product.fromJson(p)).toList();
    }
    return [];
  }

  /// GET /api/products/suggestions?q=
  Future<List<Product>> getSuggestions(String query) async {
    final response = await _api.get(ApiConstants.productSuggestions, queryParameters: {'q': query});
    if (response.data['success'] == true && response.data['data']?['suggestions'] is List) {
      return (response.data['data']['suggestions'] as List).map((p) => Product.fromJson(p)).toList();
    }
    return [];
  }

  /// GET /api/products/filter
  Future<Map<String, dynamic>> getFilteredProducts({
    int page = 1,
    int limit = 20,
    String? sort,
    String? search,
    double? minPrice,
    double? maxPrice,
    String? category,
    String? brand,
    bool? onSale,
    bool? bestSeller,
    bool? newArrival,
  }) async {
    final response = await _api.get(ApiConstants.productFilter, queryParameters: {
      'page': page,
      'limit': limit,
      if (sort != null) 'sort': sort,
      if (search != null) 'search': search,
      if (minPrice != null) 'min_price': minPrice,
      if (maxPrice != null) 'max_price': maxPrice,
      if (category != null) 'category': category,
      if (brand != null) 'brand': brand,
      if (onSale == true) 'on_sale': 'true',
      if (bestSeller == true) 'bestSeller': 'true',
      if (newArrival == true) 'newArrival': 'true',
    });

    if (response.data['success'] == true) {
      final data = response.data['data'] ?? [];
      final meta = response.data['meta'] ?? {};
      return {
        'products': (data as List).map((p) => Product.fromJson(p)).toList(),
        'meta': meta,
      };
    }
    return {'products': <Product>[], 'meta': {}};
  }

  /// GET /api/products/best-sellers
  Future<List<Product>> getBestSellers({int limit = 10}) async {
    final response = await _api.get(ApiConstants.bestSellers, queryParameters: {'limit': limit});
    if (response.data['success'] == true) {
      final data = response.data['data'];
      List products = data is List ? data : (data['products'] ?? data ?? []);
      return products.map((p) => Product.fromJson(p)).toList();
    }
    return [];
  }

  /// GET /api/products/featured
  Future<List<Product>> getFeaturedProducts() async {
    final response = await _api.get(ApiConstants.featuredProducts);
    if (response.data['success'] == true && response.data['data'] is List) {
      return (response.data['data'] as List).map((p) => Product.fromJson(p)).toList();
    }
    return [];
  }

  /// GET /api/products/new-arrivals
  Future<List<Product>> getNewArrivals({int limit = 10}) async {
    final response = await _api.get(ApiConstants.newArrivals, queryParameters: {'limit': limit});
    if (response.data['success'] == true && response.data['data'] is List) {
      return (response.data['data'] as List).map((p) => Product.fromJson(p)).toList();
    }
    return [];
  }

  /// GET /api/products/:id/related
  Future<List<Product>> getRelatedProducts(String id, {int limit = 8}) async {
    final response = await _api.get(ApiConstants.relatedProducts(id), queryParameters: {'limit': limit});
    if (response.data['success'] == true && response.data['data'] is List) {
      return (response.data['data'] as List).map((p) => Product.fromJson(p)).toList();
    }
    return [];
  }

  /// GET /api/categories
  Future<List<Category>> getCategories({bool tree = false}) async {
    final response = await _api.get(ApiConstants.categories, queryParameters: {
      if (tree) 'tree': 'true',
    });
    if (response.data['success'] == true && response.data['data'] is List) {
      return (response.data['data'] as List).map((c) => Category.fromJson(c)).toList();
    }
    return [];
  }

  /// GET /api/media/hero/active
  Future<List<HeroSlide>> getHeroSlides() async {
    final response = await _api.get(ApiConstants.heroSlides);
    if (response.data['success'] == true && response.data['data'] is List) {
      return (response.data['data'] as List).map((s) => HeroSlide.fromJson(s)).toList();
    }
    return [];
  }
}
