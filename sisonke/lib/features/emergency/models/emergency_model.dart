class EmergencyContact {
  final String id;
  final String name;
  final String phoneNumber;
  final String category;
  final String description;
  final bool isActive;
  final String country;
  final DateTime createdAt;

  EmergencyContact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.category,
    required this.description,
    this.isActive = true,
    required this.country,
    required this.createdAt,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: json['id'] as String,
      name: json['name'] as String,
      phoneNumber: json['phone_number'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      isActive: json['is_active'] as bool? ?? true,
      country: json['country'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone_number': phoneNumber,
      'category': category,
      'description': description,
      'is_active': isActive,
      'country': country,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class EmergencyContactsResponse {
  final Map<String, List<EmergencyContact>> contacts;
  final int total;
  final DateTime lastUpdated;

  EmergencyContactsResponse({
    required this.contacts,
    required this.total,
    required this.lastUpdated,
  });

  factory EmergencyContactsResponse.fromJson(Map<String, dynamic> json) {
    final contactsMap = <String, List<EmergencyContact>>{};
    final contacts = json['contacts'] as Map<String, dynamic>;
    
    contacts.forEach((category, contactList) {
      if (contactList is List) {
        contactsMap[category] = contactList
            .map((contact) => EmergencyContact.fromJson(contact as Map<String, dynamic>))
            .toList();
      }
    });

    return EmergencyContactsResponse(
      contacts: contactsMap,
      total: json['total'] as int? ?? 0,
      lastUpdated: DateTime.parse(json['last_updated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contacts': contacts.map((category, contactList) => 
        MapEntry(category, contactList.map((c) => c.toJson()).toList())
      ),
      'total': total,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }
}

class EmergencyToolkit {
  final List<BreathingExercise> breathingExercises;
  final List<GroundingExercise> groundingExercises;
  final List<SafetyPlanStep> safetyPlanSteps;
  final String quickExitUrl;

  EmergencyToolkit({
    required this.breathingExercises,
    required this.groundingExercises,
    required this.safetyPlanSteps,
    required this.quickExitUrl,
  });

  factory EmergencyToolkit.fromJson(Map<String, dynamic> json) {
    return EmergencyToolkit(
      breathingExercises: (json['breathing_exercises'] as List<dynamic>?)
          ?.map((e) => BreathingExercise.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      groundingExercises: (json['grounding_exercises'] as List<dynamic>?)
          ?.map((e) => GroundingExercise.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      safetyPlanSteps: (json['safety_plan_steps'] as List<dynamic>?)
          ?.map((e) => SafetyPlanStep.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      quickExitUrl: json['quick_exit_url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'breathing_exercises': breathingExercises.map((e) => e.toJson()).toList(),
      'grounding_exercises': groundingExercises.map((e) => e.toJson()).toList(),
      'safety_plan_steps': safetyPlanSteps.map((e) => e.toJson()).toList(),
      'quick_exit_url': quickExitUrl,
    };
  }
}

class BreathingExercise {
  final String id;
  final String title;
  final String description;
  final int inhaleSeconds;
  final int holdSeconds;
  final int exhaleSeconds;
  final int cycles;

  BreathingExercise({
    required this.id,
    required this.title,
    required this.description,
    required this.inhaleSeconds,
    required this.holdSeconds,
    required this.exhaleSeconds,
    required this.cycles,
  });

  factory BreathingExercise.fromJson(Map<String, dynamic> json) {
    return BreathingExercise(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      inhaleSeconds: json['inhale_seconds'] as int,
      holdSeconds: json['hold_seconds'] as int,
      exhaleSeconds: json['exhale_seconds'] as int,
      cycles: json['cycles'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'inhale_seconds': inhaleSeconds,
      'hold_seconds': holdSeconds,
      'exhale_seconds': exhaleSeconds,
      'cycles': cycles,
    };
  }
}

class GroundingExercise {
  final String id;
  final String title;
  final String description;
  final List<String> steps;

  GroundingExercise({
    required this.id,
    required this.title,
    required this.description,
    required this.steps,
  });

  factory GroundingExercise.fromJson(Map<String, dynamic> json) {
    return GroundingExercise(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      steps: (json['steps'] as List<dynamic>).map((s) => s as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'steps': steps,
    };
  }
}

class SafetyPlanStep {
  final String id;
  final String title;
  final String description;
  final int order;

  SafetyPlanStep({
    required this.id,
    required this.title,
    required this.description,
    required this.order,
  });

  factory SafetyPlanStep.fromJson(Map<String, dynamic> json) {
    return SafetyPlanStep(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      order: json['order'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'order': order,
    };
  }
}

class QuickExitContent {
  final String title;
  final String content;
  final String? imageUrl;
  final Map<String, dynamic>? metadata;

  QuickExitContent({
    required this.title,
    required this.content,
    this.imageUrl,
    this.metadata,
  });

  factory QuickExitContent.fromJson(Map<String, dynamic> json) {
    return QuickExitContent(
      title: json['title'] as String,
      content: json['content'] as String,
      imageUrl: json['image_url'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'image_url': imageUrl,
      'metadata': metadata,
    };
  }
}

class TrustedContact {
  final String id;
  final String name;
  final String phoneNumber;
  final String relationship;
  final bool isPrimary;
  final DateTime createdAt;

  TrustedContact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.relationship,
    this.isPrimary = false,
    required this.createdAt,
  });

  factory TrustedContact.fromJson(Map<String, dynamic> json) {
    return TrustedContact(
      id: json['id'] as String,
      name: json['name'] as String,
      phoneNumber: json['phone_number'] as String,
      relationship: json['relationship'] as String,
      isPrimary: json['is_primary'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone_number': phoneNumber,
      'relationship': relationship,
      'is_primary': isPrimary,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class SafetyPlan {
  final String id;
  final String userId;
  final List<String> warningSigns;
  final List<String> copingStrategies;
  final List<TrustedContact> trustedContacts;
  final List<String> professionalContacts;
  final List<String> safePlaces;
  final DateTime createdAt;
  final DateTime updatedAt;

  SafetyPlan({
    required this.id,
    required this.userId,
    required this.warningSigns,
    required this.copingStrategies,
    required this.trustedContacts,
    required this.professionalContacts,
    required this.safePlaces,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SafetyPlan.fromJson(Map<String, dynamic> json) {
    return SafetyPlan(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      warningSigns: (json['warning_signs'] as List<dynamic>).map((s) => s as String).toList(),
      copingStrategies: (json['coping_strategies'] as List<dynamic>).map((s) => s as String).toList(),
      trustedContacts: (json['trusted_contacts'] as List<dynamic>?)
          ?.map((c) => TrustedContact.fromJson(c as Map<String, dynamic>))
          .toList() ?? [],
      professionalContacts: (json['professional_contacts'] as List<dynamic>).map((s) => s as String).toList(),
      safePlaces: (json['safe_places'] as List<dynamic>).map((s) => s as String).toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'warning_signs': warningSigns,
      'coping_strategies': copingStrategies,
      'trusted_contacts': trustedContacts.map((c) => c.toJson()).toList(),
      'professional_contacts': professionalContacts,
      'safe_places': safePlaces,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
