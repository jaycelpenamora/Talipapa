import 'package:flutter/material.dart';
import 'constants.dart';
import 'custom_bottom_navbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = true; // Default value for notifications
  bool darkModeEnabled = false; // Default value for dark mode

  @override
  void initState() {
    super.initState();
    loadSettings(); // Load saved settings
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      darkModeEnabled = prefs.getBool('darkModeEnabled') ?? false;
    });
  }

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', notificationsEnabled);
    await prefs.setBool('darkModeEnabled', darkModeEnabled);
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = darkModeEnabled ? Color(0xFF293045) : kGreen;
    final textColor = darkModeEnabled ? Color(0xFFBAC1B8) : kBlue;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text(
          "Settings",
          style: TextStyle(color: textColor),
        ),
      ),
      body: Container(
        color: backgroundColor, // Background color
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notifications Toggle
            ListTile(
              title: Text(
                "Notifications",
                style: TextStyle(fontSize: 18, color: textColor),
              ),
              trailing: Switch(
                value: notificationsEnabled,
                onChanged: (bool value) {
                  setState(() {
                    notificationsEnabled = value;
                  });
                  saveSettings(); // Save the updated setting
                },
              ),
            ),
            Divider(color: textColor),

            // Dark Mode Toggle
            ListTile(
              title: Text(
                "Dark Mode",
                style: TextStyle(fontSize: 18, color: textColor),
              ),
              trailing: Switch(
                value: darkModeEnabled,
                onChanged: (bool value) {
                  setState(() {
                    darkModeEnabled = value;
                  });
                  saveSettings(); // Save the updated setting
                },
              ),
            ),
            Divider(color: textColor),

            // Account Management
            ListTile(
              title: Text(
                "Account",
                style: TextStyle(fontSize: 18, color: textColor),
              ),
              subtitle: Text(
                "Manage your account settings",
                style: TextStyle(fontSize: 14, color: textColor),
              ),
              onTap: () {
                // Navigate to account management page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AccountManagementPage()),
                );
              },
            ),
            Divider(color: textColor),

            // Privacy Policy
            ListTile(
              title: Text(
                "Privacy Policy",
                style: TextStyle(fontSize: 18, color: textColor),
              ),
              onTap: () {
                // Handle privacy policy navigation
              },
            ),
            Divider(color: textColor),

            // App Version
            ListTile(
              title: Text(
                "Version",
                style: TextStyle(fontSize: 18, color: textColor),
              ),
              subtitle: Text(
                "1.0.0",
                style: TextStyle(fontSize: 14, color: textColor),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(),
    );
  }
}

// Placeholder for Account Management Page
class AccountManagementPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kGreen,
        title: Text(
          "Account Management",
          style: TextStyle(color: kBlue),
        ),
      ),
      body: Center(
        child: Text(
          "Account management features go here.",
          style: TextStyle(fontSize: 16, color: kBlue),
        ),
      ),
    );
  }
}