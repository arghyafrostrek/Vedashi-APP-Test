import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../providers/app_providers.dart';
import '../../../core/constants/app_constants.dart';
import '../../../widgets/product_card.dart';
import '../../../widgets/shared_widgets.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _heroIndex = 0;
  final PageController _heroPageController = PageController();
  Timer? _autoPlayTimer;

  @override
  void dispose() {
    _heroPageController.dispose();
    _autoPlayTimer?.cancel();
    super.dispose();
  }

  void _startAutoPlay(int slideCount) {
    _autoPlayTimer?.cancel();
    if (slideCount <= 1) return;
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_heroPageController.hasClients) {
        final next = (_heroIndex + 1) % slideCount;
        _heroPageController.animateToPage(next, duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeData = ref.watch(homeDataProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: homeData.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => const Center(
          child: EmptyState(
            icon: Icons.error_outline,
            title: 'Failed to load',
            subtitle: 'Pull down to retry',
          ),
        ),
        data: (data) => RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async => ref.invalidate(homeDataProvider),
          child: CustomScrollView(
            slivers: [
              // ─── App Bar ─────────────────────────────────────
              SliverAppBar(
                floating: true,
                snap: true,
                backgroundColor: AppColors.surface,
                elevation: 0,
                title: const Row(
                  children: [
                    Icon(Icons.eco_rounded, color: AppColors.primary, size: 28),
                    SizedBox(width: 8),
                    Text(
                      'VEDASHI',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.search, color: AppColors.textPrimary),
                    onPressed: () => Navigator.of(context).pushNamed('/search'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_none_outlined, color: AppColors.textPrimary),
                    onPressed: () {},
                  ),
                ],
              ),

              // ─── Hero Carousel ───────────────────────────────
              if (data.heroSlides.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: SizedBox(
                            height: 180,
                            child: Builder(
                              builder: (context) {
                                _startAutoPlay(data.heroSlides.length);
                                return PageView.builder(
                                  controller: _heroPageController,
                                  itemCount: data.heroSlides.length,
                                  onPageChanged: (i) => setState(() => _heroIndex = i),
                                  itemBuilder: (context, index) {
                                    final slide = data.heroSlides[index];
                                    return CachedNetworkImage(
                                      imageUrl: slide.imageUrl,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      placeholder: (_, __) => Container(color: AppColors.shimmerBase),
                                      errorWidget: (_, __, ___) => Container(
                                        color: AppColors.primary.withValues(alpha: 0.1),
                                        child: const Icon(Icons.image, size: 48, color: AppColors.textMuted),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        AnimatedSmoothIndicator(
                          activeIndex: _heroIndex,
                          count: data.heroSlides.length,
                          effect: const WormEffect(
                            dotHeight: 6,
                            dotWidth: 6,
                            activeDotColor: AppColors.primary,
                            dotColor: AppColors.divider,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // ─── Categories ──────────────────────────────────
              if (data.categories.isNotEmpty) ...[
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 28),
                    child: SectionHeader(title: 'Categories', subtitle: 'Explore curated collections'),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 120,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      scrollDirection: Axis.horizontal,
                      itemCount: data.categories.take(8).length,
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final cat = data.categories[index];
                        return GestureDetector(
                          onTap: () => Navigator.of(context).pushNamed('/products', arguments: {'category': cat.slug}),
                          child: SizedBox(
                            width: 80,
                            child: Column(
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: cat.imageUrl != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(18),
                                          child: CachedNetworkImage(
                                            imageUrl: cat.imageUrl!,
                                            fit: BoxFit.cover,
                                            errorWidget: (_, __, ___) => const Icon(Icons.category, color: AppColors.primary),
                                          ),
                                        )
                                      : const Icon(Icons.category_outlined, color: AppColors.primary, size: 28),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  cat.name,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],

              // ─── Best Sellers ────────────────────────────────
              if (data.bestSellers.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 28),
                    child: SectionHeader(
                      title: 'Best Sellers',
                      subtitle: 'Our most-loved natural wellness essentials',
                      onViewAll: () => Navigator.of(context).pushNamed('/products', arguments: {'bestSeller': true}),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 260,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      scrollDirection: Axis.horizontal,
                      itemCount: data.bestSellers.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        return SizedBox(
                          width: 160,
                          child: ProductCard(
                            product: data.bestSellers[index],
                            onTap: () => Navigator.of(context).pushNamed(
                              '/product-detail',
                              arguments: data.bestSellers[index].productId,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],

              // ─── New Arrivals ────────────────────────────────
              if (data.newArrivals.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 28),
                    child: SectionHeader(
                      title: 'New Arrivals',
                      subtitle: 'Discover the newest additions',
                      onViewAll: () => Navigator.of(context).pushNamed('/products', arguments: {'newArrival': true}),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.62,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => ProductCard(
                        product: data.newArrivals[index],
                        onTap: () => Navigator.of(context).pushNamed(
                          '/product-detail',
                          arguments: data.newArrivals[index].productId,
                        ),
                      ),
                      childCount: data.newArrivals.length,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
