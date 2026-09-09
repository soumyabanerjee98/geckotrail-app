import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../auth/providers/auth_provider.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/design_system.dart';
import '../../../shared/widgets/profile_avatar_hero.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _name = TextEditingController();
  final _bio = TextEditingController();
  final _experience = TextEditingController();
  final _bike = TextEditingController();
  final _picker = ImagePicker();

  File? _pickedPhoto;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authControllerProvider).user;
    _name.text = user?.name ?? '';
    _bio.text = user?.bio ?? '';
    _experience.text = user?.ridingExperience ?? '';
    _bike.text = user?.bikeInfo ?? '';
  }

  @override
  void dispose() {
    _name.dispose();
    _bio.dispose();
    _experience.dispose();
    _bike.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (file == null) return;
      setState(() {
        _pickedPhoto = File(file.path);
        _error = null;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _showPhotoSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.sand,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Update profile photo',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined, color: AppColors.forest),
                  title: const Text('Choose from gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickPhoto(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined, color: AppColors.forest),
                  title: const Text('Take a photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickPhoto(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Name is required');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(authControllerProvider.notifier).updateProfile(
            payload: {
              'name': name,
              'bio': _bio.text.trim(),
              'ridingExperience': _experience.text.trim(),
              'bikeInfo': _bike.text.trim(),
            },
            photoPath: _pickedPhoto?.path,
            photoFileName: _pickedPhoto?.path.split(Platform.pathSeparator).last,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
      context.pop();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user;
    final initials = _name.text.isNotEmpty
        ? _name.text
        : (user?.name.isNotEmpty == true ? user!.name : 'R');

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
                  Expanded(
                    child: Text(
                      'Edit Profile',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Update your rider identity. Photo upload is stored by the backend.',
                style: TextStyle(color: AppColors.stone),
              ),
              const SizedBox(height: 24),
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    ProfileAvatarHero(
                      radius: 56,
                      photoUrl: user?.photoUrl,
                      localFile: _pickedPhoto,
                      initials: initials,
                      showBorder: true,
                      enableHero: false,
                      onTap: _busy ? null : _showPhotoSheet,
                    ),
                    Material(
                      color: AppColors.ember,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: _busy ? null : _showPhotoSheet,
                        child: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(Icons.camera_alt, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: _busy ? null : _showPhotoSheet,
                  child: const Text('Change photo'),
                ),
              ),
              const SizedBox(height: 20),
              const UpperLabel('Display name'),
              const SizedBox(height: 8),
              TextField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(hintText: 'Your name'),
              ),
              const SizedBox(height: 14),
              const UpperLabel('Bio'),
              const SizedBox(height: 8),
              TextField(
                controller: _bio,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Short rider bio…',
                ),
              ),
              const SizedBox(height: 14),
              const UpperLabel('Riding experience'),
              const SizedBox(height: 8),
              TextField(
                controller: _experience,
                decoration: const InputDecoration(
                  hintText: 'e.g. Riding since 2016 · 8 years ADV',
                ),
              ),
              const SizedBox(height: 14),
              const UpperLabel('Current steed'),
              const SizedBox(height: 8),
              TextField(
                controller: _bike,
                decoration: const InputDecoration(
                  hintText: 'e.g. RE Himalayan 450',
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 14),
                Text(_error!, style: const TextStyle(color: AppColors.danger)),
              ],
              const SizedBox(height: 28),
              ElevatedButton(
                onPressed: _busy ? null : _save,
                child: Text(_busy ? 'Saving…' : 'Save profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
