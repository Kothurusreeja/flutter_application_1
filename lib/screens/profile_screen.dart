import 'package:flutter/material.dart';

import 'favorites_screen.dart';
import 'recently_played_screen.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const ProfileScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController(
    text: 'VibeTune Listener',
  );
  final TextEditingController _bioController = TextEditingController(
    text: 'Music • Mood • Moments',
  );
  bool _notificationsEnabled = true;
  bool _privateMode = false;

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final name = _nameController.text.trim();
    final bio = _bioController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Name cannot be empty')));
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Profile saved')));

    setState(() {
      _nameController.text = name;
      _bioController.text = bio.isEmpty ? 'Music • Mood • Moments' : bio;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF9C6BFF), Color(0xFFFF5C8A)],
                ),
              ),
              child: const Icon(Icons.person, size: 55),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _nameController,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _bioController,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _saveProfile,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C6BFF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                Expanded(child: profileStat('5', 'Songs')),
                const SizedBox(width: 12),
                Expanded(child: profileStat('5', 'Moods')),
                const SizedBox(width: 12),
                Expanded(child: profileStat('∞', 'Vibes')),
              ],
            ),
            const SizedBox(height: 35),
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF191923),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Material(
                color: const Color(0xFF191923),
                borderRadius: BorderRadius.circular(16),
                child: SwitchListTile(
                  value: widget.isDarkMode,
                  onChanged: (_) => widget.onThemeToggle(),
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Dark mode'),
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF191923),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Material(
                color: const Color(0xFF191923),
                borderRadius: BorderRadius.circular(16),
                child: SwitchListTile(
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                  secondary: const Icon(Icons.notifications_outlined),
                  title: const Text('Notifications'),
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF191923),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Material(
                color: const Color(0xFF191923),
                borderRadius: BorderRadius.circular(16),
                child: SwitchListTile(
                  value: _privateMode,
                  onChanged: (value) {
                    setState(() {
                      _privateMode = value;
                    });
                  },
                  secondary: const Icon(Icons.lock_outline),
                  title: const Text('Private mode'),
                ),
              ),
            ),
            profileOption(Icons.music_note, 'My Music', () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const FavoritesScreen(),
                ),
              );
            }),
            profileOption(Icons.history, 'Recently Played', () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const RecentlyPlayedScreen(),
                ),
              );
            }),
            profileOption(
              Icons.settings_outlined,
              'Settings',
              _showSettingsDialog,
            ),
            profileOption(Icons.info_outline, 'About VibeTune', () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('About VibeTune'),
                  content: const Text(
                    'A mood-based music app built for listening to the vibe.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget profileStat(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF191923),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }

  Future<void> _showSettingsDialog() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: widget.isDarkMode,
                onChanged: (_) => widget.onThemeToggle(),
                title: const Text('Dark mode'),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() => _notificationsEnabled = value);
                  Navigator.of(dialogContext).pop();
                },
                title: const Text('Notifications'),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _privateMode,
                onChanged: (value) {
                  setState(() => _privateMode = value);
                  Navigator.of(dialogContext).pop();
                },
                title: const Text('Private mode'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  Widget profileOption(IconData icon, String title, VoidCallback onTap) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF191923),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: const Color(0xFF191923),
        borderRadius: BorderRadius.circular(16),
        child: ListTile(
          onTap: onTap,
          leading: Icon(icon),
          title: Text(title),
          trailing: const Icon(Icons.chevron_right, color: Colors.white54),
        ),
      ),
    );
  }
}
