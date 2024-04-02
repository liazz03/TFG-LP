class EventCategory {
  final int id;
  final String name;

  EventCategory({required this.id, required this.name});

  factory EventCategory.fromMap(Map<String, dynamic> map) {
    return EventCategory(
      id: map['id'],
      name: map['category'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id, // Note: Including 'id' is optional and depends on your use case
      'category': name,
    };
  }
}
