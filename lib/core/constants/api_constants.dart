/// All API endpoints extracted from Vedashi backend repository.
/// Base URL: https://ecommerce-backend-h23p.onrender.com
class ApiConstants {
  static const String baseUrl = 'https://ecommerce-backend-h23p.onrender.com';
  static const String apiPrefix = '/api';

  // ─── Auth ──────────────────────────────────────────────────
  static const String login = '$apiPrefix/auth/login';
  static const String register = '$apiPrefix/auth/register';
  static const String refreshToken = '$apiPrefix/auth/refresh-token';
  static const String logout = '$apiPrefix/auth/logout';
  static const String getMe = '$apiPrefix/auth/me';
  static const String changePassword = '$apiPrefix/auth/change-password';
  static const String forgotPassword = '$apiPrefix/auth/forgot-password';
  static const String resetPassword = '$apiPrefix/auth/reset-password';
  static const String sendVerificationEmail = '$apiPrefix/auth/send-verification-email';
  static const String verifyEmail = '$apiPrefix/auth/verify-email';

  // ─── Products ──────────────────────────────────────────────
  static const String products = '$apiPrefix/products';
  static String productById(String id) => '$apiPrefix/products/$id';
  static String productDetails(String id) => '$apiPrefix/products/$id/details';
  static const String productSearch = '$apiPrefix/products/search';
  static const String productSuggestions = '$apiPrefix/products/suggestions';
  static const String productFilter = '$apiPrefix/products/filter';
  static const String bestSellers = '$apiPrefix/products/best-sellers';
  static const String featuredProducts = '$apiPrefix/products/featured';
  static const String newArrivals = '$apiPrefix/products/new-arrivals';
  static String relatedProducts(String id) => '$apiPrefix/products/$id/related';
  static String similarProducts(String id) => '$apiPrefix/products/$id/similar';
  static String productImages(String id) => '$apiPrefix/products/$id/images';

  // ─── Categories ────────────────────────────────────────────
  static const String categories = '$apiPrefix/categories';
  static String categoryBySlug(String slug) => '$apiPrefix/categories/slug/$slug';
  static String categoryProducts(String id) => '$apiPrefix/categories/$id/products';

  // ─── Cart ──────────────────────────────────────────────────
  static const String cart = '$apiPrefix/cart';
  static String cartById(String id) => '$apiPrefix/cart/$id';
  static const String cartItems = '$apiPrefix/cart/items';
  static String cartItem(String itemId) => '$apiPrefix/cart/items/$itemId';
  static const String cartMerge = '$apiPrefix/cart/merge';

  // ─── Orders ────────────────────────────────────────────────
  static const String checkout = '$apiPrefix/orders/checkout';
  static const String directOrder = '$apiPrefix/orders/direct';
  static const String myOrders = '$apiPrefix/orders/my';
  static String orderById(String id) => '$apiPrefix/orders/$id';
  static String trackOrder(String id) => '$apiPrefix/orders/$id/track';
  static String cancelOrder(String id) => '$apiPrefix/orders/$id/cancel';

  // ─── Payments ──────────────────────────────────────────────
  static const String initiateCheckout = '$apiPrefix/payments/razorpay/initiate-checkout';
  static const String verifyPayment = '$apiPrefix/payments/verify';
  static String paymentStatus(String orderId) => '$apiPrefix/payments/order/$orderId';

  // ─── Wishlist ──────────────────────────────────────────────
  static const String wishlist = '$apiPrefix/wishlist';
  static String wishlistCheck(String productId) => '$apiPrefix/wishlist/check/$productId';
  static String wishlistRemove(String productId) => '$apiPrefix/wishlist/$productId';

  // ─── Reviews ───────────────────────────────────────────────
  static const String reviews = '$apiPrefix/reviews';
  static String productReviews(String productId) => '$apiPrefix/reviews/product/$productId';
  static String reviewSummary(String productId) => '$apiPrefix/reviews/product/$productId/summary';
  static const String myReviews = '$apiPrefix/reviews/my';

  // ─── Customers ─────────────────────────────────────────────
  static String customerProfile(String id) => '$apiPrefix/customers/$id';
  static String customerAddresses(String id) => '$apiPrefix/customers/$id/addresses';
  static String customerAddress(String custId, String addrId) =>
      '$apiPrefix/customers/$custId/addresses/$addrId';

  // ─── Hero Slides ───────────────────────────────────────────
  static const String heroSlides = '$apiPrefix/media/hero/active';

  // ─── Search ────────────────────────────────────────────────
  static const String searchAutocomplete = '$apiPrefix/search/autocomplete';
  static const String searchFull = '$apiPrefix/search';

  // ─── Coupons ───────────────────────────────────────────────
  static const String validateCoupon = '$apiPrefix/coupons/validate';
}
