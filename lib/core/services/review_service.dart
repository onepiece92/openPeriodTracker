import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Asks for a store rating once the user has real history with the app.
///
/// The prompt is only requested when at least [minCycles] completed cycles
/// are logged and the app has been opened on at least [minOpenDays] distinct
/// days, and never more than once every [cooldownDays]. Apple and Google
/// additionally throttle the dialog on their side, so a request is not a
/// guarantee that it appears.
class ReviewService {
  static const minCycles = 3;
  static const minOpenDays = 5;
  static const cooldownDays = 120;

  static const _kOpenDays = 'review_open_days';
  static const _kLastOpen = 'review_last_open';
  static const _kLastAsk = 'review_last_ask';

  Future<void> maybeRequest({required int completedCycles}) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);

    var openDays = prefs.getInt(_kOpenDays) ?? 0;
    if (prefs.getString(_kLastOpen) != today) {
      openDays += 1;
      await prefs.setInt(_kOpenDays, openDays);
      await prefs.setString(_kLastOpen, today);
    }

    if (completedCycles < minCycles || openDays < minOpenDays) return;

    final lastAsk = prefs.getString(_kLastAsk);
    if (lastAsk != null) {
      final since = DateTime.now().difference(DateTime.parse(lastAsk)).inDays;
      if (since < cooldownDays) return;
    }

    final review = InAppReview.instance;
    if (!await review.isAvailable()) return;
    await prefs.setString(_kLastAsk, DateTime.now().toIso8601String());
    await review.requestReview();
  }
}
