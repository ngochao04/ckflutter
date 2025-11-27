import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/antique_item.dart';
import '../../domain/repositories/antique_repository.dart';
import '../../domain/repositories/storage_repository.dart';
import '../../domain/usecases/get_items_usecase.dart';
import '../../domain/usecases/create_item_usecase.dart';
import '../../domain/usecases/search_items_usecase.dart';
import '../../data/repositories/antique_repository_impl.dart';
import '../../data/repositories/imgbb_storage_repository.dart'; // THÊM DÒNG NÀY
import '../../data/datasources/antique_remote_datasource.dart';
import '../../data/datasources/antique_local_datasource.dart';
import '../../data/models/antique_item_model.dart';
import '../../core/network/network_info.dart';

// Infrastructure Providers
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl(ref.watch(connectivityProvider));
});

// DataSource Providers
final antiqueRemoteDataSourceProvider = Provider<AntiqueRemoteDataSource>((ref) {
  return AntiqueRemoteDataSourceImpl(
    firestore: ref.watch(firestoreProvider),
    auth: ref.watch(firebaseAuthProvider),
  );
});

final antiqueLocalDataSourceProvider = Provider<AntiqueLocalDataSource>((ref) {
  final box = Hive.box<AntiqueItemModel>('antique_items');
  return AntiqueLocalDataSourceImpl(box);
});

// Repository Providers
final antiqueRepositoryProvider = Provider<AntiqueRepository>((ref) {
  return AntiqueRepositoryImpl(
    remoteDataSource: ref.watch(antiqueRemoteDataSourceProvider),
    localDataSource: ref.watch(antiqueLocalDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

// ✅ THAY ĐỔI Ở ĐÂY - Dùng ImgBB thay vì Supabase
final storageRepositoryProvider = Provider<StorageRepository>((ref) {
  return ImgBBStorageRepository();
});

// UseCase Providers
final getItemsUseCaseProvider = Provider<GetItemsUseCase>((ref) {
  return GetItemsUseCase(ref.watch(antiqueRepositoryProvider));
});

final createItemUseCaseProvider = Provider<CreateItemUseCase>((ref) {
  return CreateItemUseCase(ref.watch(antiqueRepositoryProvider));
});

final searchItemsUseCaseProvider = Provider<SearchItemsUseCase>((ref) {
  return SearchItemsUseCase(ref.watch(antiqueRepositoryProvider));
});

// Auth Provider
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

// Network Status Provider
final networkStatusProvider = StreamProvider<bool>((ref) {
  return ref.watch(networkInfoProvider).onConnectivityChanged;
});

// Items State Provider
final itemsProvider = StateNotifierProvider<ItemsNotifier, ItemsState>((ref) {
  return ItemsNotifier(
    getItemsUseCase: ref.watch(getItemsUseCaseProvider),
    createItemUseCase: ref.watch(createItemUseCaseProvider),
    searchItemsUseCase: ref.watch(searchItemsUseCaseProvider),
    repository: ref.watch(antiqueRepositoryProvider),
  );
});

// Items State
class ItemsState {
  final List<AntiqueItem> items;
  final bool isLoading;
  final String? error;
  final String? selectedCategory;

  const ItemsState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.selectedCategory,
  });

  ItemsState copyWith({
    List<AntiqueItem>? items,
    bool? isLoading,
    String? error,
    String? selectedCategory,
  }) {
    return ItemsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}

// Items Notifier
class ItemsNotifier extends StateNotifier<ItemsState> {
  final GetItemsUseCase getItemsUseCase;
  final CreateItemUseCase createItemUseCase;
  final SearchItemsUseCase searchItemsUseCase;
  final AntiqueRepository repository;

  ItemsNotifier({
    required this.getItemsUseCase,
    required this.createItemUseCase,
    required this.searchItemsUseCase,
    required this.repository,
  }) : super(const ItemsState());

  Future<void> loadItems({String? category}) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await getItemsUseCase(category: category);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (items) => state = state.copyWith(
        items: items,
        isLoading: false,
        selectedCategory: category,
      ),
    );
  }

  Future<void> createItem(AntiqueItem item) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await createItemUseCase(item);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (newItem) {
        final updatedItems = [newItem, ...state.items];
        state = state.copyWith(
          items: updatedItems,
          isLoading: false,
        );
      },
    );
  }

  Future<void> updateItem(AntiqueItem item) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await repository.updateItem(item);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (updatedItem) {
        final updatedItems = state.items.map((i) {
          return i.id == updatedItem.id ? updatedItem : i;
        }).toList();
        state = state.copyWith(
          items: updatedItems,
          isLoading: false,
        );
      },
    );
  }

  Future<void> deleteItem(String id) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await repository.deleteItem(id);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (_) {
        final updatedItems = state.items.where((i) => i.id != id).toList();
        state = state.copyWith(
          items: updatedItems,
          isLoading: false,
        );
      },
    );
  }

  Future<void> searchItems(String query) async {
    if (query.trim().isEmpty) {
      await loadItems();
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    final result = await searchItemsUseCase(query);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (items) => state = state.copyWith(
        items: items,
        isLoading: false,
      ),
    );
  }

  void setCategory(String? category) {
    loadItems(category: category);
  }
}

// Selected Item Provider
final selectedItemProvider = StateProvider<AntiqueItem?>((ref) => null);

// Categories Provider
// Categories Provider - THAY ĐỔI Ở ĐÂY
final categoriesProvider = Provider<List<Map<String, String>>>((ref) {
  return [
    {'en': 'Furniture', 'vi': 'Đồ gỗ'},
    {'en': 'Ceramics', 'vi': 'Gốm sứ'},
    {'en': 'Paintings', 'vi': 'Tranh vẽ'},
    {'en': 'Jewelry', 'vi': 'Trang sức'},
    {'en': 'Textiles', 'vi': 'Vải dệt'},
    {'en': 'Sculptures', 'vi': 'Điêu khắc'},
    {'en': 'Books', 'vi': 'Sách cổ'},
    {'en': 'Coins', 'vi': 'Tiền xu'},
    {'en': 'Stamps', 'vi': 'Tem'},
    {'en': 'Instruments', 'vi': 'Nhạc cụ'},
    {'en': 'Others', 'vi': 'Khác'},
  ];
});

// Statistics Provider
final statisticsProvider = Provider<Map<String, dynamic>>((ref) {
  final items = ref.watch(itemsProvider).items;
  
  if (items.isEmpty) {
    return {
      'totalItems': 0,
      'totalValue': 0.0,
      'averageValue': 0.0,
      'categoryCounts': <String, int>{},
    };
  }

  final totalValue = items.fold<double>(
    0,
    (sum, item) => sum + item.estimatedValue,
  );

  final categoryCounts = <String, int>{};
  for (var item in items) {
    categoryCounts[item.category] = (categoryCounts[item.category] ?? 0) + 1;
  }

  return {
    'totalItems': items.length,
    'totalValue': totalValue,
    'averageValue': totalValue / items.length,
    'categoryCounts': categoryCounts,
  };
});