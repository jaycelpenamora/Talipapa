import 'package:flutter/material.dart';
import 'constants.dart';
import 'custom_bottom_navbar.dart';

class FishPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kGreen,
        title: Text(
          "Fish Page",
          style: TextStyle(color: kBlue),
        ),
      ),
      body: Center(
        child: Text(
          "Welcome to the Fish Page!",
          style: TextStyle(fontSize: 18, color: kBlue),
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(), // No arguments needed
    );
  }
}