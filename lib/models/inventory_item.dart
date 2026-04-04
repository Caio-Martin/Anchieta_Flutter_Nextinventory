class InventoryItem {
  final String id;
  final String name;
  final String code;
  final String location;
  final String status;

  const InventoryItem({
    required this.id,
    required this.name,
    required this.code,
    required this.location,
    required this.status,
  });

  InventoryItem copyWith({
    String? id,
    String? name,
    String? code,
    String? location,
    String? status,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      location: location ?? this.location,
      status: status ?? this.status,
    );
  }
}
