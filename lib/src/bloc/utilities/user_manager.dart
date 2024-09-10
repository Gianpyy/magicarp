import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// A simple manager to handle UserID
///
/// This class ensures that each user has a unique UserID by generating
/// a UUID the first time it's needed. The UserID is then stored locally
/// using SharedPreferences to persist it across app sessions.
/// The class follows the singleton pattern to ensure consistency
/// so that only one instance is used throughout the app.
class UserManager {
  // Singleton instance of the class
  static final UserManager _instance = UserManager._internal();

  // Key used to store the UserID in SharedPreferences
  static const String _userIdKey = "user_id";

  // Private constructor for the singleton
  UserManager._internal();

  // Factory constructor to return the same instance of UserManager
  factory UserManager() {
    return _instance;
  }

  // Method to get or generate the UserID
  Future<String> getUserId() async {
    // Access shared preferences and retrieve the UserID, if it exists
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString(_userIdKey);

    // If no UserID exists, generate a new one and save it
    if (userId == null) {
      var uuid = const Uuid();
      userId = uuid.v4();
      await prefs.setString(_userIdKey, userId);
    }

    return userId;
  }
}
