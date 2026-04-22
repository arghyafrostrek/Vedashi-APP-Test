import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/product_service.dart';
import '../services/cart_service.dart';
import '../services/order_service.dart';
import '../services/customer_service.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../models/cart_model.dart';
import '../models/order_model.dart';
import '../models/category_model.dart';

// ─── Service Providers ───────────────────────────────────────────
final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final productServiceProvider = Provider<ProductService>((ref) => ProductService());
final cartServiceProvider = Provider<CartService>((ref) => CartService());
final orderServiceProvider = Provider<OrderService>((ref) => OrderService());
final customerServiceProvider = Provider<CustomerService>((ref) => CustomerService());
final wishlistServiceProvider = Provider<WishlistService>((ref) => WishlistService());

// ─── Auth State ──────────────────────────────────────────────────

class AuthState {
  final User? user;
  final bool isLoading;
  final bool isAuthenticated;
  final String? error;

  AuthState({this.user, this.isLoading = false, this.isAuthenticated = false, this.error});

  AuthState copyWith({User? user, bool? isLoading, bool? isAuthenticated, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AuthState());

  Future<void> checkAuth() async {
    state = state.copyWith(isLoading: true);
    final hasToken = await _authService.hasToken();
    if (hasToken) {
      final user = await _authService.getMe();
      if (user != null) {
        state = AuthState(user: user, isAuthenticated: true, isLoading: false);
        return;
      }
    }
    state = AuthState(isLoading: false);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _authService.login(email, password);
      if (result['success'] == true) {
        final user = User.fromJson(result['data']['customer']);
        state = AuthState(user: user, isAuthenticated: true, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, error: result['message']);
      }
      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> register(String fullName, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _authService.register(fullName, email, password);
      state = state.copyWith(isLoading: false);
      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = AuthState();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authServiceProvider));
});

// ─── Home Data Provider ──────────────────────────────────────────

class HomeData {
  final List<Product> bestSellers;
  final List<Product> newArrivals;
  final List<Category> categories;
  final List<HeroSlide> heroSlides;
  final bool isLoading;

  HomeData({
    this.bestSellers = const [],
    this.newArrivals = const [],
    this.categories = const [],
    this.heroSlides = const [],
    this.isLoading = true,
  });
}

final homeDataProvider = FutureProvider<HomeData>((ref) async {
  final productService = ref.read(productServiceProvider);
  try {
    final results = await Future.wait([
      productService.getBestSellers(limit: 10),
      productService.getNewArrivals(limit: 10),
      productService.getCategories(tree: true),
      productService.getHeroSlides(),
    ]);
    return HomeData(
      bestSellers: results[0] as List<Product>,
      newArrivals: results[1] as List<Product>,
      categories: results[2] as List<Category>,
      heroSlides: results[3] as List<HeroSlide>,
      isLoading: false,
    );
  } catch (e) {
    return HomeData(isLoading: false);
  }
});

// ─── Cart Provider ───────────────────────────────────────────────

class CartNotifier extends StateNotifier<AsyncValue<Cart?>> {
  final CartService _cartService;
  final Ref _ref;

  CartNotifier(this._cartService, this._ref) : super(const AsyncValue.loading());

  Future<void> loadCart() async {
    state = const AsyncValue.loading();
    try {
      final auth = _ref.read(authProvider);
      Cart? cart;
      if (auth.isAuthenticated && auth.user != null) {
        cart = await _cartService.getCart(customerId: auth.user!.customerId);
        cart ??= await _cartService.createOrGetCart(customerId: auth.user!.customerId);
      }
      state = AsyncValue.data(cart);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addItem(String cartId, {String? variantId, String? productId, int quantity = 1}) async {
    try {
      await _cartService.addItem(cartId: cartId, variantId: variantId, productId: productId, quantity: quantity);
      await loadCart();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    try {
      await _cartService.updateItemQuantity(itemId, quantity);
      await loadCart();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeItem(String itemId) async {
    try {
      await _cartService.removeItem(itemId);
      await loadCart();
    } catch (e) {
      rethrow;
    }
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, AsyncValue<Cart?>>((ref) {
  return CartNotifier(ref.read(cartServiceProvider), ref);
});

// ─── Orders Provider ─────────────────────────────────────────────

final myOrdersProvider = FutureProvider<List<Order>>((ref) async {
  final orderService = ref.read(orderServiceProvider);
  return orderService.getMyOrders();
});

// ─── Wishlist Provider ───────────────────────────────────────────

final wishlistProvider = FutureProvider<List<WishlistItem>>((ref) async {
  final wishlistService = ref.read(wishlistServiceProvider);
  return wishlistService.getWishlist();
});

// ─── Product Detail Provider ─────────────────────────────────────

final productDetailProvider = FutureProvider.family<Product?, String>((ref, id) async {
  final productService = ref.read(productServiceProvider);
  return productService.getProductDetails(id);
});

// ─── Product Search Provider ─────────────────────────────────────

final searchResultsProvider = FutureProvider.family<List<Product>, String>((ref, query) async {
  if (query.isEmpty) return [];
  final productService = ref.read(productServiceProvider);
  return productService.searchProducts(query);
});
