import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/constants.dart';
import 'package:azan/core/utils/mqscale.dart';
import 'package:azan/generated/codegen_loader.g.dart';
import 'package:azan/views/prayer_calendar/hijri_prayer_calendar_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await _loadTestFonts();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await EasyLocalization.ensureInitialized();
    await CacheHelper.init();
    await CacheHelper.setLang('en');
    await CacheHelper.setTextsFontFamily(amiriFont);
    await CacheHelper.setTimesFontFamily(freeSerifBoldFont);
  });

  testWidgets(
    'compact month panel keeps current month visible and updates after selection',
    (tester) async {
      const size = Size(430, 932);
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildHarness(size: size));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('calendar-compact-navigation-panel')),
        findsOneWidget,
      );
      expect(find.text('Hijri months'), findsOneWidget);
      expect(find.text('Current month'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('compact-month-2')));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byKey(const ValueKey('calendar-current-month-badge')),
          matching: find.text('Safar'),
        ),
        findsOneWidget,
      );
    },
  );
}

Future<void> _loadTestFonts() async {
  final amiri = FontLoader('Amiri')
    ..addFont(rootBundle.load('assets/fonts/AmiriRegular.ttf'))
    ..addFont(rootBundle.load('assets/fonts/AmiriBold.ttf'));
  final freeSerifBold = FontLoader('FreeSerifBold')
    ..addFont(rootBundle.load('assets/fonts/FreeSerifBold.ttf'));

  await Future.wait([amiri.load(), freeSerifBold.load()]);
}

Widget _buildHarness({Size size = const Size(430, 932)}) {
  return EasyLocalization(
    supportedLocales: const [Locale('en'), Locale('ar'), Locale('bn')],
    path: 'assets/Lang',
    assetLoader: const CodegenLoader(),
    startLocale: const Locale('en'),
    fallbackLocale: const Locale('en'),
    child: Builder(
      builder: (context) {
        return MaterialApp(
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          home: MediaQuery(
            data: MediaQueryData(size: size),
            child: MQScaleInit(
              designSize: size,
              minTextAdapt: true,
              child: Scaffold(
                body: Center(
                  child: SizedBox(
                    width: 398,
                    child: Material(
                      color: Colors.transparent,
                      child: const _CompactPanelHarness(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
  );
}

class _CompactPanelHarness extends StatefulWidget {
  const _CompactPanelHarness();

  @override
  State<_CompactPanelHarness> createState() => _CompactPanelHarnessState();
}

class _CompactPanelHarnessState extends State<_CompactPanelHarness> {
  static const Map<int, String> _monthLabels = <int, String>{
    1: 'Muharram',
    2: 'Safar',
    3: 'Rabi I',
    4: 'Rabi II',
    5: 'Jumada I',
    6: 'Jumada II',
  };

  final ScrollController _monthsScrollController = ScrollController();
  int _selectedMonth = 1;

  @override
  void dispose() {
    _monthsScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final months = _monthLabels.keys.toList(growable: false);
    final selectedIndex = months.indexOf(_selectedMonth);

    return HijriCalendarCompactNavigationPanel(
      monthsTitle: 'Hijri months',
      currentMonthTitle: 'Current month',
      monthOrder: months,
      selectedMonth: _selectedMonth,
      monthLabelBuilder: (month) => _monthLabels[month] ?? '',
      monthsScrollController: _monthsScrollController,
      monthChipKeyBuilder: (month) => ValueKey('compact-month-$month'),
      onMonthSelected: (month) => setState(() => _selectedMonth = month),
      selectedMonthLabel: _monthLabels[_selectedMonth] ?? '',
      onLeftArrowTap: selectedIndex < months.length - 1
          ? () => setState(() => _selectedMonth = months[selectedIndex + 1])
          : null,
      onRightArrowTap: selectedIndex > 0
          ? () => setState(() => _selectedMonth = months[selectedIndex - 1])
          : null,
    );
  }
}
