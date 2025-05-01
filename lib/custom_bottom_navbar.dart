import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'main.dart'; // Import HomePage
import 'chatbot_page.dart'; // Import FishPage
import 'settings_page.dart'; // Import SettingsPage
import 'constants.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: kGreen,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              icon: SvgPicture.asset('assets/icons/ic_home.svg', height: 28, colorFilter: ColorFilter.mode(kBlue, BlendMode.srcIn)),
              onPressed: () {
                // Navigate to HomePage without animation
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => HomePage(),
                    transitionDuration: Duration.zero, // No animation
                    reverseTransitionDuration: Duration.zero, // No animation
                  ),
                );
              },
            ),
            IconButton(
              icon: SvgPicture.asset('assets/icons/ic_fishchatbot.svg', height: 28, colorFilter: ColorFilter.mode(kBlue, BlendMode.srcIn)),
              onPressed: () {
                // Navigate to FishPage without animation
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => ChatbotPage(),
                    transitionDuration: Duration.zero, // No animation
                    reverseTransitionDuration: Duration.zero, // No animation
                  ),
                );
              },
            ),
            IconButton(
              icon: SvgPicture.asset('assets/icons/ic_profile.svg', height: 28, colorFilter: ColorFilter.mode(kBlue, BlendMode.srcIn)),
              onPressed: () {
                // Navigate to SettingsPage without animation
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => SettingsPage(),
                    transitionDuration: Duration.zero, // No animation
                    reverseTransitionDuration: Duration.zero, // No animation
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}