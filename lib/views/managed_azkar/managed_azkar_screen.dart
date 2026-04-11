import 'dart:async';

import 'package:azan/controllers/cubits/rotation_cubit/rotation_cubit.dart';
import 'package:azan/core/components/appbutton.dart';
import 'package:azan/core/components/global_copyright_footer.dart';
import 'package:azan/core/helpers/managed_azkar_hive_helper.dart';
import 'package:azan/core/models/azkar_type.dart';
import 'package:azan/core/models/managed_azkar_entry.dart';
import 'package:azan/core/router/app_navigation.dart';
import 'package:azan/core/theme/app_theme.dart';
import 'package:azan/core/utils/alert_dialoges.dart';
import 'package:azan/core/utils/cache_helper.dart';
import 'package:azan/core/utils/dialoge_helper.dart';
import 'package:azan/core/utils/mqscale.dart';
import 'package:azan/generated/locale_keys.g.dart';
import 'package:azan/views/home/home_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ManagedAzkarScreen extends StatefulWidget {
  const ManagedAzkarScreen({super.key});

  @override
  State<ManagedAzkarScreen> createState() => _ManagedAzkarScreenState();
}

class _ManagedAzkarScreenState extends State<ManagedAzkarScreen> {
  AzkarType _selectedType = AzkarType.morning;
  bool _isLoading = true;
  List<ManagedAzkarEntry> _entries = const <ManagedAzkarEntry>[];

  @override
  void initState() {
    super.initState();
    unawaited(_loadEntries());
  }

  bool _isLandscape(BuildContext context) => UiRotationCubit().isLandscape();

  Future<void> _loadEntries() async {
    setState(() => _isLoading = true);
    final entries = await ManagedAzkarHiveHelper.getEntriesForType(
      _selectedType,
      activeOnly: false,
    );
    entries.sort((a, b) => b.id.compareTo(a.id));

    if (!mounted) return;
    setState(() {
      _entries = entries;
      _isLoading = false;
    });
  }

  void _goHome(BuildContext context) {
    AppNavigator.pushAndRemoveUntil(context, const HomeScreen());
  }

  Future<void> _showEditor({ManagedAzkarEntry? entry}) async {
    await showManagedAzkarEditorDialog(
      context,
      type: _selectedType,
      initialEntry: entry,
      onSubmit: (text, applicablePrayerIds) async {
        if (entry == null) {
          await ManagedAzkarHiveHelper.addEntry(
            type: _selectedType,
            text: text,
            applicablePrayerIds: applicablePrayerIds,
          );
        } else {
          await ManagedAzkarHiveHelper.updateEntry(
            entry.copyWith(
              text: text,
              applicablePrayerIds: applicablePrayerIds,
            ),
          );
        }
        await _loadEntries();
      },
    );
  }

  Future<void> _deleteEntry(ManagedAzkarEntry entry) async {
    await showDeleteDhikrDialog(
      context,
      dhikrText: entry.text,
      onConfirm: () {
        ManagedAzkarHiveHelper.deleteEntry(entry.id).then((_) {
          if (!mounted) return;
          unawaited(_loadEntries());
        });
      },
    );
  }

  void _selectType(AzkarType type) {
    if (_selectedType == type) return;
    setState(() {
      _selectedType = type;
    });
    unawaited(_loadEntries());
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = _isLandscape(context);

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: const GlobalCopyrightFooter(),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              CacheHelper.getSelectedBackground(),
              fit: BoxFit.fill,
              errorBuilder: (_, __, ___) => const SizedBox.expand(),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isLandscape ? 24.w : 20.w,
                vertical: 5.h,
              ),
              child: Column(
                children: [
                  _Header(
                    onClose: () => _goHome(context),
                    onMenu: () => Navigator.pop(context),
                  ),
                  SizedBox(height: isLandscape ? 10.h : 16.h),
                  Expanded(
                    child: isLandscape
                        ? Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: _GlassPanel(
                                  padding: EdgeInsets.all(16.r),
                                  child: _ManagedAzkarControls(
                                    selectedType: _selectedType,
                                    onSelectType: _selectType,
                                    onAdd: _showEditor,
                                  ),
                                ),
                              ),
                              SizedBox(width: 14.w),
                              Expanded(
                                flex: 8,
                                child: _GlassPanel(
                                  padding: EdgeInsets.all(16.r),
                                  child: _ManagedAzkarList(
                                    entries: _entries,
                                    selectedType: _selectedType,
                                    isLoading: _isLoading,
                                    onEdit: _showEditor,
                                    onDelete: _deleteEntry,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : _PortraitLayout(
                            selectedType: _selectedType,
                            entries: _entries,
                            isLoading: _isLoading,
                            onSelectType: _selectType,
                            onAdd: _showEditor,
                            onEdit: _showEditor,
                            onDelete: _deleteEntry,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onClose, required this.onMenu});

  final VoidCallback onClose;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: onClose,
          icon: Icon(Icons.close, color: AppTheme.accentColor, size: 34.r),
        ),
        Text(
          LocaleKeys.morning_evening_adhkar.tr(),
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryTextColor,
          ),
        ),
        IconButton(
          onPressed: onMenu,
          icon: Icon(Icons.menu, color: AppTheme.primaryTextColor, size: 34.r),
        ),
      ],
    );
  }
}

class _PortraitLayout extends StatelessWidget {
  const _PortraitLayout({
    required this.selectedType,
    required this.entries,
    required this.isLoading,
    required this.onSelectType,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  final AzkarType selectedType;
  final List<ManagedAzkarEntry> entries;
  final bool isLoading;
  final ValueChanged<AzkarType> onSelectType;
  final Future<void> Function({ManagedAzkarEntry? entry}) onAdd;
  final Future<void> Function({ManagedAzkarEntry? entry}) onEdit;
  final Future<void> Function(ManagedAzkarEntry entry) onDelete;

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      padding: EdgeInsets.all(16.r),
      child: Column(
        children: [
          _ManagedAzkarControls(
            selectedType: selectedType,
            onSelectType: onSelectType,
            onAdd: onAdd,
          ),
          SizedBox(height: 14.h),
          Expanded(
            child: _ManagedAzkarList(
              entries: entries,
              selectedType: selectedType,
              isLoading: isLoading,
              onEdit: onEdit,
              onDelete: onDelete,
            ),
          ),
        ],
      ),
    );
  }
}

class _ManagedAzkarControls extends StatelessWidget {
  const _ManagedAzkarControls({
    required this.selectedType,
    required this.onSelectType,
    required this.onAdd,
  });

  final AzkarType selectedType;
  final ValueChanged<AzkarType> onSelectType;
  final Future<void> Function({ManagedAzkarEntry? entry}) onAdd;

  @override
  Widget build(BuildContext context) {
    final types = AzkarType.values;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إدارة أذكار الشاشة الكاملة',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryTextColor,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'أضف أو عدّل الأذكار التي يعرضها AzkarView فوق الشاشة الرئيسية أثناء نوافذ الصباح والمساء وبعد الصلاة.',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppTheme.secondaryTextColor,
            height: 1.5,
          ),
        ),
        SizedBox(height: 14.h),
        Wrap(
          spacing: 10.w,
          runSpacing: 10.h,
          children: types
              .map((type) {
                final selected = selectedType == type;
                return ChoiceChip(
                  key: ValueKey('managed-azkar-type-${type.name}'),
                  label: Text(type.defaultTitle),
                  selected: selected,
                  onSelected: (_) => onSelectType(type),
                  selectedColor: AppTheme.accentColor.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: selected
                        ? AppTheme.primaryTextColor
                        : AppTheme.secondaryTextColor,
                    fontWeight: FontWeight.w700,
                  ),
                  backgroundColor: Colors.black.withOpacity(0.18),
                  side: BorderSide(
                    color: selected
                        ? AppTheme.accentColor
                        : Colors.white.withOpacity(0.16),
                  ),
                );
              })
              .toList(growable: false),
        ),
        SizedBox(height: 16.h),
        AppButton(
          width: 170.w,
          color: AppTheme.primaryButtonBackground,
          height: 44.h,
          radius: 22.r,
          onPressed: () => onAdd(),
          child: Text(
            LocaleKeys.add_message.tr(),
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.secondaryTextColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _ManagedAzkarList extends StatelessWidget {
  const _ManagedAzkarList({
    required this.entries,
    required this.selectedType,
    required this.isLoading,
    required this.onEdit,
    required this.onDelete,
  });

  final List<ManagedAzkarEntry> entries;
  final AzkarType selectedType;
  final bool isLoading;
  final Future<void> Function({ManagedAzkarEntry? entry}) onEdit;
  final Future<void> Function(ManagedAzkarEntry entry) onDelete;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (entries.isEmpty) {
      return Center(
        child: Text(
          'لا توجد عناصر في ${selectedType.defaultTitle}',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryTextColor,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: entries.length,
      separatorBuilder: (_, __) => SizedBox(height: 10.h),
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _ManagedAzkarTile(
          key: ValueKey('managed-azkar-entry-${entry.id}'),
          entry: entry,
          onEdit: () => onEdit(entry: entry),
          onDelete: () => onDelete(entry),
        );
      },
    );
  }
}

class _ManagedAzkarTile extends StatelessWidget {
  const _ManagedAzkarTile({
    super.key,
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  final ManagedAzkarEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final prayerNames = _prayerNames(entry, context);

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.22),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.white.withOpacity(0.18), width: 1.w),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  entry.text,
                  key: ValueKey('managed-azkar-entry-text-${entry.id}'),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: AppTheme.primaryTextColor,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                if (prayerNames != null) ...[
                  SizedBox(height: 8.h),
                  Text(
                    prayerNames,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: AppTheme.secondaryTextColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 10.w),
          IconButton(
            key: ValueKey('managed-azkar-entry-edit-${entry.id}'),
            tooltip: LocaleKeys.dhikr_edit_title.tr(),
            onPressed: onEdit,
            icon: Icon(Icons.edit, color: AppTheme.accentColor, size: 22.r),
          ),
          IconButton(
            key: ValueKey('managed-azkar-entry-delete-${entry.id}'),
            onPressed: onDelete,
            icon: Icon(Icons.close, size: 25.r, color: AppTheme.accentColor),
          ),
        ],
      ),
    );
  }

  String? _prayerNames(ManagedAzkarEntry entry, BuildContext context) {
    if (entry.setType != AzkarType.afterPrayer) return null;
    if (entry.applicablePrayerIds.isEmpty) {
      return 'بعد كل الصلوات';
    }

    final names = entry.applicablePrayerIds
        .map((id) => _prayerNameForId(id).tr())
        .toList(growable: false);
    return 'الصلوات: ${names.join(' - ')}';
  }

  String _prayerNameForId(int prayerId) {
    switch (prayerId) {
      case 1:
        return LocaleKeys.fajr;
      case 3:
        return LocaleKeys.dhuhr;
      case 4:
        return LocaleKeys.asr;
      case 5:
        return LocaleKeys.maghrib;
      case 6:
        return LocaleKeys.isha;
      default:
        return LocaleKeys.prayer;
    }
  }
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({required this.child, required this.padding});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.22),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.white.withOpacity(0.18), width: 1.w),
      ),
      child: child,
    );
  }
}

Future<void> showManagedAzkarEditorDialog(
  BuildContext context, {
  required AzkarType type,
  ManagedAzkarEntry? initialEntry,
  required Future<void> Function(String text, List<int> applicablePrayerIds)
  onSubmit,
}) async {
  final sizing = DialogConfig.getSizing(context);

  await showAppDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return UniversalDialogShell(
        forceMaxHeight: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DialogTitle(
              initialEntry == null
                  ? 'إضافة عنصر إلى ${type.defaultTitle}'
                  : 'تعديل عنصر من ${type.defaultTitle}',
            ),
            SizedBox(height: sizing.verticalGap * 0.6),
            Flexible(
              fit: FlexFit.loose,
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                physics: const BouncingScrollPhysics(),
                child: _ManagedAzkarEditorForm(
                  type: type,
                  initialEntry: initialEntry,
                  onSubmit: onSubmit,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _ManagedAzkarEditorForm extends StatefulWidget {
  const _ManagedAzkarEditorForm({
    required this.type,
    required this.initialEntry,
    required this.onSubmit,
  });

  final AzkarType type;
  final ManagedAzkarEntry? initialEntry;
  final Future<void> Function(String text, List<int> applicablePrayerIds)
  onSubmit;

  @override
  State<_ManagedAzkarEditorForm> createState() =>
      _ManagedAzkarEditorFormState();
}

class _ManagedAzkarEditorFormState extends State<_ManagedAzkarEditorForm> {
  late final TextEditingController _textController;
  late final Set<int> _selectedPrayerIds;
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: widget.initialEntry?.text ?? '',
    );
    _selectedPrayerIds =
        widget.initialEntry?.applicablePrayerIds.toSet() ?? <int>{};
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;

    setState(() => _isSaving = true);
    await widget.onSubmit(
      _textController.text.trim(),
      _selectedPrayerIds.toList()..sort(),
    );

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final sizing = DialogConfig.getSizing(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VirtualTextField(
            controller: _textController,
            maxLines: 8,
            minFieldHeight: sizing.bodyFontSize * 5.2,
            labelText: LocaleKeys.dhikr_text_label.tr(),
            textAlign: TextAlign.right,
            textStyle: TextStyle(
              color: Colors.black87,
              fontSize: sizing.bodyFontSize,
            ),
            borderRadius: sizing.borderRadius,
            contentPadding: EdgeInsets.symmetric(
              horizontal: sizing.screenWidth * 0.04,
              vertical: sizing.screenHeight * 0.015,
            ),
            labelStyle: TextStyle(
              color: Colors.grey.shade700,
              fontSize: sizing.bodyFontSize * 0.92,
              fontWeight: FontWeight.w600,
            ),
            theme: VirtualKeyboardFieldTheme(
              fillColor: Colors.white,
              borderColor: Colors.grey.shade400,
              activeBorderColor: const Color(0xFFF4C66A),
              errorBorderColor: Colors.red,
              textColor: Colors.black87,
              hintColor: Colors.grey.shade600,
              labelColor: Colors.grey.shade700,
              keyboardTextColor: Colors.black87,
              keyboardBackgroundColor: Colors.white,
              keyboardBorderColor: const Color(0x66F4C66A),
              keyboardShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return LocaleKeys.dhikr_text_required_error.tr();
              }
              return null;
            },
          ),
          if (widget.type == AzkarType.afterPrayer) ...[
            SizedBox(height: sizing.verticalGap * 0.7),
            Text(
              'الصلوات المعنية',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.secondaryTextColor,
                fontSize: sizing.bodyFontSize,
              ),
            ),
            SizedBox(height: sizing.verticalGap * 0.25),
            Text(
              'اترك الاختيارات فارغة إذا أردت إظهار الذكر بعد كل الصلوات.',
              style: TextStyle(
                color: AppTheme.secondaryTextColor,
                fontSize: sizing.bodyFontSize * 0.9,
              ),
            ),
            SizedBox(height: sizing.verticalGap * 0.35),
            Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: const <int>[1, 3, 4, 5, 6]
                  .map((prayerId) {
                    final selected = _selectedPrayerIds.contains(prayerId);
                    return FilterChip(
                      label: Text(_prayerTitle(prayerId).tr()),
                      selected: selected,
                      onSelected: (value) {
                        setState(() {
                          if (value) {
                            _selectedPrayerIds.add(prayerId);
                          } else {
                            _selectedPrayerIds.remove(prayerId);
                          }
                        });
                      },
                      selectedColor: AppTheme.accentColor.withOpacity(0.2),
                      checkmarkColor: AppTheme.primaryTextColor,
                      backgroundColor: Colors.black.withOpacity(0.18),
                      side: BorderSide(
                        color: selected
                            ? AppTheme.accentColor
                            : Colors.white.withOpacity(0.16),
                      ),
                      labelStyle: TextStyle(
                        color: selected
                            ? AppTheme.primaryTextColor
                            : AppTheme.secondaryTextColor,
                        fontWeight: FontWeight.w700,
                      ),
                    );
                  })
                  .toList(growable: false),
            ),
          ],
          SizedBox(height: sizing.verticalGap * 0.8),
          DialogButtonRow(
            leftButton: DialogButton(
              text: LocaleKeys.common_cancel.tr(),
              backgroundColor: AppTheme.cancelButtonBackgroundColor,
              textColor: AppTheme.cancelButtonTextColor,
              onPressed: () => Navigator.of(context).pop(),
            ),
            rightButton: DialogButton(
              text: _isSaving ? '...' : LocaleKeys.common_save.tr(),
              backgroundColor: AppTheme.primaryButtonBackground,
              textColor: AppTheme.primaryButtonTextColor,
              fontWeight: FontWeight.w700,
              onPressed: _submit,
            ),
          ),
        ],
      ),
    );
  }

  String _prayerTitle(int prayerId) {
    switch (prayerId) {
      case 1:
        return LocaleKeys.fajr;
      case 3:
        return LocaleKeys.dhuhr;
      case 4:
        return LocaleKeys.asr;
      case 5:
        return LocaleKeys.maghrib;
      case 6:
        return LocaleKeys.isha;
      default:
        return LocaleKeys.prayer;
    }
  }
}
