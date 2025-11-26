// lib/presentation/screens/add_item_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/antique_item.dart';
import '../../core/utils/image_helper.dart';
import '../providers/providers.dart';

class AddItemScreen extends ConsumerStatefulWidget {
  final AntiqueItem? itemToEdit;

  const AddItemScreen({super.key, this.itemToEdit});

  @override
  ConsumerState<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends ConsumerState<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _valueController = TextEditingController();
  final _originController = TextEditingController();
  final _periodController = TextEditingController();
  final _provenanceController = TextEditingController();
  
  String _selectedCategory = 'Furniture';
  String _selectedCondition = 'Excellent';
  DateTime _acquisitionDate = DateTime.now();
  List<File> _selectedImages = [];
  List<String> _existingImageUrls = [];
  bool _isLoading = false;

  final conditions = ['Excellent', 'Good', 'Fair', 'Poor', 'Restoration Needed'];

  @override
  void initState() {
    super.initState();
    if (widget.itemToEdit != null) {
      _populateFieldsForEdit();
    }
  }

  void _populateFieldsForEdit() {
    final item = widget.itemToEdit!;
    _nameController.text = item.name;
    _descriptionController.text = item.description;
    _valueController.text = item.estimatedValue.toString();
    _originController.text = item.origin;
    _periodController.text = item.period;
    _provenanceController.text = item.provenance;
    _selectedCategory = item.category;
    _selectedCondition = item.condition;
    _acquisitionDate = item.acquisitionDate;
    _existingImageUrls = List.from(item.imageUrls);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _valueController.dispose();
    _originController.dispose();
    _periodController.dispose();
    _provenanceController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final images = await ImageHelper.pickMultipleImages();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }

  Future<void> _takePicture() async {
    final image = await ImageHelper.pickImageFromCamera();
    if (image != null) {
      setState(() {
        _selectedImages.add(image);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingImageUrls.removeAt(index);
    });
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedImages.isEmpty && _existingImageUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one image')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Upload new images
      List<String> uploadedUrls = [];
      if (_selectedImages.isNotEmpty) {
        final storageRepo = ref.read(storageRepositoryProvider);
        final userId = ref.read(firebaseAuthProvider).currentUser?.uid ?? '';
        final itemId = widget.itemToEdit?.id ?? const Uuid().v4();
        
        final result = await storageRepo.uploadMultipleImages(
          _selectedImages,
          'users/$userId/items/$itemId',
        );

        result.fold(
          (failure) => throw Exception(failure.message),
          (urls) => uploadedUrls = urls,
        );
      }

      // Combine existing and new image URLs
      final allImageUrls = [..._existingImageUrls, ...uploadedUrls];

      final item = AntiqueItem(
        id: widget.itemToEdit?.id ?? const Uuid().v4(),
        name: _nameController.text.trim(),
        category: _selectedCategory,
        description: _descriptionController.text.trim(),
        estimatedValue: double.parse(_valueController.text),
        currency: 'USD',
        acquisitionDate: _acquisitionDate,
        origin: _originController.text.trim(),
        period: _periodController.text.trim(),
        condition: _selectedCondition,
        imageUrls: allImageUrls,
        provenance: _provenanceController.text.trim(),
        historicalData: {},
        createdAt: widget.itemToEdit?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        userId: ref.read(firebaseAuthProvider).currentUser?.uid ?? '',
      );

      if (widget.itemToEdit != null) {
        await ref.read(itemsProvider.notifier).updateItem(item);
      } else {
        await ref.read(itemsProvider.notifier).createItem(item);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.itemToEdit != null 
              ? 'Item updated successfully' 
              : 'Item added successfully'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.itemToEdit != null ? 'Edit Item' : 'Add New Item'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveItem,
              child: const Text('SAVE'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Images Section
            const Text(
              'Images',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildImagesSection(),
            const SizedBox(height: 24),

            // Basic Information
            const Text(
              'Basic Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Item Name *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter item name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category *',
                border: OutlineInputBorder(),
              ),
              items: categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedCategory = value!);
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description *',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter description';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Value & Condition
            const Text(
              'Value & Condition',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _valueController,
              decoration: const InputDecoration(
                labelText: 'Estimated Value (USD) *',
                border: OutlineInputBorder(),
                prefixText: '\$ ',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter estimated value';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _selectedCondition,
              decoration: const InputDecoration(
                labelText: 'Condition *',
                border: OutlineInputBorder(),
              ),
              items: conditions.map((condition) {
                return DropdownMenuItem(
                  value: condition,
                  child: Text(condition),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedCondition = value!);
              },
            ),
            const SizedBox(height: 24),

            // Origin & History
            const Text(
              'Origin & History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _originController,
              decoration: const InputDecoration(
                labelText: 'Origin/Location',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _periodController,
              decoration: const InputDecoration(
                labelText: 'Period/Era',
                border: OutlineInputBorder(),
                hintText: 'e.g., Victorian, Ming Dynasty, 1920s',
              ),
            ),
            const SizedBox(height: 16),

            ListTile(
              title: const Text('Acquisition Date'),
              subtitle: Text(
                '${_acquisitionDate.day}/${_acquisitionDate.month}/${_acquisitionDate.year}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _acquisitionDate,
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() => _acquisitionDate = date);
                }
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: BorderSide(color: Colors.grey[400]!),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _provenanceController,
              decoration: const InputDecoration(
                labelText: 'Provenance (History of Ownership)',
                border: OutlineInputBorder(),
                hintText: 'Document the item\'s history and previous owners',
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesSection() {
    return Column(
      children: [
        // Existing images
        if (_existingImageUrls.isNotEmpty)
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _existingImageUrls.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      width: 120,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(_existingImageUrls[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 12,
                      child: GestureDetector(
                        onTap: () => _removeExistingImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        
        // New images
        if (_selectedImages.isNotEmpty)
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      width: 120,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: FileImage(_selectedImages[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 12,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        
        const SizedBox(height: 12),
        
        // Add image buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.photo_library),
                label: const Text('Gallery'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _takePicture,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Camera'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}