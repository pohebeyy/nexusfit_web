import 'package:flutter/material.dart';
import 'package:startap/screens/profile/profile.dart';


class ProfileEntry {
  static Future<void> open(BuildContext context, {required bool fullscreen}) async {
    if (fullscreen) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => const ProfileScreen(),
        ),
      );
      return;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) {
        return const FractionallySizedBox(
          heightFactor: 0.92,
          child: ProfileScreen(),
        );
      },
    );
  }
}
