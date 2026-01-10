enum AdhanType { adhan, iqamaa }

class NextAdhan {
  final String title;
  DateTime? time;
  final AdhanType adhanType;
  NextAdhan({required this.title, this.time, required this.adhanType});
}
