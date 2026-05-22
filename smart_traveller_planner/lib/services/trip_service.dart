import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trip_model.dart';
import '../models/message_model.dart';
import '../models/itinerary_item.dart';

class TripService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // TRIPS
  Stream<List<Trip>> getUserTrips(String uid) {
    return _db.collection('trips')
        .where('memberIds', arrayContains: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((d) => Trip.fromMap(d.id, d.data()))
        .toList());
  }

  Future<String> createTrip(Trip trip) async {
    final doc = await _db.collection('trips').add(trip.toMap());
    return doc.id;
  }

  Future<void> updateTrip(Trip trip) {
    return _db.collection('trips').doc(trip.id).update(trip.toMap());
  }

  Future<void> deleteTrip(String tripId) async {
    await _db.collection('trips').doc(tripId).delete();
  }

  Future<void> addMember(String tripId, String userId) async {
    await _db.collection('trips').doc(tripId).update({
      'memberIds': FieldValue.arrayUnion([userId])
    });
  }

  Future<void> removeMember(String tripId, String userId) async {
    await _db.collection('trips').doc(tripId).update({
      'memberIds': FieldValue.arrayRemove([userId])
    });
  }

  // CHAT MESSAGES
  Stream<List<Message>> getTripMessages(String tripId) {
    return _db.collection('trips')
        .doc(tripId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => Message.fromMap(doc.id, doc.data()))
        .toList());
  }

  Future<void> sendMessage(Message msg) async {
    await _db.collection('trips')
        .doc(msg.tripId)
        .collection('messages')
        .doc(msg.id)
        .set(msg.toMap());
  }

  // ITINERARY
  Stream<List<ItineraryItem>> getItinerary(String tripId) {
    return _db.collection('trips')
        .doc(tripId)
        .collection('itinerary')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs
        .map((doc) => ItineraryItem.fromMap(doc.data(), doc.id))
        .toList());
  }

  Future<void> addItineraryItem(String tripId, ItineraryItem item) async {
    final itemWithTime = ItineraryItem(
      id: '',
      day: item.day,
      title: item.title,
      note: item.note,
      time: item.time,
      createdAt: Timestamp.now(),
    );

    await _db.collection('trips')
        .doc(tripId)
        .collection('itinerary')
        .add(itemWithTime.toMap());
  }

  Future<void> updateItineraryItem(String tripId, String itemId, Map<String, dynamic> data) async {
    await _db.collection('trips').doc(tripId).collection('itinerary').doc(itemId).update(data);
  }

  Future<void> deleteItineraryItem(String tripId, String itemId) async {
    await _db.collection('trips').doc(tripId).collection('itinerary').doc(itemId).delete();
  }
}