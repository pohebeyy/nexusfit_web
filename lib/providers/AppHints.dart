// import 'package:shared_preferences/shared_preferences.dart';






// class AppHints {
//   static const _keyHomeHintShown = 'hint_home_shown';
//   static const _keyProfileHintShown = 'hint_profile_shown';
//   static const _keyChatHintShown = 'hint_chat_shown';

//   static Future<bool> isHomeHintShown() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getBool(_keyHomeHintShown) ?? false;
//   }

//   static Future<void> markHomeHintShown() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool(_keyHomeHintShown, true);
//   }

//   static Future<bool> isProfileHintShown() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getBool(_keyProfileHintShown) ?? false;
//   }

//   static Future<void> markProfileHintShown() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool(_keyProfileHintShown, true);
//   }

//   static Future<bool> isChatHintShown() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getBool(_keyChatHintShown) ?? false;
//   }

//   static Future<void> markChatHintShown() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool(_keyChatHintShown, true);
//   }
// }