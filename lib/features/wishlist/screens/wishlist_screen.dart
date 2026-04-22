import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../providers/app_providers.dart';
import '../../../core/constants/app_constants.dart';
import '../../../widgets/shared_widgets.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    if (!auth.isAuthenticated) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Wishlist'), backgroundColor: AppColors.surface, foregroundColor: AppColors.textPrimary, elevation: 0),
        body: EmptyState(
          icon: Icons.favorite_border,
          title: 'Sign in to view your wishlist',
          buttonText: 'Sign In',
          onButtonTap: () => Navigator.of(context).pushNamed('/login'),
        ),
      );
    }

    final wishlistAsync = ref.watch(wishlistProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Wishlist', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: wishlistAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => const Center(child: EmptyState(icon: Icons.error_outline, title: 'Failed to load wishlist')),
        data: (items) {
          if (items.isEmpty) {
            return EmptyState(
              icon: Icons.favorite_border,
              title: 'Your wishlist is empty',
              subtitle: 'Save products you love for later',
              buttonText: 'Browse Products',
              onButtonTap: () => Navigator.of(context).pushReplacementNamed('/main'),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => ref.invalidate(wishlistProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 80,
                          height: 80,
                          child: item.thumbnailUrl != null
                              ? CachedNetworkImage(imageUrl: item.thumbnailUrl!, fit: BoxFit.cover)
                              : Container(color: AppColors.shimmerBase, child: const Icon(Icons.image, color: AppColors.textMuted)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (item.brand != null)
                              Text(item.brand!.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.primary, letterSpacing: 0.5)),
                            const SizedBox(height: 2),
                            Text(
                              item.productName ?? 'Product',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            if (item.price != null)
                              Text('${AppConstants.currency}${item.price!.toStringAsFixed(0)}', style: AppTextStyles.price.copyWith(fontSize: 15)),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.favorite, color: AppColors.saleBadge, size: 22),
                            onPressed: () {
                              ref.read(wishlistServiceProvider).removeFromWishlist(item.productId);
                              ref.invalidate(wishlistProvider);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.shopping_bag_outlined, color: AppColors.primary, size: 20),
                            onPressed: () => Navigator.of(context).pushNamed('/product-detail', arguments: item.productId),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
