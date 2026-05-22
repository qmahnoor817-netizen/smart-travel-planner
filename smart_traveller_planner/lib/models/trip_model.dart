class Trip {
  final String id;
  final String title;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> memberIds;
  final String ownerId;
  final String? notes;
  final DateTime createdAt;

  Trip({
    required this.id,
    required this.title,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.memberIds,
    required this.ownerId,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'title': title,
    'destination': destination,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'memberIds': memberIds,
    'ownerId': ownerId,
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Trip.fromMap(String id, Map<String, dynamic> map) {
    return Trip(
      id: id,
      title: map['title'],
      destination: map['destination'],
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      memberIds: List<String>.from(map['memberIds']),
      ownerId: map['ownerId'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Trip copyWith({
    String? id,
    String? title,
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? memberIds,
    String? ownerId,
    String? notes,
    DateTime? createdAt,
  }) {
    return Trip(
      id: id ?? this.id,
      title: title ?? this.title,
      destination: destination ?? this.destination,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      memberIds: memberIds ?? this.memberIds,
      ownerId: ownerId ?? this.ownerId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}