import 'dart:async';

import 'package:azan/core/models/azkar_type.dart';
import 'package:azan/views/home/components/azkar_content.dart';
import 'package:azan/views/home/components/azkar_presentation_view.dart';
import 'package:flutter/material.dart';

class AzkarView extends StatefulWidget {
  const AzkarView({super.key, required this.azkarType, this.prayerId});

  final AzkarType azkarType;
  final int? prayerId;

  @override
  State<AzkarView> createState() => _AzkarViewState();
}

class _AzkarViewState extends State<AzkarView> {
  Timer? _timer;
  int _loadVersion = 0;
  final AzkarSequentialCursor _cursor = AzkarSequentialCursor();

  late ResolvedAzkarSet _resolvedSet;
  int? _currentIndex;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _resolvedSet = emptyAzkarSet(widget.azkarType, prayerId: widget.prayerId);
    unawaited(_reloadResolvedSet());
  }

  @override
  void didUpdateWidget(covariant AzkarView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.azkarType != widget.azkarType ||
        oldWidget.prayerId != widget.prayerId) {
      _timer?.cancel();
      _resolvedSet = emptyAzkarSet(widget.azkarType, prayerId: widget.prayerId);
      unawaited(_reloadResolvedSet());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _reloadResolvedSet() async {
    final loadVersion = ++_loadVersion;
    _timer?.cancel();
    _cursor.reset();
    _currentIndex = null;
    _isLoading = true;
    if (mounted) {
      setState(() {});
    }

    final resolved = await loadAzkarSet(
      widget.azkarType,
      prayerId: widget.prayerId,
    );

    if (!mounted || loadVersion != _loadVersion) return;
    _resolvedSet = resolved;
    _currentIndex = null;
    _isLoading = false;
    _pickNextAndSchedule(first: true);
  }

  void _pickNextAndSchedule({bool first = false}) {
    if (_resolvedSet.entries.isEmpty) {
      _timer?.cancel();
      setState(() => _currentIndex = null);
      return;
    }

    final nextIndex = _pickNextSequentialIndex();
    if (first) {
      _currentIndex = nextIndex;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {});
      });
    } else {
      setState(() => _currentIndex = nextIndex);
    }

    _timer?.cancel();
    _timer = Timer(_durationForText(_resolvedSet.entries[nextIndex].text), () {
      if (!mounted) return;
      _pickNextAndSchedule();
    });
  }

  int _pickNextSequentialIndex() {
    return _cursor.nextIndex(_resolvedSet.entries.length);
  }

  Duration _durationForText(String text) {
    const minSeconds = 20;
    const maxSeconds = 75;

    final words = text
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .length;
    final readSeconds = (words / 3.0).ceil();
    final bonus = (text.length / 120).floor() * 4;
    return Duration(
      seconds: (readSeconds + bonus).clamp(minSeconds, maxSeconds),
    );
  }

  @override
  Widget build(BuildContext context) {
    final entry = _currentIndex == null
        ? null
        : _resolvedSet.entries[_currentIndex!];

    return AzkarPresentationView(
      resolvedSet: _resolvedSet,
      entry: entry,
      entryIndex: _currentIndex,
      totalEntries: _resolvedSet.entries.length,
      emptyMessage: _isLoading ? 'جاري تحميل الأذكار...' : 'لا توجد أذكار',
    );
  }
}

class AzkarSequentialCursor {
  int _nextIndex = 0;

  void reset() {
    _nextIndex = 0;
  }

  int nextIndex(int totalEntries) {
    if (totalEntries <= 0) {
      throw ArgumentError.value(totalEntries, 'totalEntries');
    }

    final index = _nextIndex % totalEntries;
    _nextIndex = (_nextIndex + 1) % totalEntries;
    return index;
  }
}
