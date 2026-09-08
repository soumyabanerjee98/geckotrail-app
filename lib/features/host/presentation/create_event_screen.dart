import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/providers/auth_provider.dart';
import '../../../shared/theme/app_theme.dart';

class CreateEventScreen extends ConsumerStatefulWidget {
  const CreateEventScreen({super.key});

  @override
  ConsumerState<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends ConsumerState<CreateEventScreen> {
  final _title = TextEditingController();
  final _trailId = TextEditingController();
  final _price = TextEditingController();
  final _capacity = TextEditingController();
  final _lat = TextEditingController();
  final _lng = TextEditingController();
  final _requirements = TextEditingController();
  DateTime? _start;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    _trailId.dispose();
    _price.dispose();
    _capacity.dispose();
    _lat.dispose();
    _lng.dispose();
    _requirements.dispose();
    super.dispose();
  }

  Future<void> _pickStart() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: DateTime.now().add(const Duration(days: 7)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 7, minute: 0),
    );
    if (time == null) return;
    setState(() {
      _start = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final event = await ref.read(eventRepositoryProvider).createEvent({
        'trailId': _trailId.text.trim(),
        'title': _title.text.trim(),
        'startDateTime': _start?.toUtc().toIso8601String(),
        'meetupLatitude': double.tryParse(_lat.text.trim()),
        'meetupLongitude': double.tryParse(_lng.text.trim()),
        'attendanceRadiusMeters': 150,
        'capacity': int.tryParse(_capacity.text.trim()),
        'price': double.tryParse(_price.text.trim()),
        'currency': 'INR',
        'requirements': _requirements.text.trim(),
      });
      if (!mounted) return;
      context.go('/host/events/${event.id}');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create event')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title')),
          const SizedBox(height: 12),
          TextField(controller: _trailId, decoration: const InputDecoration(labelText: 'Trail ID')),
          const SizedBox(height: 12),
          TextField(
            controller: _price,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Price (INR)'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _capacity,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Capacity'),
          ),
          const SizedBox(height: 12),
          TextField(controller: _lat, decoration: const InputDecoration(labelText: 'Meetup latitude')),
          const SizedBox(height: 12),
          TextField(controller: _lng, decoration: const InputDecoration(labelText: 'Meetup longitude')),
          const SizedBox(height: 12),
          TextField(
            controller: _requirements,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Requirements'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _pickStart,
            child: Text(
              _start == null ? 'Pick start date/time' : _start!.toLocal().toString(),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: AppColors.danger)),
          ],
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _busy ? null : _submit,
            child: Text(_busy ? 'Creating…' : 'Create event'),
          ),
        ],
      ),
    );
  }
}
