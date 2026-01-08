import 'package:equatable/equatable.dart';

/// A single checklist item within a protocol
class ChecklistItem extends Equatable {
  final String id;
  final String text;
  final bool isOptional;
  final String? subtext;

  const ChecklistItem({
    required this.id,
    required this.text,
    this.isOptional = false,
    this.subtext,
  });

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      id: json['id'] as String,
      text: json['text'] as String,
      isOptional: json['isOptional'] as bool? ?? false,
      subtext: json['subtext'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'isOptional': isOptional,
        'subtext': subtext,
      };

  @override
  List<Object?> get props => [id, text, isOptional, subtext];
}

/// A section within a protocol containing related checklist items
class ChecklistSection extends Equatable {
  final String id;
  final String title;
  final List<ChecklistItem> items;

  const ChecklistSection({
    required this.id,
    required this.title,
    required this.items,
  });

  factory ChecklistSection.fromJson(Map<String, dynamic> json) {
    return ChecklistSection(
      id: json['id'] as String,
      title: json['title'] as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => ChecklistItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'items': items.map((e) => e.toJson()).toList(),
      };

  @override
  List<Object?> get props => [id, title, items];
}

/// Complete protocol definition
class ProtocolDefinition extends Equatable {
  final String id;
  final String name;
  final String type;
  final String description;
  final String disclaimer;
  final List<String> sourceUrls;
  final List<ChecklistSection> sections;

  const ProtocolDefinition({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.disclaimer,
    this.sourceUrls = const [],
    required this.sections,
  });

  factory ProtocolDefinition.fromJson(Map<String, dynamic> json) {
    return ProtocolDefinition(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      disclaimer: json['disclaimer'] as String,
      sourceUrls: (json['sourceUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      sections: (json['sections'] as List<dynamic>)
          .map((e) => ChecklistSection.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'description': description,
        'disclaimer': disclaimer,
        'sourceUrls': sourceUrls,
        'sections': sections.map((e) => e.toJson()).toList(),
      };

  /// Get total number of checklist items
  int get totalItems {
    return sections.fold(0, (sum, section) => sum + section.items.length);
  }

  /// Get all item IDs
  List<String> get allItemIds {
    return sections.expand((s) => s.items.map((i) => i.id)).toList();
  }

  @override
  List<Object?> get props =>
      [id, name, type, description, disclaimer, sourceUrls, sections];
}

/// State for tracking checklist progress
class ChecklistState extends Equatable {
  final String protocolId;
  final Set<String> completedItemIds;
  final Map<String, String> itemNotes;
  final DateTime? startedAt;

  const ChecklistState({
    required this.protocolId,
    this.completedItemIds = const {},
    this.itemNotes = const {},
    this.startedAt,
  });

  ChecklistState copyWith({
    String? protocolId,
    Set<String>? completedItemIds,
    Map<String, String>? itemNotes,
    DateTime? startedAt,
  }) {
    return ChecklistState(
      protocolId: protocolId ?? this.protocolId,
      completedItemIds: completedItemIds ?? this.completedItemIds,
      itemNotes: itemNotes ?? this.itemNotes,
      startedAt: startedAt ?? this.startedAt,
    );
  }

  bool isItemCompleted(String itemId) => completedItemIds.contains(itemId);

  String? getNote(String itemId) => itemNotes[itemId];

  int get completedCount => completedItemIds.length;

  @override
  List<Object?> get props => [protocolId, completedItemIds, itemNotes, startedAt];
}
