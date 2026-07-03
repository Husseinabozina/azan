import 'dart:async';

import 'package:azan/core/utils/cache_helper.dart';
import 'package:flutter/material.dart';

enum AppKeyboardVisualPreset { androidLike }

enum AppKeyboardLocaleMode { arabic, english }

enum AppKeyboardInputMode { text, numeric }

enum AppKeyboardKeyKind {
  character,
  shift,
  backspace,
  space,
  enter,
  switchLanguage,
  switchSymbols,
}

class AppKeyboardKeySpec {
  const AppKeyboardKeySpec({
    required this.id,
    required this.kind,
    this.label,
    this.value,
    this.icon,
    this.alternateValues = const [],
    this.flex = 10,
    this.isPrimary = false,
    this.isToggled = false,
  });

  final String id;
  final AppKeyboardKeyKind kind;
  final String? label;
  final String? value;
  final IconData? icon;
  final List<String> alternateValues;
  final int flex;
  final bool isPrimary;
  final bool isToggled;
}

class AppKeyboardRowSpec {
  const AppKeyboardRowSpec({required this.keys, this.horizontalInsetRatio = 0});

  final List<AppKeyboardKeySpec> keys;
  final double horizontalInsetRatio;
}

class AppKeyboardLayout {
  const AppKeyboardLayout({required this.rows});

  final List<AppKeyboardRowSpec> rows;
}

class AppVirtualKeyboard extends StatefulWidget {
  const AppVirtualKeyboard({
    super.key,
    required this.controller,
    required this.height,
    required this.inputMode,
    required this.textColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.shadow,
    this.allowNegative = false,
    this.submitsOnEnter = true,
    this.onChanged,
    this.onHideRequested,
    this.visualPreset = AppKeyboardVisualPreset.androidLike,
  });

  final TextEditingController controller;
  final double height;
  final AppKeyboardInputMode inputMode;
  final bool allowNegative;
  final bool submitsOnEnter;
  final Color textColor;
  final Color backgroundColor;
  final Color borderColor;
  final List<BoxShadow> shadow;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onHideRequested;
  final AppKeyboardVisualPreset visualPreset;

  @override
  State<AppVirtualKeyboard> createState() => _AppVirtualKeyboardState();
}

class _AppVirtualKeyboardState extends State<AppVirtualKeyboard> {
  late AppKeyboardLocaleMode _localeMode;
  bool _symbolsVisible = false;
  bool _shiftEnabled = false;
  bool _capsLockEnabled = false;
  DateTime? _lastShiftTapAt;

  bool get _usesUppercase => _shiftEnabled || _capsLockEnabled;

  @override
  void initState() {
    super.initState();
    _localeMode = _resolveInitialLocaleMode();
  }

  AppKeyboardLocaleMode _resolveInitialLocaleMode() {
    final appLang = CacheHelper.getLang().trim().toLowerCase();
    if (appLang == 'ar') {
      return AppKeyboardLocaleMode.arabic;
    }
    if (appLang == 'en') {
      return AppKeyboardLocaleMode.english;
    }

    final deviceLang = WidgetsBinding
        .instance
        .platformDispatcher
        .locale
        .languageCode
        .trim()
        .toLowerCase();
    if (deviceLang == 'ar') {
      return AppKeyboardLocaleMode.arabic;
    }
    return AppKeyboardLocaleMode.english;
  }

  @override
  Widget build(BuildContext context) {
    final palette = _resolvePalette();
    final layout = _resolveLayout();

    return SizedBox(
      height: widget.height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const surfacePadding = 8.0;
          const rowGap = 8.0;
          final availableHeight = constraints.maxHeight - (surfacePadding * 2);
          final totalRowGap =
              (layout.rows.length > 1 ? layout.rows.length - 1 : 0) * rowGap;
          final rowHeight = availableHeight > totalRowGap
              ? (availableHeight - totalRowGap) / layout.rows.length
              : 0.0;

          return DecoratedBox(
            decoration: BoxDecoration(
              color: palette.surfaceColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(surfacePadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var index = 0; index < layout.rows.length; index++) ...[
                    if (index > 0) const SizedBox(height: rowGap),
                    _KeyboardRow(
                      row: layout.rows[index],
                      rowHeight: rowHeight,
                      onKeyPressed: _handleKeyPress,
                      onAlternateSelected: _insertText,
                      palette: palette,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  _KeyboardPalette _resolvePalette() {
    final surfaceColor = widget.backgroundColor;
    final brightness = ThemeData.estimateBrightnessForColor(surfaceColor);
    final isDarkSurface = brightness == Brightness.dark;

    switch (widget.visualPreset) {
      case AppKeyboardVisualPreset.androidLike:
        return _KeyboardPalette(
          surfaceColor: surfaceColor,
          borderColor: widget.borderColor,
          regularKeyColor: isDarkSurface
              ? surfaceColor.withValues(alpha: 0.92)
              : Colors.white,
          actionKeyColor: isDarkSurface
              ? Color.alphaBlend(
                  Colors.white.withValues(alpha: 0.14),
                  surfaceColor,
                )
              : const Color(0xFFD9DEE6),
          primaryActionColor: isDarkSurface
              ? const Color(0xFF4A8EFF)
              : const Color(0xFF1A73E8),
          textColor: widget.textColor,
          subtleTextColor: isDarkSurface
              ? Colors.white.withValues(alpha: 0.68)
              : const Color(0xFF5F6368),
          shadowColor: widget.shadow.isNotEmpty
              ? widget.shadow.first.color
              : (isDarkSurface
                    ? Colors.black.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.08)),
        );
    }
  }

  AppKeyboardLayout _resolveLayout() {
    switch (widget.inputMode) {
      case AppKeyboardInputMode.numeric:
        return _buildNumericLayout();
      case AppKeyboardInputMode.text:
        if (_symbolsVisible) {
          return _buildSymbolsLayout();
        }
        return _localeMode == AppKeyboardLocaleMode.arabic
            ? _buildArabicLayout()
            : _buildEnglishLayout();
    }
  }

  AppKeyboardLayout _buildEnglishLayout() {
    return AppKeyboardLayout(
      rows: [
        AppKeyboardRowSpec(
          keys: [for (final key in '1234567890'.split('')) _characterKey(key)],
        ),
        AppKeyboardRowSpec(
          keys: [
            for (final key in 'qwertyuiop'.split('')) _englishLetterKey(key),
          ],
        ),
        AppKeyboardRowSpec(
          horizontalInsetRatio: 0.035,
          keys: [
            for (final key in 'asdfghjkl'.split('')) _englishLetterKey(key),
          ],
        ),
        AppKeyboardRowSpec(
          horizontalInsetRatio: 0.015,
          keys: [
            _shiftKey(),
            for (final key in 'zxcvbnm'.split('')) _englishLetterKey(key),
            _backspaceKey(),
          ],
        ),
        AppKeyboardRowSpec(
          keys: [
            _switchSymbolsKey(label: '?123'),
            _languageKey(),
            _characterKey(','),
            _spaceKey(),
            _characterKey('.'),
            _enterKey(),
          ],
        ),
      ],
    );
  }

  AppKeyboardLayout _buildArabicLayout() {
    return AppKeyboardLayout(
      rows: [
        AppKeyboardRowSpec(
          keys: [for (final key in '١٢٣٤٥٦٧٨٩٠'.split('')) _characterKey(key)],
        ),
        AppKeyboardRowSpec(
          keys: [for (final key in 'دجحخهعغفقثصض'.split('')) _characterKey(key)],
        ),
        AppKeyboardRowSpec(
          horizontalInsetRatio: 0.03,
          keys: [
            _characterKey('ط'),
            _characterKey('ك'),
            _characterKey('م'),
            _characterKey('ن'),
            _characterKey('ت'),
            _characterKey('ا', alternates: const ['أ', 'إ', 'آ', 'ء']),
            _characterKey('ل'),
            _characterKey('ب'),
            _characterKey('ي', alternates: const ['ى', 'ئ']),
            _characterKey('س'),
            _characterKey('ش'),
          ],
        ),
        AppKeyboardRowSpec(
          horizontalInsetRatio: 0.05,
          keys: [
            _backspaceKey(),
            _characterKey('ظ'),
            _characterKey('ز'),
            _characterKey('و'),
            _characterKey('ة'),
            _characterKey('ى'),
            _characterKey('لا'),
            _characterKey('ر'),
            _characterKey('ؤ'),
            _characterKey('ء'),
            _characterKey('ئ'),
          ],
        ),
        AppKeyboardRowSpec(
          keys: [
            _switchSymbolsKey(label: '؟١٢٣'),
            _languageKey(),
            _characterKey('،'),
            _spaceKey(),
            _characterKey('.'),
            _enterKey(),
          ],
        ),
      ],
    );
  }

  AppKeyboardLayout _buildSymbolsLayout() {
    final isArabic = _localeMode == AppKeyboardLocaleMode.arabic;
    final numberRow = isArabic
        ? '١٢٣٤٥٦٧٨٩٠'.split('')
        : '1234567890'.split('');
    final rowTwo = isArabic
        ? ['@', '#', '٪', '&', '*', '-', '+', '(', ')', '/']
        : ['@', '#', '\$', '&', '*', '-', '+', '(', ')', '/'];
    final rowThree = isArabic
        ? ['"', '\'', ':', '؛', '!', '؟', '،', '.', '_', '=']
        : ['"', '\'', ':', ';', '!', '?', ',', '.', '_', '='];

    return AppKeyboardLayout(
      rows: [
        AppKeyboardRowSpec(
          keys: [for (final key in numberRow) _characterKey(key)],
        ),
        AppKeyboardRowSpec(
          keys: [for (final key in rowTwo) _characterKey(key)],
        ),
        AppKeyboardRowSpec(
          keys: [for (final key in rowThree) _characterKey(key)],
        ),
        AppKeyboardRowSpec(
          horizontalInsetRatio: 0.04,
          keys: [
            _switchSymbolsKey(label: isArabic ? 'أبج' : 'ABC'),
            for (final key in ['[', ']', '{', '}', '\\', '|', '~'])
              _characterKey(key),
            _backspaceKey(),
          ],
        ),
        AppKeyboardRowSpec(
          keys: [
            _languageKey(),
            _characterKey(isArabic ? '،' : ','),
            _spaceKey(),
            _characterKey('.'),
            _enterKey(),
          ],
        ),
      ],
    );
  }

  AppKeyboardLayout _buildNumericLayout() {
    final bottomRowKeys = widget.allowNegative
        ? <AppKeyboardKeySpec>[
            _characterKey('-'),
            _characterKey('0'),
            _characterKey('.'),
            _backspaceKey(),
          ]
        : <AppKeyboardKeySpec>[
            _characterKey('0'),
            _characterKey('.'),
            _backspaceKey(),
          ];

    return AppKeyboardLayout(
      rows: [
        AppKeyboardRowSpec(
          horizontalInsetRatio: 0.16,
          keys: [_characterKey('1'), _characterKey('2'), _characterKey('3')],
        ),
        AppKeyboardRowSpec(
          horizontalInsetRatio: 0.16,
          keys: [_characterKey('4'), _characterKey('5'), _characterKey('6')],
        ),
        AppKeyboardRowSpec(
          horizontalInsetRatio: 0.16,
          keys: [_characterKey('7'), _characterKey('8'), _characterKey('9')],
        ),
        AppKeyboardRowSpec(
          horizontalInsetRatio: widget.allowNegative ? 0.08 : 0.16,
          keys: bottomRowKeys,
        ),
        AppKeyboardRowSpec(
          horizontalInsetRatio: 0.26,
          keys: [_enterKey(label: 'Done')],
        ),
      ],
    );
  }

  AppKeyboardKeySpec _characterKey(
    String value, {
    int flex = 10,
    List<String> alternates = const [],
  }) {
    return AppKeyboardKeySpec(
      id: 'char-$value',
      kind: AppKeyboardKeyKind.character,
      label: value,
      value: value,
      alternateValues: alternates,
      flex: flex,
    );
  }

  AppKeyboardKeySpec _englishLetterKey(String value) {
    final output = _usesUppercase ? value.toUpperCase() : value;
    return AppKeyboardKeySpec(
      id: 'char-$value',
      kind: AppKeyboardKeyKind.character,
      label: output,
      value: output,
    );
  }

  AppKeyboardKeySpec _shiftKey() {
    return AppKeyboardKeySpec(
      id: 'shift',
      kind: AppKeyboardKeyKind.shift,
      icon: _capsLockEnabled
          ? Icons.keyboard_capslock_rounded
          : Icons.arrow_upward_rounded,
      flex: 14,
      isToggled: _usesUppercase,
    );
  }

  AppKeyboardKeySpec _backspaceKey() {
    return const AppKeyboardKeySpec(
      id: 'backspace',
      kind: AppKeyboardKeyKind.backspace,
      icon: Icons.backspace_outlined,
      flex: 14,
    );
  }

  AppKeyboardKeySpec _spaceKey() {
    return AppKeyboardKeySpec(
      id: 'space',
      kind: AppKeyboardKeyKind.space,
      label: _localeMode == AppKeyboardLocaleMode.arabic
          ? 'العربية'
          : 'English',
      flex: 40,
    );
  }

  AppKeyboardKeySpec _enterKey({String? label}) {
    return AppKeyboardKeySpec(
      id: 'enter',
      kind: AppKeyboardKeyKind.enter,
      label: label,
      icon: widget.submitsOnEnter
          ? Icons.check_rounded
          : Icons.keyboard_return_rounded,
      flex: 14,
      isPrimary: true,
    );
  }

  AppKeyboardKeySpec _languageKey() {
    return AppKeyboardKeySpec(
      id: 'language',
      kind: AppKeyboardKeyKind.switchLanguage,
      icon: Icons.language_rounded,
      label: _localeMode == AppKeyboardLocaleMode.arabic ? 'AR' : 'EN',
      flex: 12,
    );
  }

  AppKeyboardKeySpec _switchSymbolsKey({required String label}) {
    return AppKeyboardKeySpec(
      id: 'symbols',
      kind: AppKeyboardKeyKind.switchSymbols,
      label: label,
      flex: 14,
      isToggled: _symbolsVisible,
    );
  }

  void _handleKeyPress(AppKeyboardKeySpec key) {
    switch (key.kind) {
      case AppKeyboardKeyKind.character:
        _insertText(key.value ?? key.label ?? '');
        if (widget.inputMode == AppKeyboardInputMode.text &&
            _localeMode == AppKeyboardLocaleMode.english &&
            !_symbolsVisible &&
            _shiftEnabled &&
            !_capsLockEnabled &&
            _containsAlphabeticCharacter(key.value ?? '')) {
          setState(() => _shiftEnabled = false);
        }
        break;
      case AppKeyboardKeyKind.shift:
        _toggleShift();
        break;
      case AppKeyboardKeyKind.backspace:
        _backspace();
        break;
      case AppKeyboardKeyKind.space:
        _insertText(' ');
        break;
      case AppKeyboardKeyKind.enter:
        if (widget.submitsOnEnter) {
          widget.onHideRequested?.call();
        } else {
          _insertText('\n');
        }
        break;
      case AppKeyboardKeyKind.switchLanguage:
        setState(() {
          _localeMode = _localeMode == AppKeyboardLocaleMode.arabic
              ? AppKeyboardLocaleMode.english
              : AppKeyboardLocaleMode.arabic;
          _symbolsVisible = false;
          _shiftEnabled = false;
          _capsLockEnabled = false;
          _lastShiftTapAt = null;
        });
        break;
      case AppKeyboardKeyKind.switchSymbols:
        setState(() {
          _symbolsVisible = !_symbolsVisible;
          _shiftEnabled = false;
          _capsLockEnabled = false;
          _lastShiftTapAt = null;
        });
        break;
    }
  }

  void _toggleShift() {
    if (widget.inputMode != AppKeyboardInputMode.text ||
        _localeMode != AppKeyboardLocaleMode.english ||
        _symbolsVisible) {
      return;
    }

    final now = DateTime.now();
    final isDoubleTap =
        _lastShiftTapAt != null &&
        now.difference(_lastShiftTapAt!) <= const Duration(milliseconds: 350);

    setState(() {
      if (_capsLockEnabled) {
        _capsLockEnabled = false;
        _shiftEnabled = false;
      } else if (isDoubleTap) {
        _capsLockEnabled = true;
        _shiftEnabled = true;
      } else {
        _shiftEnabled = !_shiftEnabled;
      }
      _lastShiftTapAt = now;
    });
  }

  void _insertText(String insertedText) {
    if (insertedText.isEmpty) {
      return;
    }

    final currentText = widget.controller.text;
    final selection = _resolvedSelection(currentText);
    final newText = currentText.replaceRange(
      selection.start,
      selection.end,
      insertedText,
    );
    final newOffset = selection.start + insertedText.length;

    widget.controller.value = widget.controller.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newOffset),
      composing: TextRange.empty,
    );
    widget.onChanged?.call(newText);
  }

  void _backspace() {
    final currentText = widget.controller.text;
    final selection = _resolvedSelection(currentText);
    final selectionLength = selection.end - selection.start;

    if (selectionLength > 0) {
      final newText = currentText.replaceRange(
        selection.start,
        selection.end,
        '',
      );
      widget.controller.value = widget.controller.value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start),
        composing: TextRange.empty,
      );
      widget.onChanged?.call(newText);
      return;
    }

    if (selection.start == 0) {
      return;
    }

    final previousCodeUnit = currentText.codeUnitAt(selection.start - 1);
    final removedLength = _isUtf16Surrogate(previousCodeUnit) ? 2 : 1;
    final newStart = selection.start - removedLength;
    final newText = currentText.replaceRange(newStart, selection.start, '');

    widget.controller.value = widget.controller.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newStart),
      composing: TextRange.empty,
    );
    widget.onChanged?.call(newText);
  }

  TextSelection _resolvedSelection(String text) {
    final selection = widget.controller.selection;
    if (!selection.isValid ||
        selection.start < 0 ||
        selection.end < 0 ||
        selection.start > text.length ||
        selection.end > text.length) {
      return TextSelection.collapsed(offset: text.length);
    }
    return selection;
  }

  bool _containsAlphabeticCharacter(String value) {
    return RegExp(r'[A-Za-z]').hasMatch(value);
  }

  bool _isUtf16Surrogate(int value) {
    return value & 0xF800 == 0xD800;
  }
}

class _KeyboardRow extends StatelessWidget {
  const _KeyboardRow({
    required this.row,
    required this.rowHeight,
    required this.onKeyPressed,
    required this.onAlternateSelected,
    required this.palette,
  });

  final AppKeyboardRowSpec row;
  final double rowHeight;
  final ValueChanged<AppKeyboardKeySpec> onKeyPressed;
  final ValueChanged<String> onAlternateSelected;
  final _KeyboardPalette palette;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalInset = constraints.maxWidth * row.horizontalInsetRatio;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalInset),
          child: SizedBox(
            height: rowHeight,
            child: Row(
              children: [
                for (var index = 0; index < row.keys.length; index++) ...[
                  if (index > 0) const SizedBox(width: 6),
                  Expanded(
                    flex: row.keys[index].flex,
                    child: _KeyboardKeyButton(
                      keySpec: row.keys[index],
                      palette: palette,
                      rowHeight: rowHeight,
                      onPressed: () => onKeyPressed(row.keys[index]),
                      onAlternateSelected: onAlternateSelected,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _KeyboardKeyButton extends StatefulWidget {
  const _KeyboardKeyButton({
    required this.keySpec,
    required this.palette,
    required this.rowHeight,
    required this.onPressed,
    required this.onAlternateSelected,
  });

  final AppKeyboardKeySpec keySpec;
  final _KeyboardPalette palette;
  final double rowHeight;
  final VoidCallback onPressed;
  final ValueChanged<String> onAlternateSelected;

  @override
  State<_KeyboardKeyButton> createState() => _KeyboardKeyButtonState();
}

class _KeyboardKeyButtonState extends State<_KeyboardKeyButton> {
  Timer? _repeatTimer;

  @override
  void dispose() {
    _repeatTimer?.cancel();
    super.dispose();
  }

  void _startRepeat() {
    if (widget.keySpec.kind != AppKeyboardKeyKind.backspace) {
      return;
    }

    _repeatTimer?.cancel();
    _repeatTimer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      widget.onPressed();
    });
  }

  void _stopRepeat() {
    _repeatTimer?.cancel();
    _repeatTimer = null;
  }

  Future<void> _showAlternatesMenu() async {
    if (widget.keySpec.alternateValues.isEmpty) {
      return;
    }

    final renderBox = context.findRenderObject() as RenderBox?;
    final overlay =
        Overlay.of(context, rootOverlay: true).context.findRenderObject()
            as RenderBox?;
    if (renderBox == null || overlay == null) {
      return;
    }

    final keyRect = Rect.fromPoints(
      renderBox.localToGlobal(Offset.zero, ancestor: overlay),
      renderBox.localToGlobal(
        renderBox.size.bottomRight(Offset.zero),
        ancestor: overlay,
      ),
    );

    final selectedValue = await showMenu<String>(
      context: context,
      color: widget.palette.regularKeyColor,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      position: RelativeRect.fromRect(keyRect, Offset.zero & overlay.size),
      items: [
        for (final value in widget.keySpec.alternateValues)
          PopupMenuItem<String>(
            value: value,
            height: widget.rowHeight * 0.9,
            child: Center(
              child: Text(
                value,
                style: TextStyle(
                  color: widget.palette.textColor,
                  fontSize: widget.rowHeight * 0.42,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );

    if (!mounted || selectedValue == null || selectedValue.isEmpty) {
      return;
    }

    widget.onAlternateSelected(selectedValue);
  }

  @override
  Widget build(BuildContext context) {
    final keyColor = widget.keySpec.isPrimary
        ? widget.palette.primaryActionColor
        : (widget.keySpec.kind == AppKeyboardKeyKind.character ||
                  widget.keySpec.kind == AppKeyboardKeyKind.space
              ? widget.palette.regularKeyColor
              : widget.palette.actionKeyColor);
    final textColor = widget.keySpec.isPrimary
        ? Colors.white
        : (widget.keySpec.isToggled
              ? widget.palette.primaryActionColor
              : widget.palette.textColor);
    final borderColor = widget.keySpec.isToggled
        ? widget.palette.primaryActionColor.withValues(alpha: 0.28)
        : widget.palette.borderColor.withValues(alpha: 0.35);
    final labelFontSize = widget.keySpec.kind == AppKeyboardKeyKind.space
        ? widget.rowHeight * 0.28
        : widget.rowHeight * 0.40;

    return GestureDetector(
      onTap: widget.onPressed,
      onLongPress: widget.keySpec.alternateValues.isNotEmpty
          ? _showAlternatesMenu
          : null,
      onLongPressStart: widget.keySpec.kind == AppKeyboardKeyKind.backspace
          ? (_) => _startRepeat()
          : null,
      onLongPressEnd: widget.keySpec.kind == AppKeyboardKeyKind.backspace
          ? (_) => _stopRepeat()
          : null,
      onLongPressCancel: widget.keySpec.kind == AppKeyboardKeyKind.backspace
          ? _stopRepeat
          : null,
      child: Material(
        color: Colors.transparent,
        child: AnimatedContainer(
          key: ValueKey('app-key-${widget.keySpec.id}'),
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: keyColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 0.8),
            boxShadow: [
              BoxShadow(
                color: widget.palette.shadowColor,
                blurRadius: 3,
                offset: const Offset(0, 1.5),
              ),
            ],
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
          // SizedBox.expand يدّي الـ FittedBox مقاس الخانة المحكوم،
          // فالـ scaleDown يصغّر الجليف لو أعرض من الخانة (مبيكبّرش أبداً).
          child: SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: _KeyboardKeyFace(
                keySpec: widget.keySpec,
                textColor: textColor,
                subtleTextColor: widget.palette.subtleTextColor,
                labelFontSize: labelFontSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _KeyboardKeyFace extends StatelessWidget {
  const _KeyboardKeyFace({
    required this.keySpec,
    required this.textColor,
    required this.subtleTextColor,
    required this.labelFontSize,
  });

  final AppKeyboardKeySpec keySpec;
  final Color textColor;
  final Color subtleTextColor;
  final double labelFontSize;

  @override
  Widget build(BuildContext context) {
    if (keySpec.icon != null &&
        (keySpec.label == null || keySpec.label!.isEmpty)) {
      return Icon(keySpec.icon, color: textColor, size: labelFontSize * 1.12);
    }

    if (keySpec.icon != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(keySpec.icon, color: textColor, size: labelFontSize * 0.92),
          const SizedBox(height: 1),
          Text(
            keySpec.label ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: subtleTextColor,
              fontSize: labelFontSize * 0.48,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ],
      );
    }

    final baseText = Text(
      keySpec.label ?? '',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: textColor,
        fontSize: labelFontSize,
        fontWeight: keySpec.kind == AppKeyboardKeyKind.space
            ? FontWeight.w600
            : FontWeight.w500,
        height: 1,
      ),
    );

    if (keySpec.kind != AppKeyboardKeyKind.character ||
        keySpec.alternateValues.isEmpty) {
      return baseText;
    }

    return Stack(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsetsDirectional.only(start: 4, top: 3),
            child: Text(
              keySpec.alternateValues.first,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: subtleTextColor,
                fontSize: labelFontSize * 0.36,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ),
        ),
        Center(child: baseText),
      ],
    );
  }
}

class _KeyboardPalette {
  const _KeyboardPalette({
    required this.surfaceColor,
    required this.borderColor,
    required this.regularKeyColor,
    required this.actionKeyColor,
    required this.primaryActionColor,
    required this.textColor,
    required this.subtleTextColor,
    required this.shadowColor,
  });

  final Color surfaceColor;
  final Color borderColor;
  final Color regularKeyColor;
  final Color actionKeyColor;
  final Color primaryActionColor;
  final Color textColor;
  final Color subtleTextColor;
  final Color shadowColor;
}
