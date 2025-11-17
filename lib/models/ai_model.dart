/// AI模型配置
class AiModel {
  final String id;
  final String name;
  final String? description;
  final bool enabled;

  AiModel({
    required this.id,
    required this.name,
    this.description,
    this.enabled = true,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'enabled': enabled,
      };

  factory AiModel.fromJson(Map<String, dynamic> json) => AiModel(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        enabled: json['enabled'] ?? true,
      );

  AiModel copyWith({
    String? id,
    String? name,
    String? description,
    bool? enabled,
  }) =>
      AiModel(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        enabled: enabled ?? this.enabled,
      );
}
