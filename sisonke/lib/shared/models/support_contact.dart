/// Represents a support contact (helpline, clinic, counselor)
class SupportContact {
  final String id;
  final String name;
  final SupportServiceType serviceType;
  final String? phoneNumber;
  final String? email;
  final String? website;
  final String? address;
  final double? latitude;
  final double? longitude;
  final List<String> services;
  final String? operatingHours;
  final bool hasUserSaved;

  SupportContact({
    required this.id,
    required this.name,
    required this.serviceType,
    this.phoneNumber,
    this.email,
    this.website,
    this.address,
    this.latitude,
    this.longitude,
    this.services = const [],
    this.operatingHours,
    this.hasUserSaved = false,
  });

  SupportContact copyWith({
    String? id,
    String? name,
    SupportServiceType? serviceType,
    String? phoneNumber,
    String? email,
    String? website,
    String? address,
    double? latitude,
    double? longitude,
    List<String>? services,
    String? operatingHours,
    bool? hasUserSaved,
  }) {
    return SupportContact(
      id: id ?? this.id,
      name: name ?? this.name,
      serviceType: serviceType ?? this.serviceType,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      website: website ?? this.website,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      services: services ?? this.services,
      operatingHours: operatingHours ?? this.operatingHours,
      hasUserSaved: hasUserSaved ?? this.hasUserSaved,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupportContact &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

enum SupportServiceType {
  helpline('Helpline'),
  clinic('Clinic'),
  youthFriendly('Youth-Friendly Center'),
  counselor('Counselor'),
  organization('Organization');

  final String label;
  const SupportServiceType(this.label);
}

