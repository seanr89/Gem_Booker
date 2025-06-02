import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _nicknameController;

  @override
  void initState() {
    super.initState();
    // Initialize controller with current value from service, but only listen for updates from UI
    // The service will provide the initial value once loaded.
    // We use addPostFrameCallback to ensure SettingsService has loaded its prefs.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final settings = Provider.of<SettingsService>(context, listen: false);
        _nicknameController.text = settings.userNickname;
      }
    });
    _nicknameController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Update text controller if the nickname changes from outside (e.g. initial load)
    // This is a robust way to handle it.
    final settings = Provider.of<SettingsService>(context, listen: false);
    if (_nicknameController.text != settings.userNickname) {
      _nicknameController.text = settings.userNickname;
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use Consumer for parts of the UI that need to rebuild when settings change
    // Or use Provider.of<SettingsService>(context) for values and methods.
    final settings = Provider.of<SettingsService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          // --- Dark Mode Toggle ---
          SwitchListTile(
            title: const Text('Enable Dark Mode'),
            subtitle: const Text('Toggle between light and dark theme'),
            value: settings.darkModeEnabled,
            onChanged: (bool value) {
              settings.setDarkMode(value);
            },
            secondary: Icon(
                settings.darkModeEnabled ? Icons.dark_mode : Icons.light_mode),
          ),
          const Divider(),

          // --- Notification Toggle ---
          SwitchListTile(
            title: const Text('Enable Notifications'),
            value: settings.notificationEnabled,
            onChanged: (bool value) {
              settings.setNotificationEnabled(value);
            },
            secondary: const Icon(Icons.notifications_active),
          ),
          const Divider(),

          // --- Language Dropdown ---
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('App Language'),
            trailing: DropdownButton<String>(
              value: settings.selectedLanguage,
              underline: Container(), // Remove default underline
              onChanged: (String? newValue) {
                if (newValue != null) {
                  settings.setSelectedLanguage(newValue);
                }
              },
              items: <String>['en', 'es', 'fr', 'de'] // Example languages
                  .map<DropdownMenuItem<String>>((String value) {
                String displayName = value;
                switch (value) {
                  case 'en':
                    displayName = 'English';
                    break;
                  case 'es':
                    displayName = 'Español';
                    break;
                  case 'fr':
                    displayName = 'Français';
                    break;
                  case 'de':
                    displayName = 'Deutsch';
                    break;
                }
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(displayName),
                );
              }).toList(),
            ),
          ),
          const Divider(),

          // --- Font Size Slider ---
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: const Icon(Icons.format_size),
                  title: Text(
                      'Font Size Multiplier: ${settings.fontSizeMultiplier.toStringAsFixed(1)}x'),
                  contentPadding: EdgeInsets.zero,
                ),
                Slider(
                  value: settings.fontSizeMultiplier,
                  min: 0.8,
                  max: 1.5,
                  divisions: 7, // (1.5 - 0.8) / 0.1 = 7
                  label: settings.fontSizeMultiplier.toStringAsFixed(1),
                  onChanged: (double value) {
                    settings.setFontSizeMultiplier(value);
                  },
                ),
              ],
            ),
          ),
          const Divider(),

          // --- User Nickname Text Field ---
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: TextField(
              controller: _nicknameController,
              decoration: const InputDecoration(
                labelText: 'User Nickname',
                hintText: 'Enter your nickname',
                border: InputBorder.none, // cleaner look in a ListTile
              ),
              onSubmitted: (String value) {
                // Save on submit
                settings.setUserNickname(value);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nickname saved!')),
                );
              },
              // Or save on focus lost, or with a dedicated "Save" button
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0),
            child: ElevatedButton(
                onPressed: () {
                  settings.setUserNickname(_nicknameController.text);
                  FocusScope.of(context).unfocus(); // Hide keyboard
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nickname saved!')),
                  );
                },
                child: const Text("Save Nickname")),
          ),
          const Divider(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.admin_panel_settings),
            title: const Text('Admin Panel'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              context.go('/admin'); // Navigate to the admin page
            },
          ),
          const Divider(),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              'Text affected by font size setting.',
              style: TextStyle(
                  // fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * settings.fontSizeMultiplier, // Redundant if theme is handling it
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
