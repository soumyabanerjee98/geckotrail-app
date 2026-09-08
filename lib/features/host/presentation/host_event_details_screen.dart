import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../../../shared/models/event.dart';
import '../../../shared/models/ride.dart';
import '../../../shared/widgets/async_body.dart';
import '../../../shared/theme/app_theme.dart';
import 'host_dashboard_screen.dart';

final hostEventProvider =
    FutureProvider.autoDispose.family<HostedEvent, String>((ref, id) {
  return ref.watch(eventRepositoryProvider).getEvent(id);
});

final hostParticipantsProvider =
    FutureProvider.autoDispose.family<List<EventParticipant>, String>((ref, id) {
  return ref.watch(eventRepositoryProvider).participants(id);
});

class HostEventDetailsScreen extends ConsumerStatefulWidget {
  const HostEventDetailsScreen({super.key, required this.eventId});

  final String eventId;

  @override
  ConsumerState<HostEventDetailsScreen> createState() =>
      _HostEventDetailsScreenState();
}

class _HostEventDetailsScreenState
    extends ConsumerState<HostEventDetailsScreen> {
  final Set<String> _selectedParticipants = {};
  bool _busy = false;
  String? _message;

  Future<void> _complete() async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await ref.read(eventRepositoryProvider).completeEvent(
            widget.eventId,
            participantRiderIds: _selectedParticipants.toList(),
          );
      setState(() {
        _message =
            'Event completed on the server. Route access is granted by the backend to confirmed participants.';
      });
      ref.invalidate(hostEventsProvider);
      ref.invalidate(hostEventProvider(widget.eventId));
    } catch (e) {
      setState(() => _message = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _award(String riderId) async {
    final controller = TextEditingController(text: '1');
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Award recommendation points'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Recommendation points are private behavioural trust — not a public score.',
            ),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Points'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Award')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(eventRepositoryProvider).awardRecommendation(
            eventId: widget.eventId,
            riderId: riderId,
            points: int.tryParse(controller.text.trim()) ?? 1,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recommendation recorded by backend')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(hostEventProvider(widget.eventId));
    final participantsAsync = ref.watch(hostParticipantsProvider(widget.eventId));

    return Scaffold(
      appBar: AppBar(title: const Text('Host event')),
      body: eventAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (event) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(event.title, style: Theme.of(context).textTheme.headlineMedium),
              Text('Status: ${event.status.name}'),
              const SizedBox(height: 16),
              const Text(
                'Attendance, participation, and recommendation are separate. Completing the event asks the backend to grant route access only to riders you mark as genuine participants.',
              ),
              const SizedBox(height: 16),
              Text('Participants', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              participantsAsync.when(
                loading: () => const LoadingView(),
                error: (e, _) => ErrorView(message: e.toString()),
                data: (participants) {
                  if (participants.isEmpty) {
                    return const EmptyView(title: 'No participants yet');
                  }
                  return Column(
                    children: participants.map((p) {
                      final selected = _selectedParticipants.contains(p.riderId);
                      return CheckboxListTile(
                        value: selected,
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              _selectedParticipants.add(p.riderId);
                            } else {
                              _selectedParticipants.remove(p.riderId);
                            }
                          });
                        },
                        title: Text(p.name),
                        subtitle: Text(
                          'Enrolment: ${p.enrollmentStatus ?? '—'} · Attendance: ${p.attendanceStatus ?? '—'}',
                        ),
                        secondary: IconButton(
                          tooltip: 'Award recommendation',
                          onPressed: () => _award(p.riderId),
                          icon: const Icon(Icons.thumb_up_alt_outlined),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              if (_message != null) ...[
                const SizedBox(height: 12),
                Text(_message!, style: const TextStyle(color: AppColors.forest)),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _busy || _selectedParticipants.isEmpty ? null : _complete,
                child: Text(_busy ? 'Completing…' : 'Complete event'),
              ),
            ],
          );
        },
      ),
    );
  }
}
