import 'package:flutter/foundation.dart';

class FeedRefreshNotifier extends ChangeNotifier {
  void refreshFollowing() {
    notifyListeners();
  }
}