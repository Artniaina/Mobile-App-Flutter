class Item {
  final int? id;
  final String title;
  final String type;
  final String description;
  final int price;

  Item({
    this.id,
    required this.title,
    required this.type,
    required this.description,
    required this.price,
  });

  // Convert a Item object into a Map object
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'description': description,
      'price': price,
    };
  }

  // Extract a Item object from a Map object
  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      id: map['id'],
      title: map['title'],
      type: map['type'],
      description: map['description'],
      price: map['price'],
    );
  }
}
