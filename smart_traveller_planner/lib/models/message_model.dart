import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String tripId;
  final String senderId;
  final String? senderName;
  final String text;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.tripId,
    required this.senderId,
    this.senderName,
    required this.text,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
    'tripId': tripId,
    'senderId': senderId,
    'senderName': senderName,
    'text': text,
    'timestamp': Timestamp.fromDate(timestamp),
  };

  factory Message.fromMap(String id, Map<String, dynamic> map) {
    final ts = map['timestamp'];
    DateTime dateTime;

    if (ts is Timestamp) {
      dateTime = ts.toDate();
    } else if (ts is String) {
      dateTime = DateTime.parse(ts);
    } else {
      dateTime = DateTime.now();
    }

    return Message(
      id: id,
      tripId: map['tripId']?? '',
      senderId: map['senderId']?? '',
      senderName: map['senderName'],
      text: map['text']?? '',
      timestamp: dateTime,
    );
  }
}