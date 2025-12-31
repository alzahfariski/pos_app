import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/presentation/widgets/custom_toast.dart';
import '../../../../core/presentation/widgets/custom_dialog.dart';
import '../../../../core/utils/image_helper.dart';
import '../cubit/products_cubit.dart';
import '../../domain/entities/product.dart';

import 'dart:math';

class ProductFormPage extends StatefulWidget {
  final Product? product;

  const ProductFormPage({super.key, this.product});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _skuController;
  late TextEditingController _costController;
  late TextEditingController _priceController;

  final ImagePicker _picker = ImagePicker();
  String? _selectedImagePath;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');

    // Auto-generate SKU if new product
    if (widget.product == null) {
      final random = Random();
      // Using 5 digits random number to minimize collision with soft-deleted items
      final number = random.nextInt(90000) + 10000; // 10000 to 99999
      _skuController = TextEditingController(text: 'PROD-$number');
    } else {
      _skuController = TextEditingController(text: widget.product!.sku);
    }

    _costController = TextEditingController(
      text: widget.product?.cost.toString() ?? '',
    );
    _priceController = TextEditingController(
      text: widget.product?.price.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _costController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        if (!mounted) return;
        setState(() {
          _selectedImagePath = image.path;
        });
      }
    } catch (e) {
      if (!mounted) return;
      CustomToast.show(context, 'Failed to pick image: $e', isError: true);
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final sku = _skuController.text;
      final cost = double.tryParse(_costController.text) ?? 0;
      final price = double.tryParse(_priceController.text) ?? 0;
      // Default stock is 0 as per requirement, or preserve existing for edit
      final stock = widget.product?.stock ?? 0;

      if (widget.product == null) {
        // Add
        context.read<ProductsCubit>().addProduct(
          name: name,
          sku: sku,
          cost: cost,
          price: price,
          stock: stock,
          imagePath: _selectedImagePath,
        );
      } else {
        // Update
        context.read<ProductsCubit>().updateProduct(
          id: widget.product!.id,
          name: name,
          sku: sku,
          cost: cost,
          price: price,
          stock: stock,
          imagePath: _selectedImagePath,
        );
      }
    }
  }

  Future<void> _deleteProduct() async {
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: 'Delete Product',
        content:
            'Are you sure you want to delete this product? This action cannot be undone.',
        icon: Icons.warning_amber_rounded,
        iconColor: AppColors.danger500,
        primaryButtonText: 'Delete',
        onPrimaryPressed: () {
          Navigator.pop(context);
          if (mounted) {
            context.read<ProductsCubit>().deleteProduct(widget.product!.id);
          }
        },
        secondaryButtonText: 'Cancel',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;

    return BlocListener<ProductsCubit, ProductsState>(
      listener: (context, state) {
        if (state is ProductOperationSuccess) {
          CustomToast.show(context, state.message, isError: false);
          context.pop();
        } else if (state is ProductsLoadFailure) {
          CustomToast.show(context, state.message, isError: true);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            isEdit ? 'Edit Product' : 'New Product',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: Colors.black,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image Picker Section
                Center(
                  child: InkWell(
                    onTap: _pickImage,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        color: AppColors.neutral50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              _selectedImagePath == null &&
                                  (widget.product?.imageUrl == null ||
                                      widget.product!.imageUrl!.isEmpty)
                              ? AppColors.neutral300
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: _selectedImagePath != null
                            ? Image.file(
                                File(_selectedImagePath!),
                                fit: BoxFit.cover,
                              )
                            : (widget.product?.imageUrl != null &&
                                  widget.product!.imageUrl!.isNotEmpty)
                            ? CachedNetworkImage(
                                imageUrl: ImageHelper.sanitizeUrl(
                                  widget.product!.imageUrl!,
                                ),
                                fit: BoxFit.cover,
                                placeholder: (_, _) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                errorWidget: (_, _, _) => const Icon(
                                  Icons.add_photo_alternate_outlined,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate_rounded,
                                    size: 48,
                                    color: AppColors.primary300,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Upload Image',
                                    style: TextStyle(
                                      color: AppColors.primary500,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Form Fields
                _buildSectionHeader('Basic Info'),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _nameController,
                  label: 'Product Name',
                  hint: 'e.g., Kopi Susu Aren',
                  validator: (v) => v!.isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _skuController,
                  label: 'SKU',
                  hint: 'Auto-generated or custom',
                  validator: (v) => v!.isEmpty ? 'SKU is required' : null,
                ),

                const SizedBox(height: 24),
                _buildSectionHeader('Pricing & Inventory'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _costController,
                        label: 'Cost (HPP)',
                        prefix: 'Rp ',
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _priceController,
                        label: 'Selling Price',
                        prefix: 'Rp ',
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 48),

                // Submit Button
                BlocBuilder<ProductsCubit, ProductsState>(
                  builder: (context, state) {
                    final isLoading = state is ProductsLoading;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton(
                          onPressed: isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary500,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                            shadowColor: AppColors.primary200,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  isEdit ? 'Update Product' : 'Save Product',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                        if (isEdit && widget.product!.stock <= 0) ...[
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: isLoading ? null : _deleteProduct,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.danger500,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              side: const BorderSide(
                                color: AppColors.danger200,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Delete Product',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 32,
                          ), // Extra padding for mobile
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? prefix,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: prefix,
        filled: true,
        fillColor: const Color(0xFFF9FAFB), // Very light gray
        labelStyle: TextStyle(color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary500, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
