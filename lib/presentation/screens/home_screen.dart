// lib/presentation/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../providers/providers.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_message.dart';
import 'item_detail_screen.dart';
import 'add_item_screen.dart';
import 'search_screen.dart';
import 'statistics_screen.dart';
import '../../core/constants/app_strings.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final currencyFormatter = NumberFormat.currency(symbol: '₫', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(itemsProvider.notifier).loadItems());
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(firebaseAuthProvider).signOut();
            },
            child: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemsState = ref.watch(itemsProvider);
    final networkStatus = ref.watch(networkStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.antiqueCollection),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: AppStrings.search,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: AppStrings.statistics,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatisticsScreen()),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutDialog();
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 12),
                      Text('Đăng xuất', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Network Status Banner
          networkStatus.when(
            data: (isConnected) => !isConnected
                ? Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    color: Colors.orange[100],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_off, size: 16, color: Colors.orange[900]),
                        const SizedBox(width: 8),
                        Text(
                          AppStrings.offlineMode,
                          style: TextStyle(color: Colors.orange[900]),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          
          // Category Filter
          _buildCategoryFilter(),
          
          // Items Grid
          Expanded(
            child: _buildContent(itemsState),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddItemScreen()),
          );
          if (result == true && mounted) {
            ref.read(itemsProvider.notifier).loadItems();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text(AppStrings.addItem),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final selectedCategory = ref.watch(itemsProvider).selectedCategory;

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _CategoryChip(
            label: AppStrings.all,
            isSelected: selectedCategory == null,
            onTap: () => ref.read(itemsProvider.notifier).setCategory(null),
          ),
          _CategoryChip(
            label: AppStrings.furniture,
            isSelected: selectedCategory == 'Furniture',
            onTap: () => ref.read(itemsProvider.notifier).setCategory('Furniture'),
          ),
          _CategoryChip(
            label: AppStrings.ceramics,
            isSelected: selectedCategory == 'Ceramics',
            onTap: () => ref.read(itemsProvider.notifier).setCategory('Ceramics'),
          ),
          _CategoryChip(
            label: AppStrings.paintings,
            isSelected: selectedCategory == 'Paintings',
            onTap: () => ref.read(itemsProvider.notifier).setCategory('Paintings'),
          ),
          _CategoryChip(
            label: AppStrings.jewelry,
            isSelected: selectedCategory == 'Jewelry',
            onTap: () => ref.read(itemsProvider.notifier).setCategory('Jewelry'),
          ),
          _CategoryChip(
            label: AppStrings.others,
            isSelected: selectedCategory == 'Others',
            onTap: () => ref.read(itemsProvider.notifier).setCategory('Others'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ItemsState state) {
    if (state.isLoading && state.items.isEmpty) {
      return const ShimmerLoading();
    }

    if (state.error != null) {
      return ErrorMessage(
        message: state.error!,
        onRetry: () => ref.read(itemsProvider.notifier).loadItems(),
      );
    }

    if (state.items.isEmpty) {
      return const EmptyState(
        icon: Icons.collections,
        title: AppStrings.noItemsYet,
        message: AppStrings.startBuilding,
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(itemsProvider.notifier).loadItems(
        category: state.selectedCategory,
      ),
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: state.items.length,
        itemBuilder: (context, index) {
          final item = state.items[index];
          return _ItemCard(
            item: item,
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ItemDetailScreen(item: item),
                ),
              );
              if (result == true && mounted) {
                ref.read(itemsProvider.notifier).loadItems();
              }
            },
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
        checkmarkColor: Theme.of(context).primaryColor,
      ),
    );
  }
}

class _ItemCard extends StatelessWidget {
  final dynamic item;
  final VoidCallback onTap;

  const _ItemCard({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(symbol: '₫', decimalDigits: 0);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: item.imageUrls.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: item.imageUrls.first,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported),
                      ),
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image, size: 48),
                    ),
            ),
            
            // Details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getCategoryVietnamese(item.category),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      currencyFormatter.format(item.estimatedValue),
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
}