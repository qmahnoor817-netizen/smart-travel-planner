import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/trip_model.dart';
import '../services/trip_service.dart';
import '../services/auth_service.dart';

class CreateTripScreen extends StatefulWidget {
  final Trip? trip;
  const CreateTripScreen({super.key, this.trip});

  @override
  State<CreateTripScreen> createState() => _CreateTripScreenState();
}

class _CreateTripScreenState extends State<CreateTripScreen> {
  final titleCtrl = TextEditingController();
  final destCtrl = TextEditingController();
  final notesCtrl = TextEditingController();
  DateTime? startDate, endDate;
  bool loading = false;

  bool get isEditing => widget.trip != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final t = widget.trip!;

      titleCtrl.text = t.title;
      destCtrl.text = t.destination;
      notesCtrl.text = t.notes ?? '';
      startDate = t.startDate;
      endDate = t.endDate;

      setState(() {
      });
    }
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    destCtrl.dispose();
    notesCtrl.dispose();
    super.dispose();
  }

  void saveTrip() async {
    if (titleCtrl.text.isEmpty || destCtrl.text.isEmpty || startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fill all required fields'))
      );
      return;
    }

    setState(() => loading = true);
    try {
      if (isEditing) {
        // Update existing trip
        final updatedTrip = widget.trip!.copyWith(
          title: titleCtrl.text,
          destination: destCtrl.text,
          startDate: startDate!,
          endDate: endDate!,
          notes: notesCtrl.text,
        );
        await TripService().updateTrip(updatedTrip);
      } else {
        // Create new trip
        final trip = Trip(
          id: '',
          title: titleCtrl.text,
          destination: destCtrl.text,
          startDate: startDate!,
          endDate: endDate!,
          memberIds: [AuthService().currentUser!.uid],
          ownerId: AuthService().currentUser!.uid,
          notes: notesCtrl.text,
          createdAt: DateTime.now(),
        );
        await TripService().createTrip(trip);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'))
      );
    }
    setState(() => loading = false);
  }

  Future<void> pickDate(bool isStart) async {
    final initial = isStart ? (startDate ?? DateTime.now()) : (endDate ?? startDate ?? DateTime.now());
    final date = await showDatePicker(
        context: context,
        initialDate: initial,
        firstDate: DateTime(2020),
        lastDate: DateTime(2030)
    );
    if (date != null) {
      setState(() => isStart ? startDate = date : endDate = date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(isEditing ? 'Edit Trip' : 'Create Trip'),
          backgroundColor: Colors.transparent
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(children: [
          TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Trip Title')
          ),
          const SizedBox(height: 16),
          TextField(
              controller: destCtrl,
              decoration: const InputDecoration(labelText: 'Destination')
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => pickDate(true),
                child: Text(
                    startDate == null
                        ? 'Start Date'
                        : DateFormat('MMM dd, yyyy').format(startDate!)
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton(
                onPressed: () => pickDate(false),
                child: Text(
                    endDate == null
                        ? 'End Date'
                        : DateFormat('MMM dd, yyyy').format(endDate!)
                ),
              ),
            ),
          ]),
          const SizedBox(height: 16),
          TextField(
              controller: notesCtrl,
              decoration: const InputDecoration(labelText: 'Notes'),
              maxLines: 3
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: loading ? null : saveTrip,
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C5CE7),
                minimumSize: const Size(double.infinity, 50)
            ),
            child: loading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(isEditing ? 'Update Trip' : 'Create Trip',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ]),
      ),
    );
  }
}