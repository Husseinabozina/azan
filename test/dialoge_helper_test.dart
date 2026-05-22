import 'package:azan/controllers/cubits/rotation_cubit/rotation_cubit.dart';
import 'package:azan/core/utils/app_virtual_keyboard.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/dialoge_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await CacheHelper.init();
    UiRotationCubit().changeIsLandscape(false);
  });

  testWidgets(
    'showAppDialog keeps the shared shell palette across app themes',
    (tester) async {
      Future<void> pumpAndOpen(ThemeData theme) async {
        await tester.pumpWidget(
          _DialogHarness(
            theme: theme,
            child: Builder(
              builder: (context) {
                return TextButton(
                  onPressed: () {
                    showAppDialog<void>(
                      context: context,
                      builder: (_) {
                        return const UniversalDialogShell(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              DialogTitle('Shared Dialog'),
                              SizedBox(height: 12),
                              DialogBodyText('Body copy'),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: const Text('Open'),
                );
              },
            ),
          ),
        );

        _pressTextButton(tester, 'Open');
        await tester.pumpAndSettle();
      }

      await pumpAndOpen(ThemeData.light());

      final lightSurface = tester.widget<Container>(_dialogSurfaceFinder());
      final lightDecoration = lightSurface.decoration! as BoxDecoration;
      final titleText = tester.widget<Text>(find.text('Shared Dialog'));

      expect(lightDecoration.color, DialogPalette.backgroundColor);
      expect(titleText.style?.color, DialogPalette.titleTextColor);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();

      await pumpAndOpen(
        ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Colors.purple,
          colorScheme: const ColorScheme.dark(
            primary: Colors.teal,
            surface: Colors.black,
          ),
        ),
      );

      final darkSurface = tester.widget<Container>(_dialogSurfaceFinder());
      final darkDecoration = darkSurface.decoration! as BoxDecoration;

      expect(darkDecoration.color, DialogPalette.backgroundColor);
      expect(darkDecoration.color, lightDecoration.color);
    },
  );

  testWidgets(
    'DialogTextField uses the fixed dialog input palette and keyboard shell',
    (tester) async {
      final controller = TextEditingController(text: 'value');

      await tester.pumpWidget(
        _DialogHarness(
          theme: ThemeData.light(),
          child: Scaffold(
            body: DialogTextField(
              controller: controller,
              label: 'Label',
              hint: 'Hint',
            ),
          ),
        ),
      );

      final fieldSurface = tester.widget<Container>(
        _dialogInputSurfaceFinder(),
      );
      final fieldDecoration = fieldSurface.decoration! as BoxDecoration;
      final fieldBorder = fieldDecoration.border! as Border;

      expect(find.text('Label'), findsOneWidget);
      expect(find.text('value'), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_rounded), findsOneWidget);
      expect(fieldDecoration.color, DialogPalette.inputFillColor);
      expect(fieldBorder.top.color, DialogPalette.inputBorderColor);

      await tester.tap(find.text('value'));
      await tester.pumpAndSettle();

      final keyboardShell = tester.widget<Container>(_keyboardShellFinder());
      final keyboardDecoration = keyboardShell.decoration! as BoxDecoration;

      expect(find.byType(AppVirtualKeyboard), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_hide_rounded), findsOneWidget);
      expect(keyboardDecoration.color, Colors.white);
      expect(keyboardDecoration.border?.top.color, const Color(0x66D4A64A));
    },
  );

  testWidgets(
    'AppVirtualKeyboard types, shifts, switches language, and backspaces',
    (tester) async {
      await CacheHelper.setLang('en');
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AppVirtualKeyboard(
                controller: controller,
                height: 260,
                inputMode: AppKeyboardInputMode.text,
                textColor: DialogPalette.inputTextColor,
                backgroundColor: Colors.white,
                borderColor: const Color(0x66D4A64A),
                shadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('app-key-char-a')));
      await tester.pump();
      expect(controller.text, 'a');

      await tester.tap(find.byKey(const ValueKey('app-key-shift')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('app-key-char-a')));
      await tester.pump();
      expect(controller.text, 'aA');

      await tester.tap(find.byKey(const ValueKey('app-key-language')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('app-key-char-ض')));
      await tester.pump();
      expect(controller.text, 'aAض');

      await tester.tap(find.byKey(const ValueKey('app-key-backspace')));
      await tester.pump();
      expect(controller.text, 'aA');
    },
  );

  testWidgets(
    'AppVirtualKeyboard inserts Arabic alternates from long press menu',
    (tester) async {
      await CacheHelper.setLang('ar');
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AppVirtualKeyboard(
                controller: controller,
                height: 260,
                inputMode: AppKeyboardInputMode.text,
                textColor: DialogPalette.inputTextColor,
                backgroundColor: Colors.white,
                borderColor: const Color(0x66D4A64A),
                shadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.longPress(find.byKey(const ValueKey('app-key-char-ا')));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(PopupMenuItem<String>, 'أ'));
      await tester.pumpAndSettle();

      expect(controller.text, 'أ');
    },
  );

  testWidgets('showUniversalTimePicker injects the shared picker palette', (
    tester,
  ) async {
    await tester.pumpWidget(
      _DialogHarness(
        theme: ThemeData.light(),
        size: const Size(1024, 1400),
        child: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () {
                showUniversalTimePicker(
                  context,
                  initialTime: const TimeOfDay(hour: 9, minute: 30),
                );
              },
              child: const Text('Open Time'),
            );
          },
        ),
      ),
    );

    _pressTextButton(tester, 'Open Time');
    await tester.pumpAndSettle();

    final pickerThemes = tester
        .widgetList<Theme>(find.byType(Theme))
        .where(
          (theme) =>
              theme.data.timePickerTheme.backgroundColor ==
              DialogPalette.surfaceColor,
        )
        .toList();

    expect(pickerThemes, isNotEmpty);

    final pickerTheme = pickerThemes.first.data;
    expect(pickerTheme.dialogTheme.backgroundColor, DialogPalette.surfaceColor);
    expect(
      pickerTheme.timePickerTheme.dialBackgroundColor,
      DialogPalette.surfaceRaisedColor,
    );
    expect(
      pickerTheme.colorScheme.primary,
      DialogPalette.primaryButtonBackground,
    );
  });

  testWidgets('showUniversalDatePicker injects the shared picker palette', (
    tester,
  ) async {
    await tester.pumpWidget(
      _DialogHarness(
        theme: ThemeData.dark(),
        size: const Size(1024, 1400),
        child: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () {
                showUniversalDatePicker(
                  context,
                  initialDate: DateTime(2026, 4, 9),
                  firstDate: DateTime(2025, 1, 1),
                  lastDate: DateTime(2027, 12, 31),
                );
              },
              child: const Text('Open Date'),
            );
          },
        ),
      ),
    );

    _pressTextButton(tester, 'Open Date');
    await tester.pumpAndSettle();

    final pickerThemes = tester
        .widgetList<Theme>(find.byType(Theme))
        .where(
          (theme) =>
              theme.data.datePickerTheme.backgroundColor ==
              DialogPalette.surfaceColor,
        )
        .toList();

    expect(pickerThemes, isNotEmpty);

    final pickerTheme = pickerThemes.first.data;
    final actionColor = pickerTheme.textButtonTheme.style?.foregroundColor
        ?.resolve(<WidgetState>{});

    expect(
      pickerTheme.datePickerTheme.headerBackgroundColor,
      DialogPalette.surfaceRaisedColor,
    );
    expect(
      pickerTheme.datePickerTheme.headerForegroundColor,
      DialogPalette.titleTextColor,
    );
    expect(
      pickerTheme.colorScheme.primary,
      DialogPalette.primaryButtonBackground,
    );
    expect(actionColor, DialogPalette.primaryButtonBackground);
  });
}

class _DialogHarness extends StatelessWidget {
  const _DialogHarness({
    required this.theme,
    required this.child,
    this.size = const Size(393, 852),
  });

  final ThemeData theme;
  final Widget child;
  final Size size;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: theme,
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: Scaffold(body: Center(child: child)),
      ),
    );
  }
}

void _pressTextButton(WidgetTester tester, String label) {
  final button = tester.widget<TextButton>(
    find.widgetWithText(TextButton, label).first,
  );
  button.onPressed?.call();
}

Finder _dialogSurfaceFinder() {
  return find.byWidgetPredicate((widget) {
    if (widget is! Container) return false;
    final decoration = widget.decoration;
    return decoration is BoxDecoration &&
        decoration.color == DialogPalette.backgroundColor;
  }, description: 'dialog surface');
}

Finder _dialogInputSurfaceFinder() {
  return find.byWidgetPredicate((widget) {
    if (widget is! Container) return false;
    final decoration = widget.decoration;
    return decoration is BoxDecoration &&
        decoration.color == DialogPalette.inputFillColor &&
        decoration.border is Border &&
        (decoration.border! as Border).top.color ==
            DialogPalette.inputBorderColor;
  }, description: 'dialog input surface');
}

Finder _keyboardShellFinder() {
  return find.byWidgetPredicate((widget) {
    if (widget is! Container) return false;
    final decoration = widget.decoration;
    return decoration is BoxDecoration &&
        decoration.color == Colors.white &&
        decoration.border is Border &&
        (decoration.border! as Border).top.color == const Color(0x66D4A64A);
  }, description: 'keyboard shell');
}
