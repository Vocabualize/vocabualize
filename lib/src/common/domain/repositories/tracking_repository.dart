abstract interface class TrackingRepository {
  Future<void> trackEvent(String name);
  Future<void> trackPracticeIteration(int practicedCount, int dueCount);
}
