import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/trip_service.dart';

class ItineraryItem {
  final String id;
  final String day; // "Day 1", "Day 2" - for display
  final String title;
  final String note;
  final String time; // "09:00 AM"
  final Timestamp createdAt; // for sorting

  ItineraryItem({
    required this.id,
    required this.day,
    required this.title,
    required this.note,
    required this.time,
    required this.createdAt,
  });

  factory ItineraryItem.fromMap(Map<String, dynamic> map, String id) {
    Timestamp createdAtTs;
    final raw = map['createdAt'];

    if (raw is Timestamp) {
      createdAtTs = raw;
    } else if (raw is String) {
      createdAtTs = Timestamp.fromDate(DateTime.parse(raw));
    } else {
      createdAtTs = Timestamp.now();
    }

    return ItineraryItem(
      id: id,
      day: map['day']?? '',
      title: map['title']?? '',
      note: map['note']?? '',
      time: map['time']?? '',
      createdAt: createdAtTs,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'title': title,
      'note': note,
      'time': time,
      'createdAt': createdAt,
    };
  }

}