class WishlistItem {
  final int? id;
  final int userId;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final String description;
  final bool isPriority;
  final DateTime createdAt;

  WishlistItem({
    this.id,
    required this.userId,
    required this.title,
    required this.targetAmount,
    this.currentAmount = 0.0,
    this.description = '',
    this.isPriority = false,
    required this.createdAt,
  });

  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      userId: json['user_id'] != null
          ? int.tryParse(json['user_id'].toString()) ?? 0
          : 0,
      title: json['title']?.toString() ?? '',
      targetAmount: json['target_amount'] != null
          ? double.tryParse(json['target_amount'].toString()) ?? 0.0
          : 0.0,
      currentAmount: json['current_amount'] != null
          ? double.tryParse(json['current_amount'].toString()) ?? 0.0
          : 0.0,
      description: json['description']?.toString() ?? '',
      isPriority:
          json['is_priority'] == '1' ||
          json['is_priority'] == 1 ||
          json['is_priority'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'description': description,
      'is_priority': isPriority ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  double get progressPercentage {
    if (targetAmount == 0) return 0.0;
    return (currentAmount / targetAmount).clamp(0.0, 1.0);
  }
}
