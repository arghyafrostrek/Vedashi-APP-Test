import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../providers/app_providers.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/product_model.dart';
import '../../../widgets/shared_widgets.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _currentImageIndex = 0;
  ProductVariant? _selectedVariant;
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailProvider(widget.productId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: productAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => const Center(child: EmptyState(icon: Icons.error_outline, title: 'Failed to load product')),
        data: (product) {
          if (product == null) {
            return const Center(child: EmptyState(icon: Icons.search_off, title: 'Product not found'));
          }

          _selectedVariant ??= product.defaultVariant;
          final images = product.images.isNotEmpty ? product.images : [product.thumbnailUrl ?? ''];
          final effectivePrice = _selectedVariant?.effectivePrice ?? product.effectivePrice;
          final originalPrice = _selectedVariant?.price ?? product.originalPrice;
          final hasDiscount = effectivePrice < originalPrice;

          return CustomScrollView(
            slivers: [
              // ─── Image Gallery ──────────────────────────────
              SliverAppBar(
                expandedHeight: MediaQuery.of(context).size.width * 0.9,
                pinned: true,
                backgroundColor: Colors.white,
                iconTheme: const IconThemeData(color: AppColors.textPrimary),
                actions: [
                  IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: PageView.builder(
                    itemCount: images.length,
                    onPageChanged: (i) => setState(() => _currentImageIndex = i),
                    itemBuilder: (context, index) {
                      final img = images[index];
                      if (img.isEmpty) return Container(color: AppColors.shimmerBase);
                      return CachedNetworkImage(
                        imageUrl: img,
                        fit: BoxFit.contain,
                        placeholder: (_, __) => Container(color: AppColors.shimmerBase),
                        errorWidget: (_, __, ___) => Container(
                          color: AppColors.shimmerBase,
                          child: const Icon(Icons.image, size: 64, color: AppColors.textMuted),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // ─── Product Info ───────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image dots
                        if (images.length > 1)
                          Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(images.length, (i) => Container(
                                width: _currentImageIndex == i ? 20 : 6,
                                height: 6,
                                margin: const EdgeInsets.symmetric(horizontal: 2),
                                decoration: BoxDecoration(
                                  color: _currentImageIndex == i ? AppColors.primary : AppColors.divider,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              )),
                            ),
                          ),

                        const SizedBox(height: 16),

                        // Brand
                        if (product.brand != null)
                          Text(
                            product.brand!.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                              letterSpacing: 1,
                            ),
                          ),

                        const SizedBox(height: 6),

                        // Name
                        Text(product.productName, style: AppTextStyles.heading2),

                        const SizedBox(height: 12),

                        // Rating
                        if (product.averageRating != null && product.averageRating! > 0)
                          Row(
                            children: [
                              ...List.generate(5, (i) => Icon(
                                i < product.averageRating!.round() ? Icons.star_rounded : Icons.star_outline_rounded,
                                size: 18,
                                color: AppColors.starYellow,
                              )),
                              const SizedBox(width: 8),
                              Text(
                                '${product.averageRating!.toStringAsFixed(1)} (${product.reviewCount ?? 0} reviews)',
                                style: AppTextStyles.bodySmall,
                              ),
                            ],
                          ),

                        const SizedBox(height: 16),

                        // Price
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${AppConstants.currency}${effectivePrice.toStringAsFixed(0)}',
                              style: AppTextStyles.price.copyWith(fontSize: 26),
                            ),
                            if (hasDiscount) ...[
                              const SizedBox(width: 10),
                              Text(
                                '${AppConstants.currency}${originalPrice.toStringAsFixed(0)}',
                                style: AppTextStyles.salePrice.copyWith(fontSize: 16),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.saleBadge.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '-${(((originalPrice - effectivePrice) / originalPrice) * 100).round()}%',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.saleBadge),
                                ),
                              ),
                            ],
                          ],
                        ),

                        // Stock status
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              product.inStock ? Icons.check_circle : Icons.cancel,
                              size: 16,
                              color: product.inStock ? AppColors.success : AppColors.error,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              product.inStock ? 'In Stock' : 'Out of Stock',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: product.inStock ? AppColors.success : AppColors.error,
                              ),
                            ),
                          ],
                        ),

                        // ─── Variants ─────────────────────────────
                        if (product.variants.length > 1) ...[
                          const SizedBox(height: 20),
                          Text('Options', style: AppTextStyles.heading3),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: product.variants.where((v) => v.isActive).map((variant) {
                              final isSelected = _selectedVariant?.variantId == variant.variantId;
                              return GestureDetector(
                                onTap: () => setState(() => _selectedVariant = variant),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSelected ? AppColors.primary : AppColors.divider,
                                      width: isSelected ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Text(
                                    variant.variantName ?? variant.variantSku ?? 'Option',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],

                        // ─── Quantity ─────────────────────────────
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Text('Quantity', style: AppTextStyles.heading3),
                            const SizedBox(width: 16),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.divider),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove, size: 18),
                                    onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                                  ),
                                  Text('$_quantity', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                  IconButton(
                                    icon: const Icon(Icons.add, size: 18),
                                    onPressed: () => setState(() => _quantity++),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // ─── Description ──────────────────────────
                        if (product.description != null && product.description!.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Text('Description', style: AppTextStyles.heading3),
                          const SizedBox(height: 8),
                          Text(product.description!, style: AppTextStyles.bodyMedium.copyWith(height: 1.6)),
                        ],

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),

      // ─── Bottom Action Bar ──────────────────────────────
      bottomNavigationBar: productAsync.when(
        loading: () => null,
        error: (_, __) => null,
        data: (product) {
          if (product == null || !product.inStock) return null;
          return Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, -4))],
            ),
            child: VedashiButton(
              text: 'Add to Cart',
              icon: Icons.shopping_bag_outlined,
              onPressed: () async {
                final auth = ref.read(authProvider);
                if (!auth.isAuthenticated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Please sign in to add items to cart'),
                      backgroundColor: AppColors.warning,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                  return;
                }

                try {
                  final cartState = ref.read(cartProvider);
                  final cart = cartState.value;
                  if (cart != null) {
                    await ref.read(cartProvider.notifier).addItem(
                      cart.cartId,
                      variantId: _selectedVariant?.variantId,
                      productId: product.productId,
                      quantity: _quantity,
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Added to cart!'),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating),
                    );
                  }
                }
              },
            ),
          );
        },
      ),
    );
  }
}
