/// Represents a user's safety plan
class SafetyPlan {
  final String id;
  final List<String> warningSigns;
  final List<String> copingStrategies;
  final List<TrustedPerson> trustedPeople;
  final List<String> safePlaces;
  final DateTime createdAt;
  final DateTime? updatedAt;

  SafetyPlan({
    required this.id,
    this.warningSigns = const [],
    this.copingStrategies = const [],
    this.trustedPeople = const [],
    this.safePlaces = const [],
    required this.createdAt,
    this.updatedAt,
  });

  SafetyPlan copyWith({
    String? id,
    List<String>? warningSigns,
    List<String>? copingStrategies,
    List<TrustedPerson>? trustedPeople,
    List<String>? safePlaces,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SafetyPlan(
      id: id ?? this.id,
      warningSigns: warningSigns ?? this.warningSigns,
      copingStrategies: copingStrategies ?? this.copingStrategies,
      trustedPeople: trustedPeople ?? this.trustedPeople,
      safePlaces: safePlaces ?? this.safePlaces,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SafetyPlan &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Represents a trusted contact
class TrustedPerson {
  final String id;
  final String name;
  final String phoneNumber;
  final String? email;
  final String? relationship;

  TrustedPerson({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.email,
    this.relationship,
  });

  TrustedPerson copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? email,
    String? relationship,
  }) {
    return TrustedPerson(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      relationship: relationship ?? this.relationship,
    );
  }
}

