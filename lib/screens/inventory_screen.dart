import 'package:flutter/material.dart';
import '../models/inventory_item.dart';
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
  final List<InventoryItem> _items = [
    const InventoryItem(
      id: '1',
      name: 'Notebook Dell Latitude',
      code: 'PAT-2026-001',
      location: 'TI - Sala 02',
      status: 'Em uso',
    ),
  ];

  int _nextAssetNumber = 2;

  String _generateAssetCode() {
    final code = 'PAT-2026-${_nextAssetNumber.toString().padLeft(3, '0')}';
    _nextAssetNumber++;
    return code;
  }

  Future<void> _showItemDialog({InventoryItem? item}) async {
    final nameController = TextEditingController(text: item?.name ?? '');
    final locationController = TextEditingController(
      text: item?.location ?? '',
    );
    final statusController = TextEditingController(text: item?.status ?? '');
    final formKey = GlobalKey<FormState>();

    final isNewItem = item == null;
    final generatedCode = isNewItem ? _generateAssetCode() : item.code;

    await showDialog<void>(
      context: context,
      builder: (context) {
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
                    // Exibir patrimônio como texto (não editável)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Patrimônio',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            generatedCode,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
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
              onPressed: () {
                if (!formKey.currentState!.validate()) {
                  return;
                }

                setState(() {
                  if (isNewItem) {
                    _items.insert(
                      0,
                      InventoryItem(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: nameController.text.trim(),
                        code: generatedCode,
                        location: locationController.text.trim(),
                        status: statusController.text.trim(),
                      ),
                    );
                  } else {
                    final index = _items.indexWhere(
                      (element) => element.id == item.id,
                    );
                    if (index != -1) {
                      _items[index] = item.copyWith(
                        name: nameController.text.trim(),
                        location: locationController.text.trim(),
                        status: statusController.text.trim(),
                      );
                    }
                  }
                });

                Navigator.pop(context);
              },
              child: Text(isNewItem ? 'Salvar' : 'Atualizar'),
            ),
          ],
        );
      },
    );

    nameController.dispose();
    locationController.dispose();
    statusController.dispose();
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

    setState(() {
      _items.removeWhere((element) => element.id == item.id);
    });
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

class _DialogTextField extends StatelessWidget {
  const _DialogTextField({
    required this.controller,
    required this.label,
    this.hintText,
  });

  final TextEditingController controller;
  final String label;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
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
        if (value == null || value.trim().isEmpty) {
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
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: _selectedValue,
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
