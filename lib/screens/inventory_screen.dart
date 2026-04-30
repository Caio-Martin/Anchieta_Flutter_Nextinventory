import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

import '../models/inventory_item.dart';
import '../services/gemini_service.dart';
import '../services/inventory_database_service.dart';
import '../widgets/inventory_item_card.dart';
import 'about_screen.dart';
import 'login_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  static const routeName = '/inventory';

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final InventoryDatabaseService _database = InventoryDatabaseService.instance;
  List<InventoryItem> _items = [];
  bool _isLoading = true;

  int _nextAssetNumber = 2;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await _database.getItems();
    if (!mounted) {
      return;
    }

    setState(() {
      _items = items;
      _nextAssetNumber = _calculateNextAssetNumber(items);
      _isLoading = false;
    });
  }

  int _calculateNextAssetNumber(List<InventoryItem> items) {
    var maxNumber = 0;
    final pattern = RegExp(r'^PAT-\d{4}-(\d+)$');

    for (final current in items) {
      final match = pattern.firstMatch(current.code);
      if (match == null) {
        continue;
      }

      final value = int.tryParse(match.group(1) ?? '0') ?? 0;
      if (value > maxNumber) {
        maxNumber = value;
      }
    }

    return maxNumber + 1;
  }

  Future<void> _showItemDialog({InventoryItem? item}) async {
    await showDialog<void>(
      context: context,
      builder: (context) => _ItemDialog(
        item: item,
        database: _database,
        nextAssetNumber: _nextAssetNumber,
        onSaved: _loadItems,
      ),
    );
  }

  Future<void> _deleteItem(InventoryItem item) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir item'),
          content: Text('Deseja excluir "${item.name}" da lista?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    final deleted = await _database.deleteItem(item.id);
    if (!mounted) {
      return;
    }

    if (!deleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item nao encontrado para exclusao.')),
      );
      return;
    }

    await _loadItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventario'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, AboutScreen.routeName);
            },
            icon: const Icon(Icons.info_outline),
            tooltip: 'Sobre',
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                color: const Color(0xFF135D66),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white24,
                      child: Icon(
                        Icons.inventory_2_outlined,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'NextInventory',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Gestao simples de inventario',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.inventory_2_outlined),
                title: const Text('Inventario'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Sobre'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AboutScreen.routeName);
                },
              ),
              const Spacer(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sair'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(
                    context,
                    LoginScreen.routeName,
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (_isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth > 980 ? 980 : double.infinity,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Itens do inventario',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    const SizedBox(height: 20),
                    if (_items.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Column(
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 56,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 12),
                            Text('Nenhum item cadastrado.'),
                          ],
                        ),
                      )
                    else
                      ..._items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: InventoryItemCard(
                            item: item,
                            onEdit: () => _showItemDialog(item: item),
                            onDelete: () => _deleteItem(item),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showItemDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Adicionar item'),
      ),
    );
  }
}

class _ItemDialog extends StatefulWidget {
  const _ItemDialog({
    required this.item,
    required this.database,
    required this.nextAssetNumber,
    required this.onSaved,
  });

  final InventoryItem? item;
  final InventoryDatabaseService database;
  final int nextAssetNumber;
  final VoidCallback onSaved;

  @override
  State<_ItemDialog> createState() => _ItemDialogState();
}

class _ItemDialogState extends State<_ItemDialog> {
  late TextEditingController nameController;
  late TextEditingController locationController;
  late TextEditingController statusController;
  late TextEditingController descriptionController;
  late GlobalKey<FormState> formKey;
  bool _isAnalyzingImage = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.item?.name ?? '');
    locationController = TextEditingController(
      text: widget.item?.location ?? '',
    );
    statusController = TextEditingController(text: widget.item?.status ?? '');
    descriptionController = TextEditingController(text: widget.item?.description ?? '');
    formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    nameController.dispose();
    locationController.dispose();
    statusController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isNewItem = widget.item == null;
    final generatedCode = isNewItem
        ? 'PAT-2026-${widget.nextAssetNumber.toString().padLeft(3, '0')}'
        : widget.item!.code;

    Future<void> handleImageCapture(ImageSource source) async {
      try {
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(
          source: source,
          maxWidth: 1024,
          maxHeight: 1024,
        );

        if (pickedFile == null) return;

        setState(() {
          _isAnalyzingImage = true;
        });

        final bytes = await pickedFile.readAsBytes();
        final mimeType = lookupMimeType(pickedFile.name) ?? 'image/jpeg';

        final details = await GeminiService.instance
            .generateItemDetailsFromImage(bytes, mimeType);

        if (!mounted) return;

        setState(() {
          nameController.text = details.name;
          descriptionController.text = details.description;
          _isAnalyzingImage = false;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isAnalyzingImage = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao analisar imagem: $e')),
        );
      }
    }

    void showImageSourceOptions() {
      showModalBottomSheet(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Tirar foto com a câmera'),
                onTap: () {
                  Navigator.pop(context);
                  handleImageCapture(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Escolher da galeria'),
                onTap: () {
                  Navigator.pop(context);
                  handleImageCapture(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      );
    }

    return AlertDialog(
      title: Text(isNewItem ? 'Adicionar item' : 'Editar item'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Patrimônio',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            generatedCode,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (_isAnalyzingImage)
                        const Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      else
                        ElevatedButton.icon(
                          onPressed: showImageSourceOptions,
                          icon: const Icon(Icons.auto_awesome, size: 18),
                          label: const Text('Identificar Foto'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _DialogTextField(
                  controller: nameController,
                  label: 'Nome do item',
                  hintText: 'Ex: Notebook, Monitor, Teclado...',
                ),
                const SizedBox(height: 12),
                _DialogTextField(
                  controller: locationController,
                  label: 'Localização',
                  hintText: 'Ex: TI - Sala 02',
                ),
                const SizedBox(height: 12),
                _DialogTextField(
                  controller: descriptionController,
                  label: 'Descrição',
                  hintText: 'Descrição ou características...',
                  maxLines: 3,
                  isRequired: false,
                ),
                const SizedBox(height: 12),
                _DialogDropdown(
                  controller: statusController,
                  label: 'Status',
                  items: const [
                    'Em uso',
                    'Disponível',
                    'Manutenção',
                    'Baixado',
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () async {
            if (!formKey.currentState!.validate()) {
              return;
            }

            try {
              if (isNewItem) {
                await widget.database.createItem(
                  name: nameController.text.trim(),
                  code: generatedCode,
                  location: locationController.text.trim(),
                  status: statusController.text.trim(),
                  description: descriptionController.text.trim(),
                );
              } else {
                await widget.database.updateItem(
                  widget.item!.copyWith(
                    name: nameController.text.trim(),
                    location: locationController.text.trim(),
                    status: statusController.text.trim(),
                    description: descriptionController.text.trim(),
                  ),
                );
              }

              if (!mounted) {
                return;
              }
              Navigator.pop(context);
              widget.onSaved();
            } on InventoryDatabaseException catch (error) {
              if (!mounted) {
                return;
              }
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(error.message)));
            } catch (_) {
              if (!mounted) {
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Nao foi possivel salvar o item.'),
                ),
              );
            }
          },
          child: Text(isNewItem ? 'Salvar' : 'Atualizar'),
        ),
      ],
    );
  }
}

class _DialogTextField extends StatelessWidget {
  const _DialogTextField({
    required this.controller,
    required this.label,
    this.hintText,
    this.maxLines = 1,
    this.isRequired = true,
  });

  final TextEditingController controller;
  final String label;
  final String? hintText;
  final int maxLines;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      minLines: 1,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
      validator: (value) {
        if (isRequired && (value == null || value.trim().isEmpty)) {
          return 'Campo obrigatório';
        }
        return null;
      },
    );
  }
}

class _DialogDropdown extends StatefulWidget {
  const _DialogDropdown({
    required this.controller,
    required this.label,
    required this.items,
  });

  final TextEditingController controller;
  final String label;
  final List<String> items;

  @override
  State<_DialogDropdown> createState() => _DialogDropdownState();
}

class _DialogDropdownState extends State<_DialogDropdown> {
  late String _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.controller.text.isNotEmpty
        ? widget.controller.text
        : widget.items.first;

    widget.controller.text = _selectedValue;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: _selectedValue,
      decoration: InputDecoration(
        labelText: widget.label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
      items: widget.items
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedValue = value!;
          widget.controller.text = value;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Selecione um status';
        }
        return null;
      },
    );
  }
}
