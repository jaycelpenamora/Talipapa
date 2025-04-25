import 'package:flutter/material.dart';
import 'constants.dart';
import 'custom_bottom_navbar.dart'; // Import the custom bottom navigation bar
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

  Future<void> resetData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all saved data
    setState(() {
      notificationsEnabled = true;
      darkModeEnabled = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("All data has been reset.")),
    );
  }

  void showResetConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Reset"),
          content: Text("Are you sure you want to reset all data? This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                resetData(); // Perform reset
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Reset"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dynamically set background and text colors based on darkModeEnabled
    final backgroundColor = darkModeEnabled ? kDarkAltGray : kGreen;
    final textColor = darkModeEnabled ? Colors.white : kBlue;

    return Scaffold(
      backgroundColor: backgroundColor, // Dynamic background color
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Center( // Center the "Settings" header horizontally
          child: Text(
            "Settings",
            style: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Container(
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

            // Reset Data
            ListTile(
              title: Text(
                "Reset Data",
                style: TextStyle(fontSize: 18, color: textColor),
              ),
              onTap: () {
                showResetConfirmationDialog(); // Show confirmation dialog
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(), // Re-added the bottom navigation bar
    );
  }
}