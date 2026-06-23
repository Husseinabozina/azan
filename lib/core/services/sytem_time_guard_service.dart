import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum DeviceTimeChangeType {
  timeChanged,
  dateChanged,
  timezoneChanged,
  significantTimeChange, // iOS
  unknown,
}

class DeviceTimeChangeEvent {
  final DeviceTimeChangeType type;
  final Map<String, dynamic> raw;

  const DeviceTimeChangeEvent({required this.type, required this.raw});

  @override
  String toString() => 'DeviceTimeChangeEvent(type: $type, raw: $raw)';
}

class SystemTimeGuardService {
  static const EventChannel _channel = EventChannel('system_time_guard/events');

  final Future<void> Function(DeviceTimeChangeEvent event) onDeviceTimeChanged;
  final void Function(Object error, StackTrace stackTrace)? onError;

  StreamSubscription? _sub;
  bool _isStarted = false;

  SystemTimeGuardService({required this.onDeviceTimeChanged, this.onError});

  bool get isStarted => _isStarted;

  void startListening() {
    if (_isStarted) return;
    _isStarted = true;

    _sub = _channel.receiveBroadcastStream().listen(
      (dynamic event) async {
        try {
          final map = (event is Map)
              ? Map<String, dynamic>.from(event as Map)
              : <String, dynamic>{'type': 'unknown'};

          final typeString = map['type']?.toString() ?? 'unknown';
          final parsedType = _parseType(typeString);

          await onDeviceTimeChanged(
            DeviceTimeChangeEvent(type: parsedType, raw: map),
          );
        } catch (e, st) {
          debugPrint('SystemTimeGuardService handler error: $e');
          onError?.call(e, st);
        }
      },
      onError: (Object e, StackTrace st) {
        debugPrint('SystemTimeGuardService stream error: $e');
        onError?.call(e, st);
      },
      cancelOnError: false,
    );
  }

  Future<void> stopListening() async {
    _isStarted = false;
    await _sub?.cancel();
    _sub = null;
  }

  DeviceTimeChangeType _parseType(String value) {
    switch (value) {
      case 'time_changed':
        return DeviceTimeChangeType.timeChanged;
      case 'date_changed':
        return DeviceTimeChangeType.dateChanged;
      case 'timezone_changed':
        return DeviceTimeChangeType.timezoneChanged;
      case 'significant_time_change':
        return DeviceTimeChangeType.significantTimeChange;
      default:
        return DeviceTimeChangeType.unknown;
    }
  }
}
