class AppState {}

class UiRotationChanged extends AppState {
  final int quarterTurns;
  UiRotationChanged(this.quarterTurns);
}

class AppInitial extends AppState {}

class AppChanged extends AppState {}

class FetchPrayerTimesFailure extends AppState {
  String message;
  FetchPrayerTimesFailure(this.message);
}

class FetchPrayerTimesSuccess extends AppState {
  FetchPrayerTimesSuccess();
}

class FetchPrayerTimesLoading extends AppState {}

class saveIqamaTimesLoading extends AppState {}

class saveIqamaTimesSuccess extends AppState {}

class saveIqamaTimesFailure extends AppState {}

class savePrayerDurationLoading extends AppState {}

class savePrayerDurationSuccess extends AppState {}

class savePrayerDurationFailure extends AppState {}
