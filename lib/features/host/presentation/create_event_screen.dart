import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../auth/providers/auth_provider.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/design_system.dart';

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
    return TopoBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  ),
                  Text(
                    'Create Hosted Ride',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Publish a marshal-led expedition on a curated trail.',
                style: TextStyle(color: AppColors.stone),
              ),
              const SizedBox(height: 20),
              const UpperLabel('Ride title'),
              const SizedBox(height: 8),
              TextField(
                controller: _title,
                decoration: const InputDecoration(hintText: 'Spiti Dawn Run'),
              ),
              const SizedBox(height: 14),
              const UpperLabel('Trail ID'),
              const SizedBox(height: 8),
              TextField(
                controller: _trailId,
                decoration: const InputDecoration(hintText: 'Published trail UUID'),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const UpperLabel('Price (INR)'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _price,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: '2499'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const UpperLabel('Capacity'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _capacity,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: '12'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const UpperLabel('Meetup coordinates'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _lat,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(hintText: 'Latitude'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _lng,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(hintText: 'Longitude'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const UpperLabel('Requirements'),
              const SizedBox(height: 8),
              TextField(
                controller: _requirements,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'ADV bike, cold-weather kit…',
                ),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: _pickStart,
                icon: const Icon(Icons.schedule),
                label: Text(
                  _start == null
                      ? 'Pick start date / time'
                      : DateFormat('EEE, MMM d · HH:mm').format(_start!),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: AppColors.danger)),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _busy ? null : _submit,
                child: Text(_busy ? 'Creating…' : 'Publish Ride'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
