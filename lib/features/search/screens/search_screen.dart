import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/app_providers.dart';
import '../../../core/constants/app_constants.dart';
import '../../../widgets/product_card.dart';
import '../../../widgets/shared_widgets.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});
  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface, elevation: 0, foregroundColor: AppColors.textPrimary,
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Search products...', border: InputBorder.none, hintStyle: TextStyle(color: AppColors.textMuted)),
          onChanged: (v) { if (v.length >= 2) setState(() => _query = v); },
          onSubmitted: (v) => setState(() => _query = v),
        ),
        actions: [
          if (_controller.text.isNotEmpty) IconButton(icon: const Icon(Icons.close), onPressed: () { _controller.clear(); setState(() => _query = ''); }),
        ],
      ),
      body: _query.isEmpty
          ? const Center(child: EmptyState(icon: Icons.search, title: 'Search for products', subtitle: 'Type at least 2 characters'))
          : Consumer(builder: (context, ref, _) {
              final results = ref.watch(searchResultsProvider(_query));
              return results.when(
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                error: (e, _) => const Center(child: EmptyState(icon: Icons.error_outline, title: 'Search failed')),
                data: (products) {
                  if (products.isEmpty) return const Center(child: EmptyState(icon: Icons.search_off, title: 'No results', subtitle: 'Try a different search'));
                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.62),
                    itemCount: products.length,
                    itemBuilder: (context, i) => ProductCard(
                      product: products[i],
                      onTap: () => Navigator.of(context).pushNamed('/product-detail', arguments: products[i].productId),
                    ),
                  );
                },
              );
            }),
    );
  }
}
