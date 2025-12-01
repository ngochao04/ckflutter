import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/providers.dart';
import '../../core/constants/app_strings.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

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
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statisticsProvider);
    final currencyFormatter = NumberFormat.currency(symbol: '₫', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.statistics),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary Cards
          _StatCard(
            icon: Icons.inventory,
            title: AppStrings.totalItems,
            value: stats['totalItems'].toString(),
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          
          _StatCard(
            icon: Icons.attach_money,
            title: AppStrings.totalValue,
            value: currencyFormatter.format(stats['totalValue']),
            color: Colors.green,
          ),
          const SizedBox(height: 16),
          
          _StatCard(
            icon: Icons.trending_up,
            title: AppStrings.averageValue,
            value: currencyFormatter.format(stats['averageValue']),
            color: Colors.orange,
          ),
          const SizedBox(height: 32),

          // Category Breakdown
          const Text(
            AppStrings.itemsByCategory,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          if ((stats['categoryCounts'] as Map<String, int>).isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(AppStrings.noItemsYet),
              ),
            )
          else
            ...(stats['categoryCounts'] as Map<String, int>).entries.map(
              (entry) => _CategoryCard(
                category: _getCategoryVietnamese(entry.key),
                count: entry.value,
                totalItems: stats['totalItems'],
              ),
            ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String category;
  final int count;
  final int totalItems;

  const _CategoryCard({
    required this.category,
    required this.count,
    required this.totalItems,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (count / totalItems * 100).toStringAsFixed(1);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  category,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$count ${AppStrings.items} ($percentage%)',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: count / totalItems,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}