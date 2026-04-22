import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../providers/app_providers.dart';
import '../../../core/constants/app_constants.dart';
import '../../../widgets/shared_widgets.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(cartProvider);
    final auth = ref.watch(authProvider);

    if (!auth.isAuthenticated) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Cart'), backgroundColor: AppColors.surface, foregroundColor: AppColors.textPrimary, elevation: 0),
        body: EmptyState(
          icon: Icons.shopping_bag_outlined,
          title: 'Sign in to view your cart',
          subtitle: 'Add items to your cart after signing in',
          buttonText: 'Sign In',
          onButtonTap: () => Navigator.of(context).pushNamed('/login'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Shopping Cart', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: cartAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => const Center(child: EmptyState(icon: Icons.error_outline, title: 'Failed to load cart')),
        data: (cart) {
          if (cart == null || cart.items.isEmpty) {
            return EmptyState(
              icon: Icons.shopping_bag_outlined,
              title: 'Your cart is empty',
              subtitle: 'Browse products and add them to your cart',
              buttonText: 'Start Shopping',
              onButtonTap: () => Navigator.of(context).pushReplacementNamed('/main'),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    return Dismissible(
                      key: Key(item.cartItemId),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.delete_outline, color: AppColors.error),
                      ),
                      onDismissed: (_) {
                        ref.read(cartProvider.notifier).removeItem(item.cartItemId);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
                        ),
                        child: Row(
                          children: [
                            // Image
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

                            // Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.productName ?? 'Product',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (item.variantName != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(item.variantName!, style: AppTextStyles.bodySmall),
                                    ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${AppConstants.currency}${item.effectivePrice.toStringAsFixed(0)}',
                                    style: AppTextStyles.price.copyWith(fontSize: 15),
                                  ),
                                ],
                              ),
                            ),

                            // Quantity controls
                            Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.divider),
                                  ),
                                  child: Column(
                                    children: [
                                      InkWell(
                                        onTap: () => ref.read(cartProvider.notifier).updateQuantity(item.cartItemId, item.quantity + 1),
                                        child: const Padding(
                                          padding: EdgeInsets.all(6),
                                          child: Icon(Icons.add, size: 16, color: AppColors.primary),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2),
                                        child: Text('${item.quantity}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                      ),
                                      InkWell(
                                        onTap: item.quantity > 1
                                            ? () => ref.read(cartProvider.notifier).updateQuantity(item.cartItemId, item.quantity - 1)
                                            : () => ref.read(cartProvider.notifier).removeItem(item.cartItemId),
                                        child: Padding(
                                          padding: const EdgeInsets.all(6),
                                          child: Icon(
                                            item.quantity > 1 ? Icons.remove : Icons.delete_outline,
                                            size: 16,
                                            color: item.quantity > 1 ? AppColors.textMuted : AppColors.error,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ─── Order Summary ──────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, -4))],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${cart.items.length} item${cart.items.length > 1 ? 's' : ''}', style: AppTextStyles.bodyMedium),
                        Text(
                          '${AppConstants.currency}${cart.items.fold<double>(0, (sum, item) => sum + item.lineTotal).toStringAsFixed(0)}',
                          style: AppTextStyles.price.copyWith(fontSize: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    VedashiButton(
                      text: 'Proceed to Checkout',
                      icon: Icons.arrow_forward,
                      onPressed: () => Navigator.of(context).pushNamed('/checkout'),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
