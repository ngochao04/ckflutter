import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../providers/providers.dart';
import '../widgets/empty_state.dart';
import 'item_detail_screen.dart';
import '../../core/constants/app_strings.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final currencyFormatter = NumberFormat.currency(symbol: '₫', decimalDigits: 0);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      ref.read(itemsProvider.notifier).loadItems();
    } else {
      ref.read(itemsProvider.notifier).searchItems(query);
    }
  }

  String _getCategoryVietnamese(String category) {
    switch (category) {
      case 'Furniture': return AppStrings.furniture;
      case 'Ceramics': return AppStrings.ceramics;
      case 'Paintings': return AppStrings.paintings;
      case 'Jewelry': return AppStrings.jewelry;
      case 'Textiles': return AppStrings.textiles;
      case 'Sculptures': return AppStrings.sculptures;
      case 'Books': return AppStrings.books;
      case 'Coins': return AppStrings.coins;
      case 'Stamps': return AppStrings.stamps;
      case 'Instruments': return AppStrings.instruments;
      default: return AppStrings.others;
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemsState = ref.watch(itemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: AppStrings.searchItems,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: _performSearch,
          ),
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                _performSearch('');
              },
            ),
        ],
      ),
      body: itemsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : itemsState.items.isEmpty
              ? EmptyState(
                  icon: Icons.search_off,
                  title: _searchController.text.isEmpty
                      ? AppStrings.startSearching
                      : AppStrings.noResultsFound,
                  message: _searchController.text.isEmpty
                      ? AppStrings.enterKeywords
                      : AppStrings.tryDifferentKeywords,
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: itemsState.items.length,
                  itemBuilder: (context, index) {
                    final item = itemsState.items[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: item.imageUrls.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: item.imageUrls.first,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.error),
                                  ),
                                )
                              : Container(
                                  width: 60,
                                  height: 60,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.image),
                                ),
                        ),
                        title: Text(
                          item.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(_getCategoryVietnamese(item.category)),
                            const SizedBox(height: 4),
                            Text(
                              currencyFormatter.format(item.estimatedValue),
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ItemDetailScreen(item: item),
                            ),
                          );
                          if (result == true && mounted) {
                            _performSearch(_searchController.text);
                          }
                        },
                      ),
                    );
                  },
                ),
    );
  }
}