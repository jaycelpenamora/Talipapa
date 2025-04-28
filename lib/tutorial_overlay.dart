import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';

class TutorialOverlay extends StatefulWidget {
  final VoidCallback onClose;

  const TutorialOverlay({super.key, required this.onClose});

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> {
  bool dontShowAgain = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Material(  // Wrap with Material for proper overlay
        type: MaterialType.transparency,
        child: Container(
          width: MediaQuery.of(context).size.width,  // Full width
          height: MediaQuery.of(context).size.height, // Full height
          color: Colors.black.withOpacity(0.7),      // Darker overlay
          child: SafeArea(
            child: Center(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Welcome to Talipapa!",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: kBlue,
                      ),
                    ),
                    SizedBox(height: 24),
                    ListTile(
                      leading: Icon(Icons.star, color: kPink),
                      title: Text("Favorite Commodities", 
                        style: TextStyle(color: kBlue)),
                      subtitle: Text("Tap the star icon to manage your favorites",
                        style: TextStyle(color: kBlue)),
                    ),
                    ListTile(
                      leading: Icon(Icons.add, color: kPink),
                      title: Text("Add Commodities", 
                        style: TextStyle(color: kBlue)),
                      subtitle: Text("Use the add icon to manage displayed items",
                        style: TextStyle(color: kBlue)),
                    ),
                    ListTile(
                      leading: Icon(Icons.touch_app, color: kBlue),
                      title: Text("Select Items", 
                        style: TextStyle(color: kBlue)),
                      subtitle: Text("Tap to select for price prediction",
                        style: TextStyle(color: kBlue)),
                    ),
                    ListTile(
                      leading: Icon(Icons.pan_tool, color: kBlue),
                      title: Text("Multiple Selection",
                        style: TextStyle(color: kBlue)),
                      subtitle: Text("Long press to select multiple items",
                        style: TextStyle(color: kBlue)),
                    ),
                    SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: dontShowAgain,
                              onChanged: (bool? value) {
                                setState(() {
                                  dontShowAgain = value ?? false;
                                });
                              },
                              activeColor: kPink,
                            ),
                            Text(
                              "Skip app launch tutorial", // Updated text
                              style: TextStyle(
                                color: kBlue,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () async {
                            if (dontShowAgain) {
                              final prefs = await SharedPreferences.getInstance();
                              await prefs.setBool('skipLaunchTutorial', true); // Changed key
                            }
                            widget.onClose();
                          },
                          child: Text("Close", style: TextStyle(color: kPink)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}