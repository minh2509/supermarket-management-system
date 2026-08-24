import 'package:flutter/material.dart';
import 'package:supermarket_manager_system/data/services/product_api_service.dart';
import 'package:supermarket_manager_system/domain/models/category_option.dart';
import 'package:supermarket_manager_system/domain/models/product_detail.dart';
import 'package:supermarket_manager_system/domain/models/supplier_option.dart';
import 'package:supermarket_manager_system/domain/models/update_product_request.dart';

class UpdateProductDialog extends StatefulWidget {
  const UpdateProductDialog({
    super.key,
    required this.product,
  });

  final ProductDetail product;

  @override
  State<UpdateProductDialog> createState() => _UpdateProductDialogState();
}

class _UpdateProductDialogState extends State<UpdateProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _productApiService = ProductApiService();

  late final TextEditingController _productBatchController;
  late final TextEditingController _productNameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _costPriceController;
  late final TextEditingController _sellingPriceController;
  late final TextEditingController _cartonsController;
  late final TextEditingController _qtyCartonsController;
  late final TextEditingController _mftDateController;
  late final TextEditingController _expiryDateController;
  late final TextEditingController _imageUrlController;

  List<SupplierOption> _suppliers = [];
  List<CategoryOption> _categories = [];
  int? _selectedSupplierId;
  int? _selectedCategoryId;
  bool _isLoading = false;
  bool _isLoadingOptions = true;

  @override
  void initState() {
    super.initState();
    _productBatchController = TextEditingController(text: widget.product.productBatch);
    _productNameController = TextEditingController(text: widget.product.productName);
    _descriptionController = TextEditingController(text: widget.product.description);
    _costPriceController = TextEditingController(
      text: widget.product.costPrice?.toStringAsFixed(2) ?? '',
    );
    _sellingPriceController = TextEditingController(
      text: widget.product.sellingPrice.toStringAsFixed(2),
    );
    _cartonsController = TextEditingController(
      text: widget.product.qtyCartons?.toString() ?? '0',
    );
    _qtyCartonsController = TextEditingController(
      text: widget.product.inStock.toString(),
    );
    _mftDateController = TextEditingController(text: widget.product.mftDate);
    _expiryDateController = TextEditingController(text: widget.product.expiryDate);
    _imageUrlController = TextEditingController(text: widget.product.imageUrl);
    _loadOptions();
  }

  @override
  void dispose() {
    _productBatchController.dispose();
    _productNameController.dispose();
    _descriptionController.dispose();
    _costPriceController.dispose();
    _sellingPriceController.dispose();
    _cartonsController.dispose();
    _qtyCartonsController.dispose();
    _mftDateController.dispose();
    _expiryDateController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadOptions() async {
    try {
      final suppliers = await _productApiService.getSupplierOptions();
      final categories = await _productApiService.getCategoryOptions();

      // Find matching supplier and category IDs
      int? supplierId;
      int? categoryId;

      if (widget.product.supplierName.isNotEmpty) {
        final matchingSupplier = suppliers.firstWhere(
          (s) => s.supplierName == widget.product.supplierName,
          orElse: () => const SupplierOption(id: 0, supplierName: ''),
        );
        if (matchingSupplier.id > 0) supplierId = matchingSupplier.id;
      }

      if (widget.product.categoryName.isNotEmpty) {
        final matchingCategory = categories.firstWhere(
          (c) => c.name == widget.product.categoryName,
          orElse: () => const CategoryOption(id: 0, name: ''),
        );
        if (matchingCategory.id > 0) categoryId = matchingCategory.id;
      }

      setState(() {
        _suppliers = suppliers;
        _categories = categories;
        _selectedSupplierId = supplierId;
        _selectedCategoryId = categoryId;
        _isLoadingOptions = false;
      });
    } catch (e) {
      setState(() => _isLoadingOptions = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load options: $e')),
        );
      }
    }
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = picked.toIso8601String().split('T')[0];
    }
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedSupplierId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a supplier')),
      );
      return;
    }

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final request = UpdateProductRequest(
        productBatch: _productBatchController.text.trim(),
        productName: _productNameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        costPrice: double.parse(_costPriceController.text.trim()),
        sellingPrice: double.parse(_sellingPriceController.text.trim()),
        cartons: int.parse(_cartonsController.text.trim()),
        qtyCartons: int.parse(_qtyCartonsController.text.trim()),
        supplierId: _selectedSupplierId!,
        categoryId: _selectedCategoryId!,
        mftDate: _mftDateController.text.trim(),
        expiryDate: _expiryDateController.text.trim(),
        imageUrl: _imageUrlController.text.trim().isEmpty
            ? null
            : _imageUrlController.text.trim(),
      );

      await _productApiService.updateProduct(widget.product.id, request);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update product: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth < 640 ? screenWidth - 24 : 600.0;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: dialogWidth,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            if (_isLoadingOptions)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: _buildForm(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE8EAED))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Update Product',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          IconButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    final isCompactLayout = MediaQuery.of(context).size.width < 440;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextField(
            label: 'Product Batch',
            controller: _productBatchController,
            required: true,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Product Name',
            controller: _productNameController,
            required: true,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Product Description',
            controller: _descriptionController,
            required: false,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          _buildResponsivePair(
            isCompactLayout: isCompactLayout,
            first: _buildTextField(
              label: 'Cost Price',
              controller: _costPriceController,
              required: true,
              keyboardType: TextInputType.number,
            ),
            second: _buildTextField(
              label: 'Selling Price',
              controller: _sellingPriceController,
              required: true,
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(height: 16),
          _buildResponsivePair(
            isCompactLayout: isCompactLayout,
            first: _buildTextField(
              label: 'Cartons',
              controller: _cartonsController,
              required: true,
              keyboardType: TextInputType.number,
            ),
            second: _buildTextField(
              label: 'In Stock',
              controller: _qtyCartonsController,
              required: true,
              keyboardType: TextInputType.number,
            ),
          ),
          const SizedBox(height: 16),
          _buildResponsivePair(
            isCompactLayout: isCompactLayout,
            first: _buildSupplierDropdown(),
            second: _buildCategoryDropdown(),
          ),
          const SizedBox(height: 16),
          _buildResponsivePair(
            isCompactLayout: isCompactLayout,
            first: _buildDateField('MFT Date', _mftDateController),
            second: _buildDateField('Expiry Date', _expiryDateController),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Product Image URL',
            controller: _imageUrlController,
            required: false,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton(
                onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _isLoading ? null : _updateProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Update'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required bool required,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: 'Enter $label',
          ),
          validator: (value) {
            if (required && (value == null || value.trim().isEmpty)) {
              return '$label is required';
            }
            
            // Validate numeric fields
            if (value != null && value.trim().isNotEmpty && keyboardType == TextInputType.number) {
              final numValue = double.tryParse(value.trim());
              if (numValue == null) {
                return 'Please enter a valid number';
              }
              if (numValue < 0) {
                return '$label must be greater than or equal to 0';
              }
              // For integer fields (Cartons, In Stock)
              if (label == 'Cartons' || label == 'In Stock') {
                if (numValue != numValue.toInt()) {
                  return '$label must be a whole number';
                }
              }
            }
            
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSupplierDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Supplier',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          initialValue: _selectedSupplierId,
          isExpanded: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Choose...',
          ),
          validator: (value) {
            if (value == null) {
              return 'Supplier is required';
            }
            return null;
          },
          selectedItemBuilder: (context) {
            return _suppliers
                .map(
                  (s) => Text(
                    s.supplierName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
                .toList();
          },
          items: _suppliers
              .map((s) => DropdownMenuItem<int>(
                    value: s.id,
                    child: Text(
                      s.supplierName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ))
              .toList(),
          onChanged: (value) => setState(() => _selectedSupplierId = value),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          initialValue: _selectedCategoryId,
          isExpanded: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Choose...',
          ),
          validator: (value) {
            if (value == null) {
              return 'Category is required';
            }
            return null;
          },
          selectedItemBuilder: (context) {
            return _categories
                .map(
                  (c) => Text(
                    c.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
                .toList();
          },
          items: _categories
              .map((c) => DropdownMenuItem<int>(
                    value: c.id,
                    child: Text(
                      c.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ))
              .toList(),
          onChanged: (value) => setState(() => _selectedCategoryId = value),
        ),
      ],
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          maxLines: 1,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            hintText: 'Select date',
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '$label is required';
            }
            return null;
          },
          onTap: () => _selectDate(controller),
        ),
      ],
    );
  }

  Widget _buildResponsivePair({
    required bool isCompactLayout,
    required Widget first,
    required Widget second,
  }) {
    if (isCompactLayout) {
      return Column(
        children: [
          first,
          const SizedBox(height: 16),
          second,
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: first),
        const SizedBox(width: 16),
        Expanded(child: second),
      ],
    );
  }
}
