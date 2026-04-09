import 'dart:async';

import 'package:azan/controllers/cubits/appcubit/app_cubit.dart';
import 'package:azan/controllers/cubits/appcubit/app_state.dart';
import 'package:azan/core/components/flash_dialoge.dart';
import 'package:azan/core/components/global_copyright_footer.dart';
import 'package:azan/core/helpers/date_helper.dart';
import 'package:azan/core/helpers/display_board_hive_helper.dart';
import 'package:azan/core/helpers/display_board_schedule_helper.dart';
import 'package:azan/core/helpers/localizationHelper.dart';
import 'package:azan/core/helpers/simple_sound_player.dart';
import 'package:azan/core/models/display_announcement.dart';
import 'package:azan/core/models/home_display_mode.dart';
import 'package:azan/core/models/next_Iqama.dart';
import 'package:azan/core/router/app_navigation.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/mqscale.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:azan/views/home/azan_prayer_screen.dart';
import 'package:azan/views/home/home_screen.dart';
import 'package:azan/views/home/components/black_screen_info_overlay.dart';
import 'package:azan/views/home/components/cusotm_drawer.dart';
import 'package:azan/views/home/components/home_appbar.dart';
import 'package:azan/views/home/components/iqama_last_minute_countdown_overlay.dart';
import 'package:azan/views/display_board/components/display_board_prayer_rows.dart';
import 'package:azan/views/display_board/components/display_board_runtime_widgets.dart';
import 'package:azan/views/home/components/prayer_row_data.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:azan/core/models/prayer.dart' as prayer_model;

abstract class DisplayBoardRuntimeBase<T extends StatefulWidget>
    extends State<T> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  AppCubit get cubit => AppCubit();
  final SimpleSoundPlayer _soundPlayer = SimpleSoundPlayer();
  final Set<int> _playedAdhanToday = <int>{};
  final Set<int> _playedIqamaToday = <int>{};

  Timer? _tickTimer;
  Timer? _minuteTimer;
  Timer? _announcementTimer;

  Future<bool> _hideFuture = Future.value(false);
  Future<prayer_model.Prayer?> _nextPrayerFuture = Future.value(null);
  bool isLoading = false;
  int _announcementFrame = 0;
  late DateTime _lastDate;
  bool _isRoutingByDisplayMode = false;
  bool _hasSeenScheduledAnnouncements = false;

  bool get isLandscapeBoard;

  bool get _includeUnscheduledAnnouncements =>
      CacheHelper.getHomeDisplayMode() == HomeDisplayMode.displayBoard;

  List<DisplayAnnouncement> _runtimeAnnouncements([DateTime? now]) {
    final instant = now ?? DateTime.now();
    return DisplayBoardScheduleResolver.resolveVisibleAnnouncements(
      cubit.displayAnnouncementList ?? const [],
      instant,
      includeUnscheduled: _includeUnscheduledAnnouncements,
    );
  }

  DisplayAnnouncement? get currentAnnouncement =>
      resolveDisplayAnnouncementForFrame(_runtimeAnnouncements(), _announcementFrame);

  Future<prayer_model.Prayer?> get nextPrayerFuture => _nextPrayerFuture;

  Widget buildBoardLayout(
    BuildContext context, {
    required List<DisplayAnnouncement> announcements,
    required DisplayAnnouncement? currentAnnouncement,
    required List<PrayerRowData> rows,
  });

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isSameMinute(DateTime a, DateTime b) =>
      a.year == b.year &&
      a.month == b.month &&
      a.day == b.day &&
      a.hour == b.hour &&
      a.minute == b.minute;

  void _syncHomeBlackScreenFlag(bool visible) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      cubit.setHomeBlackScreenVisible(visible);
    });
  }

  void _syncDisplayBoardMode(DateTime now) {
    if (_isRoutingByDisplayMode || !mounted) return;

    final items = cubit.displayAnnouncementList ?? const <DisplayAnnouncement>[];
    final hasScheduledNow =
        DisplayBoardScheduleResolver.hasScheduledAnnouncementsDue(items, now);
    if (hasScheduledNow) {
      _hasSeenScheduledAnnouncements = true;
    }

    if (_hasSeenScheduledAnnouncements && !hasScheduledNow) {
      _isRoutingByDisplayMode = true;
      unawaited(() async {
        await DisplayBoardScheduleResolver.switchBackToHomeMode(
          items: items,
          now: now,
          dismissCurrentScheduled: false,
        );
        if (!mounted) return;
        AppNavigator.pushAndRemoveUntil(context, const HomeScreen());
      }());
      return;
    }

    final effectiveMode = DisplayBoardScheduleResolver.effectiveDisplayMode(
      manualMode: CacheHelper.getHomeDisplayMode(),
      items: items,
      now: now,
    );
    if (effectiveMode == HomeDisplayMode.displayBoard) return;

    _isRoutingByDisplayMode = true;
    AppNavigator.pushAndRemoveUntil(context, const HomeScreen());
  }

  Future<void> _refreshMinuteFutures() async {
    _hideFuture = isAfterFixedTimeForIshaaOrSunrise(context: context);
    _nextPrayerFuture = cubit.nextPrayer(context).then((p) {
      cubit.nextPrayerVar = p;
      return p;
    });
  }

  Future<void> _handleHijriTap() async {
    await CacheHelper.stepHijriOffsetCycle();
    if (!mounted) return;
    await cubit.getTodayHijriDate(context);
    if (!mounted) return;
    setState(() {});
  }

  @protected
  Future<void> handleHijriTap() => _handleHijriTap();

  void _restartAnnouncementRotation() {
    _announcementTimer?.cancel();
    _announcementFrame = 0;

    final seconds = CacheHelper.getDisplayBoardRotationSeconds();
    _announcementTimer = Timer.periodic(Duration(seconds: seconds), (_) {
      if (!mounted) return;
      setState(() {
        _announcementFrame++;
      });
    });
  }

  void _onNewDay() {
    _playedAdhanToday.clear();
    _playedIqamaToday.clear();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      _initDayData();
    });
  }

  void _initDayData() {
    final city = cubit.getCity()?.nameEn ?? '';
    unawaited(cubit.getTodayHijriDate(context));
    unawaited(cubit.initializePrayerTimes(city: city, context: context));
    unawaited(cubit.getIqamaTime());
    unawaited(cubit.assignDisplayAnnouncements());
    unawaited(_refreshMinuteFutures());
  }

  void _startTimers() {
    _tickTimer?.cancel();
    _minuteTimer?.cancel();

    _refreshMinuteFutures();
    _restartAnnouncementRotation();

    _tickTimer = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (!mounted) {
        t.cancel();
        return;
      }

      final now = DateTime.now();
      _syncDisplayBoardMode(now);
      _checkAndPlayPrayerSound(now);
      performAdhanActions(context);

      final remainingToIqama = cubit.remainingToIqama();
      if (cubit.isBetweenAdhanAndIqama &&
          !cubit.startAzanAtIqamaPhase &&
          remainingToIqama != null &&
          remainingToIqama <= Duration.zero) {
        cubit.isBetweenAdhanAndIqama = false;
        cubit.startAzanAtIqamaPhase = true;
        cubit.showPrayerAzanPage = true;
      }

      if (!_isSameDay(now, _lastDate)) {
        _lastDate = now;
        _onNewDay();
      }

      setState(() {});
    });

    _minuteTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (!mounted) return;
      await _refreshMinuteFutures();
      setState(() {});
    });
  }

  Future<void> homeScreenWork() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    _lastDate = DateTime.now();
    final city = cubit.getCity()?.nameEn ?? '';
    if (!mounted) return;
    await cubit.getTodayHijriDate(context);
    if (!mounted) return;
    await Future.wait([
      cubit.getIqamaTime(),
      cubit.initializePrayerTimes(city: city, context: context),
      cubit.assignDisplayAnnouncements(),
    ]);
    _hasSeenScheduledAnnouncements =
        DisplayBoardScheduleResolver.hasScheduledAnnouncementsDue(
          cubit.displayAnnouncementList ?? const <DisplayAnnouncement>[],
          DateTime.now(),
        );

    if (!mounted) return;
    setState(() => isLoading = false);
    _syncDisplayBoardMode(DateTime.now());
    _startTimers();
  }

  void performAdhanActions(BuildContext context) {
    if (cubit.prayerTimes == null) return;

    final azanSource = cubit.getAzanSoundSource;
    final prayers = cubit.prayers(context);
    for (final prayer in prayers) {
      final adhanTime = prayer.dateTime;
      if (adhanTime == null) continue;

      if (_isSameMinute(adhanTime, DateTime.now())) {
        final id = prayer.id;
        int iqamaOffsetMinutes = 10;
        final iqamaMinutes = cubit.iqamaMinutes;
        if (iqamaMinutes != null && id > 0 && id <= iqamaMinutes.length) {
          iqamaOffsetMinutes = iqamaMinutes[id - 1];
        }
        final iqamaTime = adhanTime.add(Duration(minutes: iqamaOffsetMinutes));

        if (!_playedAdhanToday.contains(id) && azanSource.isNotEmpty) {
          _playedAdhanToday.add(id);
          unawaited(
            _soundPlayer.playAsset(azanSource).then((success) {
              if (!success) {
                _playedAdhanToday.remove(id);
              }
            }),
          );
        }

        setState(() {
          CacheHelper.setCurrentPrayerKey(prayer.title);
          cubit.startAdhanCycle(
            prayer: prayer,
            adhanTime: adhanTime,
            iqamaTime: iqamaTime,
          );
          cubit.showPrayerAzanPage = true;
        });
      }
    }
  }

  void _checkAndPlayPrayerSound(DateTime now) {
    if (cubit.prayerTimes == null || cubit.iqamaMinutes == null) return;

    final prayers = cubit.prayers(context);
    final iqamaMinutes = cubit.iqamaMinutes!;
    final iqamaSource = cubit.getIqamaSoundSource;
    if (iqamaSource.isEmpty) return;

    for (final prayer in prayers) {
      final id = prayer.id;
      final adhanTime = prayer.dateTime;
      if (adhanTime == null) continue;

      if (iqamaMinutes.length >= id) {
        final iqamaTime = adhanTime.add(
          Duration(minutes: iqamaMinutes[id - 1]),
        );
        final nextVarTime = cubit.nextPrayerVar?.dateTime;
        final currentTime = cubit.currentPrayer?.dateTime;

        if (currentTime != null &&
            nextVarTime != null &&
            iqamaTime.isBefore(nextVarTime) &&
            iqamaTime.isAfter(currentTime)) {
          cubit.nextAdhan = NextAdhan(
            title: cubit.nextPrayerVar!.title,
            adhanType: AdhanType.iqamaa,
          );
        } else {
          cubit.nextAdhan = NextAdhan(
            title: cubit.nextPrayerVar?.title ?? '',
            adhanType: AdhanType.adhan,
          );
        }

        if (!_playedIqamaToday.contains(id) && _isSameMinute(iqamaTime, now)) {
          _playedIqamaToday.add(id);
          unawaited(
            _soundPlayer.playAsset(iqamaSource).then((success) {
              if (!success) {
                _playedIqamaToday.remove(id);
              }
            }),
          );
        }
      }
    }
  }

  Future<bool> isAfterFixedTimeForIshaaOrSunrise({
    required BuildContext context,
    Duration stopBeforeNextPrayerBy = const Duration(hours: 2),
  }) async {
    if (cubit.currentPrayer == null) return false;

    final prayer = cubit.currentPrayer;
    final prayerTime = prayer?.dateTime;
    if (prayer == null || prayerTime == null) return false;

    const ishaaId = 6;
    const sunriseId = 2;

    final int offsetMinutes;
    if (prayer.id == ishaaId) {
      offsetMinutes = CacheHelper.getHideScreenAfterIshaaMinutes();
    } else if (prayer.id == sunriseId) {
      offsetMinutes = CacheHelper.getHideScreenAfterSunriseMinutes();
    } else {
      return false;
    }

    final now = DateTime.now();
    final start = prayerTime.add(Duration(minutes: offsetMinutes));
    if (now.isBefore(start)) return false;

    final next = await cubit.nextPrayer(context);
    final nextTime = next?.dateTime;
    if (nextTime == null) return true;

    final end = nextTime.subtract(stopBeforeNextPrayerBy);
    if (!end.isAfter(start)) return false;

    return now.isBefore(end);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      homeScreenWork();
    });
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    _minuteTimer?.cancel();
    _announcementTimer?.cancel();
    _soundPlayer.dispose();
    cubit.setHomeBlackScreenVisible(false);
    super.dispose();
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        SizedBox(
          child: HomeAppBar(
            onDrawerTap: () => scaffoldKey.currentState?.openDrawer(),
            titleFontSize: isLandscapeBoard ? 20.sp : 18.sp,
          ),
        ),
        const Spacer(),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppTheme.primaryTextColor),
            SizedBox(height: 10.h),
            Text(
              LocaleKeys.loading.tr(),
              style: TextStyle(
                fontFamily: CacheHelper.getTextsFontFamily(),
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: AppTheme.secondaryTextColor,
              ),
            ),
          ],
        ),
        const Spacer(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final noShadowTheme = Theme.of(context).copyWith(
      textTheme: AppTheme.withoutTextShadow(Theme.of(context).textTheme),
      primaryTextTheme: AppTheme.withoutTextShadow(
        Theme.of(context).primaryTextTheme,
      ),
    );

    final pastIqamaFlags = computePastIqamaFlags(context, cubit);
    final rows = buildDisplayBoardPrayerRows(context, cubit, pastIqamaFlags);

    return Theme(
      data: noShadowTheme,
      child: Scaffold(
        extendBody: true,
        bottomNavigationBar: const GlobalCopyrightFooter(),
        key: scaffoldKey,
        drawer: CustomDrawer(context: context),
        body: BlocConsumer<AppCubit, AppState>(
          listener: (context, state) {
            if (state is FetchPrayerTimesFailure) {
              showFlashMessage(
                message: state.message,
                type: FlashMessageType.error,
                context: context,
              );
            }
          },
          builder: (context, state) {
            final selectedBackground = CacheHelper.getSelectedBackground();
            final announcements = _runtimeAnnouncements();

            return Stack(
              children: [
                Image.asset(
                  selectedBackground,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.fill,
                ),
                if (AppTheme.backgroundReadabilityOverlayAlpha > 0)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: ColoredBox(
                        color: Colors.black.withValues(
                          alpha: AppTheme.backgroundReadabilityOverlayAlpha,
                        ),
                      ),
                    ),
                  ),
                const Positioned.fill(child: DisplayBoardBackdropOverlay()),
                Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top,
                    bottom: MediaQuery.of(context).padding.bottom,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isLandscapeBoard ? 22.w : 14.w,
                      vertical: isLandscapeBoard ? 10.h : 8.h,
                    ),
                    child: isLoading
                        ? _buildLoadingState()
                        : buildBoardLayout(
                            context,
                            announcements: announcements,
                            currentAnnouncement: currentAnnouncement,
                            rows: rows,
                          ),
                  ),
                ),
                FutureBuilder<bool>(
                  future: _hideFuture,
                  builder: (context, snapshot) {
                    final currentPrayerId = cubit.currentPrayer?.id;
                    final hideAfterCurrentPrayerEnabled = currentPrayerId == 6
                        ? CacheHelper.getHideScreenAfterIshaaEnabled()
                        : currentPrayerId == 2
                        ? CacheHelper.getHideScreenAfterSunriseEnabled()
                        : false;
                    final shouldHide =
                        hideAfterCurrentPrayerEnabled &&
                        (snapshot.data == true);

                    final azanActive =
                        CacheHelper.getShowAzanScreen() &&
                        (cubit.currentPrayer != null &&
                            cubit.currentPrayer!.id != 2 &&
                            cubit.showPrayerAzanPage);
                    final remainingToIqama = cubit.remainingToIqama();
                    final showLastMinuteCountdown =
                        CacheHelper.getShowIqamaCountdownLastMinuteOnly() &&
                        cubit.isBetweenAdhanAndIqama &&
                        remainingToIqama != null &&
                        remainingToIqama > Duration.zero &&
                        remainingToIqama <= const Duration(seconds: 60);
                    final hideFooterOnBlack =
                        shouldHide ||
                        showLastMinuteCountdown ||
                        cubit.isAzanBlackScreenVisible;
                    _syncHomeBlackScreenFlag(hideFooterOnBlack);
                    final remainingSeconds = showLastMinuteCountdown
                        ? ((remainingToIqama.inMilliseconds + 999) ~/ 1000)
                              .clamp(1, 60)
                        : 0;
                    final secondsText = showLastMinuteCountdown
                        ? (LocalizationHelper.isArAndArNumberEnable()
                              ? DateHelper.toArabicDigits(
                                  remainingSeconds.toString(),
                                )
                              : remainingSeconds.toString())
                        : '';

                    Widget overlay = const SizedBox.shrink();
                    if (azanActive) {
                      overlay = AzanPrayerScreen(
                        key: const ValueKey('display-board-azan'),
                        currentPrayer: cubit.currentPrayer!,
                      );
                    } else if (showLastMinuteCountdown) {
                      overlay = IqamaLastMinuteCountdownOverlay(
                        secondsText: secondsText,
                        fontSizeOverride: isLandscapeBoard ? 300.sp : 240.sp,
                      );
                    } else if (shouldHide) {
                      overlay = BlackScreenInfoOverlay(
                        key: const ValueKey('display-board-black-screen'),
                      );
                    }

                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 1500),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      transitionBuilder: (child, anim) {
                        final scale = Tween<double>(
                          begin: 0.985,
                          end: 1.0,
                        ).animate(anim);
                        return FadeTransition(
                          opacity: anim,
                          child: ScaleTransition(scale: scale, child: child),
                        );
                      },
                      child: overlay,
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
