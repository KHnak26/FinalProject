class Item {
  final int id;
  final String title;
  final String subtitle;

  Item({required this.id, required this.title, required this.subtitle});

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json['id'] as int,
        title: json['title'] as String,
        subtitle: json['subtitle'] as String,
      );
}
