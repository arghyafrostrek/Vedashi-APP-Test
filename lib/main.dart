import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_constants.dart';
import 'features/splash/splash_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/home/screens/main_screen.dart';
import 'features/product/screens/product_detail_screen.dart';
import 'features/search/screens/search_screen.dart';
import 'features/orders/screens/orders_screen.dart';
import 'features/wishlist/screens/wishlist_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: VedashiApp()));
}

class VedashiApp extends StatelessWidget {
  const VedashiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.surface,
          error: AppColors.error,
        ),
      ),
      home: const SplashScreen(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/register':
            return MaterialPageRoute(builder: (_) => const RegisterScreen());
          case '/main':
            return MaterialPageRoute(builder: (_) => const MainScreen());
          case '/search':
            return MaterialPageRoute(builder: (_) => const SearchScreen());
          case '/orders':
            return MaterialPageRoute(builder: (_) => const OrdersScreen());
          case '/wishlist':
            return MaterialPageRoute(builder: (_) => const WishlistScreen());
          case '/product-detail':
            final productId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => ProductDetailScreen(productId: productId),
            );
          default:
            return MaterialPageRoute(builder: (_) => const SplashScreen());
        }
      },
    );
  }
}
