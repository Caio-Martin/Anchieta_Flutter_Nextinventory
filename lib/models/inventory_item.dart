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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'location': location,
      'status': status,
    };
  }

  factory InventoryItem.fromMap(Map<String, dynamic> map) {
    return InventoryItem(
      id: map['id'] as String,
      name: map['name'] as String,
      code: map['code'] as String,
      location: map['location'] as String,
      status: map['status'] as String,
    );
  }
}
