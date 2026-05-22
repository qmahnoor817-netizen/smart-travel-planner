import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import '../models/trip_model.dart';
import '../models/itinerary_item.dart';
import '../services/trip_service.dart';
import '../services/api_service.dart';
import 'chat_screen.dart';
import 'explore_screen.dart';

class TripDetailsScreen extends StatefulWidget {
  final Trip trip;
  const TripDetailsScreen({super.key, required this.trip});

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  final api = ApiService();
  int selectedDay = 1;
  LatLng? destinationLatLng;
  String weather = '--°C';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final places = await api.getAttractions(widget.trip.destination);
    if (places.isNotEmpty && places[0]['geocodes']!= null) {
      final loc = places[0]['geocodes']['main'];
      if (mounted) {
        setState(() => destinationLatLng = LatLng(loc['latitude'], loc['longitude']));
      }
    }

    // Changed: load weather for selected day
    await _loadWeatherForDay(selectedDay);

    if (mounted) setState(() => isLoading = false);
  }

  // New function for day-wise weather
  Future<void> _loadWeatherForDay(int day) async {
    final date = widget.trip.startDate.add(Duration(days: day - 1));
    final temp = await api.getTempForDate(widget.trip.destination, date);
    if (mounted) {
      setState(() {
        weather = temp!= null? '$temp°C' : '--°C';
      });
    }
  }

  Future<bool?> _confirmDelete() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        title: const Text('Delete Activity?'),
        content: const Text('Do you really want to delete this activity? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  int get totalDays => widget.trip.endDate.difference(widget.trip.startDate).inDays + 1;

  void _addItem() {
    final titleCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    final timeCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF151B2D),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20, right: 20, top: 20,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Add Activity', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Place/Activity')),
          const SizedBox(height: 12),
          TextField(controller: timeCtrl, decoration: const InputDecoration(labelText: 'Time e.g. 09:00')),
          const SizedBox(height: 12),
          TextField(controller: noteCtrl, decoration: const InputDecoration(labelText: 'Note'), maxLines: 2),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (titleCtrl.text.isEmpty) return;

              final newItem = ItineraryItem(
                id: '',
                day: 'Day $selectedDay', // Make sure this matches your filter
                title: titleCtrl.text,
                note: noteCtrl.text,
                time: timeCtrl.text,
                createdAt: Timestamp.now(),
              );

              print('Adding item for: ${newItem.day}'); // DEBUG LINE

              TripService().addItineraryItem(widget.trip.id, newItem);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C5CE7),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Add', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  void _editItem(ItineraryItem item) {
    final titleCtrl = TextEditingController(text: item.title);
    final noteCtrl = TextEditingController(text: item.note);
    final timeCtrl = TextEditingController(text: item.time);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF151B2D),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Edit Activity', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Place/Activity')),
          const SizedBox(height: 12),
          TextField(controller: timeCtrl, decoration: const InputDecoration(labelText: 'Time')),
          const SizedBox(height: 12),
          TextField(controller: noteCtrl, decoration: const InputDecoration(labelText: 'Note'), maxLines: 2),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              TripService().updateItineraryItem(widget.trip.id, item.id, {
                'title': titleCtrl.text,
                'note': noteCtrl.text,
                'time': timeCtrl.text,
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C5CE7), minimumSize: const Size(double.infinity, 50)),
            child: const Text('Save', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  Widget _buildDayTabs() {
    return IntrinsicHeight( // auto-adjusts to content height
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: List.generate(totalDays, (i) {
            final isSelected = selectedDay == i + 1;
            final date = widget.trip.startDate.add(Duration(days: i));
            return GestureDetector(
              onTap: () {
                setState(() => selectedDay = i + 1);
                _loadWeatherForDay(i + 1);
              },
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected? const Color(0xFF6C5CE7) : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isSelected? Colors.transparent : Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Day ${i + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(DateFormat('MMM dd').format(date),
                        style: TextStyle(fontSize: 12, color: Colors.grey[400])),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _glassCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.trip.title),
        actions: [
          IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(tripId: widget.trip.id))),
              icon: const Icon(Icons.chat_bubble_outline)),
          IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ExploreScreen(city: widget.trip.destination, tripId: widget.trip.id,))),
              icon: const Icon(Icons.explore)),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0E1A), Color(0xFF151B2D), Color(0xFF1E2442)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF6C5CE7)))
            : Column(children: [
          const SizedBox(height: 100),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.trip.destination, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold))
                  .animate().fadeIn().slideX(begin: -0.2),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.thermostat, size: 16, color: Color(0xFFFF6B6B)),
                const SizedBox(width: 6),
                Text('$weather • $totalDays Days', style: TextStyle(color: Colors.grey[400])),
              ]).animate(delay: 200.ms).fadeIn(),
            ]),
          ),
          const SizedBox(height: 16),

          // Map - kept exactly like before
          if (destinationLatLng!= null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _glassCard(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: 160,
                    child: FlutterMap(
                      options: MapOptions(initialCenter: destinationLatLng!, initialZoom: 11),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                          subdomains: const ['a', 'b', 'c', 'd'],
                        ),
                        MarkerLayer(markers: [
                          Marker(point: destinationLatLng!, child: const Icon(Icons.location_pin, color: Color(0xFF6C5CE7), size: 40)),
                        ]),
                      ],
                    ),
                  ),
                ),
              ).animate(delay: 300.ms).fadeIn().scale(begin: const Offset(0.95, 0.95)),
            ),

          const SizedBox(height: 20),
          _buildDayTabs().animate(delay: 400.ms).fadeIn().slideY(begin: 0.2),
          const SizedBox(height: 20),

          // Itinerary list
          Expanded(
            child: StreamBuilder<List<ItineraryItem>>(
              stream: TripService().getItinerary(widget.trip.id),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text('Error: ${snap.error}'));
                }

                final allItems = snap.data?? [];
                print('Total items from Firestore: ${allItems.length}');
                print('Looking for day: Day $selectedDay');

                final items = allItems
                    .where((e) => e.day == 'Day $selectedDay')
                    .toList()
                  ..sort((a, b)  {
                    final format = DateFormat('hh:mm a', 'en_US');
                    final timeA = format.tryParse(a.time) ?? DateTime(0);
                    final timeB = format.tryParse(b.time) ?? DateTime(0);
                    return timeA.compareTo(timeB);
                  });

                print('Filtered items for this day: ${items.length}');

                if (items.isEmpty) {
                  return Center(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.event_note, size: 48, color: Colors.grey[600]),
                      const SizedBox(height: 12),
                      Text('No plans for Day $selectedDay', style: TextStyle(color: Colors.grey[400])),
                    ]),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final item = items[i];
                    // FIX 3: Replaced Dismissible with Row + PopupMenu for edit/delete
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6C5CE7).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(item.time.isEmpty? '--:--' : item.time, style: const TextStyle(color: Color(0xFF00D9FF))),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(item.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            if (item.note.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(item.note, style: TextStyle(color: Colors.grey[400])),
                              ),
                          ]),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (val) async {
                            if (val == 'edit') {
                              _editItem(item);
                            } else if (val == 'delete') {
                              final confirm = await _confirmDelete(); // show dialog
                              if (confirm == true) {
                                await TripService().deleteItineraryItem(widget.trip.id, item.id);
                              }
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'edit', child: Row(children: [
                              Icon(Icons.edit, size: 18), SizedBox(width: 8), Text('Edit'),
                            ])),
                            const PopupMenuItem(value: 'delete', child: Row(children: [
                              Icon(Icons.delete, size: 18, color: Colors.redAccent),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: Colors.redAccent)),
                            ])),
                          ],
                          icon: const Icon(Icons.more_vert, color: Colors.grey),
                        )
                      ]),
                    ).animate(delay: (i * 100).ms).fadeIn().slideX(begin: 0.2);
                  },
                );
              },
            ),
          ),
        ]),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addItem,
        backgroundColor: const Color(0xFF6C5CE7),
        icon: const Icon(Icons.add),
        label: const Text('Add Activity'),
      ),
    );
  }
}