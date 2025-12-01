// lib/presentation/screens/item_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/antique_item.dart';
import '../providers/providers.dart';
import 'add_item_screen.dart';
import '../../core/constants/app_strings.dart';

class ItemDetailScreen extends ConsumerWidget {
  final AntiqueItem item;

  const ItemDetailScreen({super.key, required this.item});

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

  String _getConditionVietnamese(String condition) {
    switch (condition) {
      case 'Excellent': return AppStrings.excellent;
      case 'Good': return AppStrings.good;
      case 'Fair': return AppStrings.fair;
      case 'Poor': return AppStrings.poor;
      case 'Restoration Needed': return AppStrings.restorationNeeded;
      default: return condition;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyFormatter = NumberFormat.currency(symbol: '₫', decimalDigits: 0);
    final dateFormatter = DateFormat('dd/MM/yyyy');

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: item.imageUrls.isNotEmpty
                  ? PageView.builder(
                      itemCount: item.imageUrls.length,
                      itemBuilder: (context, index) {
                        return CachedNetworkImage(
                          imageUrl: item.imageUrls[index],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.error),
                          ),
                        );
                      },
                    )
                  : Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image, size: 80),
                    ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: AppStrings.edit,
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddItemScreen(itemToEdit: item),
                    ),
                  );
                  if (result == true && context.mounted) {
                    Navigator.pop(context, true);
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                tooltip: AppStrings.delete,
                onPressed: () => _showDeleteDialog(context, ref),
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Category
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(_getCategoryVietnamese(item.category)),
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  ),
                  const SizedBox(height: 24),

                  // Value
                  _InfoCard(
                    icon: Icons.attach_money,
                    title: AppStrings.estimatedValue,
                    content: currencyFormatter.format(item.estimatedValue),
                    color: Colors.green,
                  ),
                  const SizedBox(height: 16),

                  // Condition
                  _InfoCard(
                    icon: Icons.star,
                    title: AppStrings.condition,
                    content: _getConditionVietnamese(item.condition),
                    color: _getConditionColor(item.condition),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    AppStrings.description,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.description,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 24),

                  // Origin & Period
                  if (item.origin.isNotEmpty || item.period.isNotEmpty) ...[
                    Text(
                      AppStrings.originAndHistory,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (item.origin.isNotEmpty)
                      _DetailRow(
                        icon: Icons.location_on,
                        label: AppStrings.origin,
                        value: item.origin,
                      ),
                    if (item.period.isNotEmpty)
                      _DetailRow(
                        icon: Icons.history,
                        label: AppStrings.period,
                        value: item.period,
                      ),
                    const SizedBox(height: 24),
                  ],

                  // Acquisition Date
                  _DetailRow(
                    icon: Icons.calendar_today,
                    label: AppStrings.acquisitionDate,
                    value: dateFormatter.format(item.acquisitionDate),
                  ),
                  const SizedBox(height: 24),

                  // Provenance
                  if (item.provenance.isNotEmpty) ...[
                    Text(
                      AppStrings.provenance,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.withOpacity(0.3)),
                      ),
                      child: Text(
                        item.provenance,
                        style: const TextStyle(fontSize: 15, height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Metadata
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    '${AppStrings.created}: ${dateFormatter.format(item.createdAt)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  Text(
                    '${AppStrings.lastUpdated}: ${dateFormatter.format(item.updatedAt)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getConditionColor(String condition) {
    switch (condition) {
      case 'Excellent':
        return Colors.green;
      case 'Good':
        return Colors.blue;
      case 'Fair':
        return Colors.orange;
      case 'Poor':
        return Colors.red;
      case 'Restoration Needed':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.deleteItem),
        content: Text('${AppStrings.deleteConfirm} "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(itemsProvider.notifier).deleteItem(item.id);
              if (context.mounted) {
                Navigator.pop(context, true);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text(AppStrings.itemDeletedSuccess)),
                );
              }
            },
            child: Text(
              AppStrings.delete.toUpperCase(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.content,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
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
                  content,
                  style: TextStyle(
                    fontSize: 20,
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

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}