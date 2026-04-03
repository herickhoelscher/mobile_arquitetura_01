import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/product.dart';
import '../viewmodels/product_viewmodel.dart';

class ProductFormPage extends StatefulWidget {
  final Product? product;

  const ProductFormPage({super.key, this.product});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _priceController;
  late final TextEditingController _categoryController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _imageController;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.product?.title ?? '');
    _priceController = TextEditingController(
      text: widget.product != null ? widget.product!.price.toString() : '',
    );
    _categoryController = TextEditingController(text: widget.product?.category ?? '');
    _descriptionController = TextEditingController(text: widget.product?.description ?? '');
    _imageController = TextEditingController(text: widget.product?.image ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProductViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Produto' : 'Novo Produto'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildField(
                controller: _titleController,
                label: 'Nome do produto',
                validator: (v) => v!.trim().isEmpty ? 'Informe o nome do produto' : null,
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _priceController,
                label: 'Preço (R\$)',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v!.trim().isEmpty) return 'Informe o preço';
                  final parsed = double.tryParse(v.trim().replaceAll(',', '.'));
                  if (parsed == null) return 'Preço inválido';
                  if (parsed <= 0) return 'O preço deve ser maior que zero';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _categoryController,
                label: 'Categoria',
                validator: (v) => v!.trim().isEmpty ? 'Informe a categoria' : null,
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _imageController,
                label: 'URL da imagem',
                keyboardType: TextInputType.url,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final uri = Uri.tryParse(v.trim());
                  if (uri == null || !uri.hasAbsolutePath || uri.scheme.isEmpty) {
                    return 'Informe uma URL válida';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildField(
                controller: _descriptionController,
                label: 'Descrição',
                maxLines: 4,
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: vm.isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: vm.isSubmitting
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          _isEditing ? 'Salvar alterações' : 'Cadastrar produto',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
      validator: validator,
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final vm = context.read<ProductViewModel>();
    final imageUrl = _imageController.text.trim().isEmpty
        ? 'https://via.placeholder.com/150'
        : _imageController.text.trim();

    bool success;
    if (_isEditing) {
      success = await vm.updateProduct(Product(
        id: widget.product!.id,
        title: _titleController.text.trim(),
        price: double.parse(_priceController.text.trim().replaceAll(',', '.')),
        category: _categoryController.text.trim(),
        description: _descriptionController.text.trim(),
        image: imageUrl,
        favorite: widget.product!.favorite,
      ));
    } else {
      success = await vm.addProduct(
        title: _titleController.text.trim(),
        price: double.parse(_priceController.text.trim().replaceAll(',', '.')),
        category: _categoryController.text.trim(),
        description: _descriptionController.text.trim(),
        image: imageUrl,
      );
    }

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing
              ? 'Produto atualizado com sucesso!'
              : 'Produto cadastrado com sucesso!'),
          backgroundColor: Colors.green.shade700,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao salvar produto. Tente novamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
