import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:azan/controllers/cubits/rotation_cubit/rotation_cubit.dart';
import 'package:azan/core/components/global_copyright_footer.dart';
import 'package:azan/core/helpers/azkar_prayer_scope_helper.dart';
import 'package:azan/core/helpers/managed_azkar_hive_helper.dart';
import 'package:azan/core/helpers/managed_azkar_import_helper.dart';
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
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

String _prayerTitle(int prayerId) {
  return AzkarPrayerScopeHelper.titleKey(prayerId);
}

class ManagedAzkarScreen extends StatefulWidget {
  const ManagedAzkarScreen({super.key});

  @override
  State<ManagedAzkarScreen> createState() => _ManagedAzkarScreenState();
}

class _ManagedAzkarScreenState extends State<ManagedAzkarScreen> {
  AzkarType _selectedType = AzkarType.morning;
  int? _selectedPrayerFilterId;
  bool _isLoading = true;
  List<ManagedAzkarEntry> _entries = const <ManagedAzkarEntry>[];

  @override
  void initState() {
    super.initState();
    unawaited(_loadEntries());
  }

  bool _isLandscape(BuildContext context) => UiRotationCubit().isLandscape();

  List<ManagedAzkarEntry> get _visibleEntries {
    if (_selectedType != AzkarType.afterPrayer ||
        _selectedPrayerFilterId == null) {
      return _entries;
    }

    final prayerId = _selectedPrayerFilterId!;
    return _entries
        .where(
          (entry) =>
              entry.applicablePrayerIds.isEmpty ||
              entry.applicablePrayerIds.contains(prayerId),
        )
        .toList(growable: false);
  }

  Future<void> _loadEntries() async {
    setState(() => _isLoading = true);
    final entries = await ManagedAzkarHiveHelper.getEntriesForType(
      _selectedType,
      activeOnly: false,
    );

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
      onImportFile: entry == null ? _importFromFile : null,
      onPasteBulk: entry == null ? _importFromClipboard : null,
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

  Future<String?> _importFromFile() async {
    PlatformFile? file;
    try {
      final picked = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        withData: true,
        type: FileType.custom,
        allowedExtensions: const ['txt', 'csv', 'xlsx'],
      );
      file = picked?.files.single;
    } on PlatformException {
      return 'الجهاز لا يحتوي على تطبيق لاختيار الملفات. على بعض شاشات Android TV لا يوجد مدير ملفات، استخدم "لصق جماعي" أو ثبّت مدير ملفات/Document Picker على الشاشة.';
    } catch (_) {
      return 'تعذر فتح اختيار الملفات على هذا الجهاز. استخدم لصق جماعي أو جرّب من جهاز يحتوي على مدير ملفات.';
    }

    if (file == null) return null;

    final bytes =
        file.bytes ??
        (file.path == null ? null : await File(file.path!).readAsBytes());
    if (bytes == null || bytes.isEmpty) {
      return 'لم نتمكن من قراءة الملف. جرّب ملف TXT أو CSV أو XLSX واضح.';
    }
    if (bytes.length > 5 * 1024 * 1024) {
      return 'حجم الملف أكبر من 5MB. قسّم المحتوى إلى ملف أصغر.';
    }

    return _importParsedContent(
      bytes: bytes,
      sourceName: file.name,
      successPrefix: 'تم استيراد الملف',
    );
  }

  Future<String?> _importFromClipboard() async {
    final clipboard = await Clipboard.getData(Clipboard.kTextPlain);
    final content = clipboard?.text ?? '';
    if (content.trim().isEmpty) {
      return 'لا يوجد نص منسوخ حاليًا.';
    }

    return _importParsedContent(
      content: content,
      sourceName: 'clipboard.txt',
      successPrefix: 'تم استيراد النص المنسوخ',
    );
  }

  Future<String?> _importParsedContent({
    String? content,
    List<int>? bytes,
    required String sourceName,
    required String successPrefix,
  }) async {
    final result = bytes == null
        ? ManagedAzkarImportHelper.parseFileContent(
            content: content ?? '',
            fileName: sourceName,
            type: _selectedType,
          )
        : ManagedAzkarImportHelper.parseFileBytes(
            bytes: bytes,
            fileName: sourceName,
            type: _selectedType,
          );

    if (result.entries.isEmpty) {
      return result.warnings.isEmpty
          ? 'لم يتم العثور على عناصر صالحة للاستيراد.'
          : result.warnings.join('\n');
    }

    final count = await ManagedAzkarHiveHelper.importEntries(
      type: _selectedType,
      drafts: result.entries,
    );
    if (!mounted) return null;
    await _loadEntries();

    final warnings = result.warnings.isEmpty
        ? ''
        : '\n\nملاحظات:\n${result.warnings.take(2).join('\n')}';
    return '$successPrefix: $count عنصر إلى ${_selectedType.defaultTitle}.$warnings';
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

  Future<void> _toggleEntryActive(ManagedAzkarEntry entry) async {
    await ManagedAzkarHiveHelper.setActive(entry.id, !entry.active);
    if (!mounted) return;
    await _loadEntries();
  }

  Future<void> _reorderEntry(int oldIndex, int newIndex) async {
    final visibleEntries = _visibleEntries;
    if (oldIndex < 0 || oldIndex >= visibleEntries.length) return;

    final targetIndex = oldIndex < newIndex ? newIndex - 1 : newIndex;
    if (oldIndex == targetIndex || visibleEntries.isEmpty) return;

    final boundedTargetIndex = targetIndex
        .clamp(0, visibleEntries.length - 1)
        .toInt();
    final movedEntry = visibleEntries[oldIndex];
    final targetEntry = visibleEntries[boundedTargetIndex];
    final targetTypeIndex = _entries.indexWhere(
      (entry) => entry.id == targetEntry.id,
    );
    if (targetTypeIndex == -1) return;

    await ManagedAzkarHiveHelper.moveEntryToTypeIndex(
      type: _selectedType,
      entryId: movedEntry.id,
      targetIndex: targetTypeIndex,
    );
    if (!mounted) return;
    await _loadEntries();
  }

  void _selectType(AzkarType type) {
    if (_selectedType == type) return;
    setState(() {
      _selectedType = type;
      if (type != AzkarType.afterPrayer) {
        _selectedPrayerFilterId = null;
      }
    });
    unawaited(_loadEntries());
  }

  void _selectPrayerFilter(int? prayerId) {
    if (_selectedPrayerFilterId == prayerId) return;
    setState(() => _selectedPrayerFilterId = prayerId);
  }

  Future<void> _showPrayerFilterPicker() async {
    final selectedPrayerId = await showAppDialog<int>(
      context: context,
      builder: (dialogContext) =>
          _PrayerFilterDialog(selectedPrayerId: _selectedPrayerFilterId),
    );

    if (!mounted) return;
    if (selectedPrayerId == null) return;
    _selectPrayerFilter(selectedPrayerId == -1 ? null : selectedPrayerId);
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
                                    scrollable: true,
                                  ),
                                ),
                              ),
                              SizedBox(width: 14.w),
                              Expanded(
                                flex: 8,
                                child: _GlassPanel(
                                  padding: EdgeInsets.all(16.r),
                                  child: _ManagedAzkarList(
                                    entries: _visibleEntries,
                                    selectedType: _selectedType,
                                    selectedPrayerFilterId:
                                        _selectedPrayerFilterId,
                                    isLoading: _isLoading,
                                    onAdd: _showEditor,
                                    onEdit: _showEditor,
                                    onDelete: _deleteEntry,
                                    onToggleActive: _toggleEntryActive,
                                    onReorder: _reorderEntry,
                                    onPickPrayerFilter: _showPrayerFilterPicker,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : _PortraitLayout(
                            selectedType: _selectedType,
                            entries: _visibleEntries,
                            selectedPrayerFilterId: _selectedPrayerFilterId,
                            isLoading: _isLoading,
                            onSelectType: _selectType,
                            onAdd: _showEditor,
                            onEdit: _showEditor,
                            onDelete: _deleteEntry,
                            onToggleActive: _toggleEntryActive,
                            onReorder: _reorderEntry,
                            onPickPrayerFilter: _showPrayerFilterPicker,
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
    required this.selectedPrayerFilterId,
    required this.isLoading,
    required this.onSelectType,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
    required this.onReorder,
    required this.onPickPrayerFilter,
  });

  final AzkarType selectedType;
  final List<ManagedAzkarEntry> entries;
  final int? selectedPrayerFilterId;
  final bool isLoading;
  final ValueChanged<AzkarType> onSelectType;
  final Future<void> Function({ManagedAzkarEntry? entry}) onAdd;
  final Future<void> Function({ManagedAzkarEntry? entry}) onEdit;
  final Future<void> Function(ManagedAzkarEntry entry) onDelete;
  final Future<void> Function(ManagedAzkarEntry entry) onToggleActive;
  final Future<void> Function(int oldIndex, int newIndex) onReorder;
  final VoidCallback onPickPrayerFilter;

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      padding: EdgeInsets.all(16.r),
      child: Column(
        children: [
          _ManagedAzkarControls(
            selectedType: selectedType,
            onSelectType: onSelectType,
          ),
          SizedBox(height: 14.h),
          Expanded(
            child: _ManagedAzkarList(
              entries: entries,
              selectedType: selectedType,
              selectedPrayerFilterId: selectedPrayerFilterId,
              isLoading: isLoading,
              onAdd: onAdd,
              onEdit: onEdit,
              onDelete: onDelete,
              onToggleActive: onToggleActive,
              onReorder: onReorder,
              onPickPrayerFilter: onPickPrayerFilter,
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
    this.scrollable = false,
  });

  final AzkarType selectedType;
  final ValueChanged<AzkarType> onSelectType;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final types = AzkarType.values;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إدارة محتوى الآيات والأحاديث والأذكار',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryTextColor,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'أضف وعدّل المحتوى من لوحة التحكم، مع دعم الاستيراد الجماعي لتسهيل الإدارة والتحديث.',
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
                  selectedColor: AppTheme.accentColor.withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: selected
                        ? AppTheme.primaryTextColor
                        : AppTheme.secondaryTextColor,
                    fontWeight: FontWeight.w700,
                  ),
                  backgroundColor: Colors.black.withValues(alpha: 0.18),
                  side: BorderSide(
                    color: selected
                        ? AppTheme.accentColor
                        : Colors.white.withValues(alpha: 0.16),
                  ),
                );
              })
              .toList(growable: false),
        ),
      ],
    );

    if (!scrollable) return content;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: content,
          ),
        );
      },
    );
  }
}

class _ContentImportGrid extends StatelessWidget {
  const _ContentImportGrid({
    required this.onImportFile,
    required this.onPasteBulk,
  });

  final VoidCallback onImportFile;
  final VoidCallback onPasteBulk;

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;
    final cards = [
      _ContentImportCard(
        icon: Icons.table_chart_rounded,
        title: 'استيراد من ملف',
        description: 'اختر ملف Excel أو CSV أو TXT جاهز للاستيراد.',
        actionLabel: 'اختر ملف',
        onTap: onImportFile,
        compact: isLandscape,
        stretchContent: isLandscape,
      ),
      _ContentImportCard(
        icon: Icons.content_paste_go_rounded,
        title: 'لصق جماعي',
        description: 'انسخ النصوص من الحاسب أو الجوال، أو استخدم ملف TXT.',
        actionLabel: 'لصق محتوى',
        onTap: onPasteBulk,
        compact: isLandscape,
        stretchContent: isLandscape,
      ),
    ];

    if (isLandscape) {
      return SizedBox(
        height: 144.h,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < cards.length; i++) ...[
              if (i > 0) SizedBox(width: 8.w),
              Expanded(child: cards[i]),
            ],
          ],
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < cards.length; i++) ...[
          if (i > 0) SizedBox(height: 8.h),
          cards[i],
        ],
      ],
    );
  }
}

class _ContentImportCard extends StatelessWidget {
  const _ContentImportCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onTap,
    this.compact = false,
    this.stretchContent = false,
  });

  final IconData icon;
  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback onTap;
  final bool compact;
  final bool stretchContent;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          constraints: BoxConstraints(minHeight: compact ? 96.h : 112.h),
          padding: EdgeInsets.all(compact ? 9.r : 12.r),
          decoration: BoxDecoration(
            color: _ManagedAzkarDialogColors.cardBackground,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: _ManagedAzkarDialogColors.cardBorder,
              width: 1.w,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                icon,
                color: _ManagedAzkarDialogColors.accent,
                size: compact ? 26.r : 32.r,
              ),
              SizedBox(height: compact ? 5.h : 8.h),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _ManagedAzkarDialogColors.primaryText,
                  fontSize: compact ? 12.5.sp : 14.sp,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: compact ? 3.h : 5.h),
              Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _ManagedAzkarDialogColors.secondaryText,
                  fontSize: compact ? 10.5.sp : 11.5.sp,
                  height: compact ? 1.22 : 1.35,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: compact ? 3 : 4,
                overflow: TextOverflow.ellipsis,
              ),
              if (stretchContent)
                const Spacer()
              else
                SizedBox(height: compact ? 7.h : 10.h),
              if (stretchContent) SizedBox(height: compact ? 7.h : 10.h),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(
                  vertical: compact ? 5.h : 7.h,
                  horizontal: 8.w,
                ),
                decoration: BoxDecoration(
                  color: _ManagedAzkarDialogColors.accent.withValues(
                    alpha: 0.14,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: _ManagedAzkarDialogColors.accent.withValues(
                      alpha: 0.55,
                    ),
                    width: 1.w,
                  ),
                ),
                child: Text(
                  actionLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _ManagedAzkarDialogColors.primaryText,
                    fontSize: compact ? 10.5.sp : 12.sp,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ManagedAzkarList extends StatelessWidget {
  const _ManagedAzkarList({
    required this.entries,
    required this.selectedType,
    required this.selectedPrayerFilterId,
    required this.isLoading,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
    required this.onReorder,
    required this.onPickPrayerFilter,
  });

  final List<ManagedAzkarEntry> entries;
  final AzkarType selectedType;
  final int? selectedPrayerFilterId;
  final bool isLoading;
  final Future<void> Function({ManagedAzkarEntry? entry}) onAdd;
  final Future<void> Function({ManagedAzkarEntry? entry}) onEdit;
  final Future<void> Function(ManagedAzkarEntry entry) onDelete;
  final Future<void> Function(ManagedAzkarEntry entry) onToggleActive;
  final Future<void> Function(int oldIndex, int newIndex) onReorder;
  final VoidCallback onPickPrayerFilter;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ManagedListToolbar(
          selectedType: selectedType,
          selectedPrayerFilterId: selectedPrayerFilterId,
          count: entries.length,
          onAdd: () => onAdd(),
          onPickPrayerFilter: onPickPrayerFilter,
        ),
        SizedBox(height: 10.h),
        _ManagedTableHeader(selectedType: selectedType),
        SizedBox(height: 8.h),
        Expanded(child: _buildBody()),
      ],
    );
  }

  Widget _buildBody() {
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

    return ReorderableListView.builder(
      padding: EdgeInsets.zero,
      itemCount: entries.length,
      buildDefaultDragHandles: false,
      onReorder: (oldIndex, newIndex) {
        unawaited(onReorder(oldIndex, newIndex));
      },
      itemBuilder: (context, index) {
        final entry = entries[index];
        return Padding(
          key: ValueKey('managed-azkar-entry-wrapper-${entry.id}'),
          padding: EdgeInsets.only(
            bottom: index == entries.length - 1 ? 0 : 10.h,
          ),
          child: _ManagedAzkarTile(
            entry: entry,
            index: index,
            dragHandle: ReorderableDragStartListener(
              key: ValueKey('managed-azkar-entry-drag-${entry.id}'),
              index: index,
              child: const _ManagedDragHandle(),
            ),
            onEdit: () => onEdit(entry: entry),
            onDelete: () => onDelete(entry),
            onToggleActive: () => onToggleActive(entry),
          ),
        );
      },
    );
  }
}

class _ManagedListToolbar extends StatelessWidget {
  const _ManagedListToolbar({
    required this.selectedType,
    required this.selectedPrayerFilterId,
    required this.count,
    required this.onAdd,
    required this.onPickPrayerFilter,
  });

  final AzkarType selectedType;
  final int? selectedPrayerFilterId;
  final int count;
  final VoidCallback onAdd;
  final VoidCallback onPickPrayerFilter;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                selectedType.defaultTitle,
                style: TextStyle(
                  color: AppTheme.primaryTextColor,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                '$count عنصر محفوظ',
                style: TextStyle(
                  color: AppTheme.secondaryTextColor,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        if (selectedType == AzkarType.afterPrayer) ...[
          _PrayerFilterButton(
            selectedPrayerId: selectedPrayerFilterId,
            onTap: onPickPrayerFilter,
          ),
          SizedBox(width: 8.w),
        ],
        _ManagedAddButton(onTap: onAdd),
      ],
    );
  }
}

class _PrayerFilterButton extends StatelessWidget {
  const _PrayerFilterButton({
    required this.selectedPrayerId,
    required this.onTap,
  });

  final int? selectedPrayerId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = selectedPrayerId == null
        ? 'كل الصلوات'
        : _prayerTitle(selectedPrayerId!).tr();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        constraints: BoxConstraints(maxWidth: 118.w),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppTheme.accentColor.withValues(alpha: 0.58),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          textDirection: ui.TextDirection.rtl,
          children: [
            Icon(
              Icons.filter_alt_rounded,
              color: AppTheme.accentColor,
              size: 17.r,
            ),
            SizedBox(width: 5.w),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppTheme.primaryTextColor,
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrayerFilterDialog extends StatelessWidget {
  const _PrayerFilterDialog({required this.selectedPrayerId});

  final int? selectedPrayerId;

  @override
  Widget build(BuildContext context) {
    final sizing = DialogConfig.getSizing(context);

    return UniversalDialogShell(
      customMaxWidth: sizing.isLandscape
          ? sizing.screenWidth * 0.42
          : sizing.screenWidth * 0.88,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const DialogTitle('تصنيف أذكار بعد الصلاة'),
          SizedBox(height: sizing.verticalGap * 0.45),
          Text(
            'اختر الصلاة لعرض الأذكار المرتبطة بها. العناصر العامة "كل صلاة" ستظهر مع أي اختيار.',
            textAlign: TextAlign.center,
            textDirection: ui.TextDirection.rtl,
            style: TextStyle(
              color: _ManagedAzkarDialogColors.secondaryText,
              fontSize: sizing.bodyFontSize * 0.9,
              height: 1.35,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: sizing.verticalGap * 0.55),
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            alignment: WrapAlignment.center,
            children: <int>[-1, ...AzkarPrayerScopeHelper.editablePrayerIds]
                .map((prayerId) {
                  final resolvedPrayerId = prayerId == -1 ? null : prayerId;
                  final selected = resolvedPrayerId == selectedPrayerId;
                  final label = resolvedPrayerId == null
                      ? 'كل الصلوات'
                      : _prayerTitle(resolvedPrayerId).tr();

                  return _PrayerFilterOption(
                    label: label,
                    selected: selected,
                    onTap: () => Navigator.of(context).pop(prayerId),
                  );
                })
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class _PrayerFilterOption extends StatelessWidget {
  const _PrayerFilterOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        width: 128.w,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: selected
              ? _ManagedAzkarDialogColors.selectedSurface
              : _ManagedAzkarDialogColors.cardBackground,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: selected
                ? _ManagedAzkarDialogColors.accent
                : _ManagedAzkarDialogColors.cardBorder,
            width: selected ? 1.5.w : 1.w,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          textDirection: ui.TextDirection.rtl,
          children: [
            if (selected) ...[
              Icon(
                Icons.check_rounded,
                color: _ManagedAzkarDialogColors.accent,
                size: 18.r,
              ),
              SizedBox(width: 6.w),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected
                      ? _ManagedAzkarDialogColors.primaryText
                      : _ManagedAzkarDialogColors.secondaryText,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManagedAddButton extends StatelessWidget {
  const _ManagedAddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppTheme.primaryButtonBackground,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, color: AppTheme.primaryButtonTextColor),
            SizedBox(width: 5.w),
            Text(
              'إضافة جديد',
              style: TextStyle(
                color: AppTheme.primaryButtonTextColor,
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManagedTableHeader extends StatelessWidget {
  const _ManagedTableHeader({required this.selectedType});

  final AzkarType selectedType;

  String get _leadingTitle {
    switch (selectedType) {
      case AzkarType.afterPrayer:
        return 'الصلاة';
      case AzkarType.morning:
      case AzkarType.evening:
        return 'الترتيب';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: _ManagedAzkarDialogColors.listHeaderBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: _ManagedAzkarDialogColors.listItemBorder,
          width: 1.w,
        ),
      ),
      child: Row(
        textDirection: ui.TextDirection.rtl,
        children: [
          SizedBox(width: 68.w, child: _ManagedHeaderText(_leadingTitle)),
          SizedBox(width: 8.w),
          Expanded(child: _ManagedHeaderText('العنوان')),
          SizedBox(width: 8.w),
          SizedBox(width: 58.w, child: _ManagedHeaderText('الحالة')),
          SizedBox(width: 8.w),
          SizedBox(width: 78.w, child: _ManagedHeaderText('الإجراءات')),
        ],
      ),
    );
  }
}

class _ManagedHeaderText extends StatelessWidget {
  const _ManagedHeaderText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: _ManagedAzkarDialogColors.secondaryText,
        fontSize: 11.5.sp,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _ManagedAzkarTile extends StatelessWidget {
  const _ManagedAzkarTile({
    required this.entry,
    required this.index,
    required this.dragHandle,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
  });

  final ManagedAzkarEntry entry;
  final int index;
  final Widget dragHandle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleActive;

  @override
  Widget build(BuildContext context) {
    final prayerScopeLabel = _prayerScopeLabel(entry, context);
    final orderLabel = '${index + 1}';
    final displayText = _cleanDisplayText(entry.text);
    final textColor = entry.active
        ? _ManagedAzkarDialogColors.listItemText
        : _ManagedAzkarDialogColors.listItemMutedText;
    final metaTextColor = entry.active
        ? _ManagedAzkarDialogColors.secondaryText
        : _ManagedAzkarDialogColors.listItemMutedText;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: entry.active
            ? _ManagedAzkarDialogColors.listItemBackground
            : _ManagedAzkarDialogColors.listItemInactiveBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: entry.active
              ? _ManagedAzkarDialogColors.listItemBorder
              : _ManagedAzkarDialogColors.listItemBorder.withValues(
                  alpha: 0.55,
                ),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: entry.active ? 0.24 : 0.14),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Row(
        textDirection: ui.TextDirection.rtl,
        children: [
          SizedBox(
            width: 68.w,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    dragHandle,
                    SizedBox(width: 4.w),
                    _ManagedOrderBadge(label: orderLabel, active: entry.active),
                  ],
                ),
                if (prayerScopeLabel != null) ...[
                  SizedBox(height: 5.h),
                  Text(
                    prayerScopeLabel,
                    textAlign: TextAlign.center,
                    textDirection: ui.TextDirection.rtl,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: metaTextColor,
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              displayText,
              key: ValueKey('managed-azkar-entry-text-${entry.id}'),
              textAlign: TextAlign.right,
              textDirection: ui.TextDirection.rtl,
              style: TextStyle(
                color: textColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                height: 1.35,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 8.w),
          SizedBox(
            width: 58.w,
            child: _ManagedStatusButton(
              active: entry.active,
              onTap: onToggleActive,
            ),
          ),
          SizedBox(width: 8.w),
          SizedBox(
            width: 78.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ManagedTileActionButton(
                  key: ValueKey('managed-azkar-entry-edit-${entry.id}'),
                  tooltip: LocaleKeys.dhikr_edit_title.tr(),
                  icon: Icons.edit_rounded,
                  onPressed: onEdit,
                ),
                SizedBox(width: 6.w),
                _ManagedTileActionButton(
                  key: ValueKey('managed-azkar-entry-delete-${entry.id}'),
                  tooltip: LocaleKeys.delete.tr(),
                  icon: Icons.delete_outline_rounded,
                  color: AppTheme.cancelButtonBackgroundColor,
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _prayerScopeLabel(ManagedAzkarEntry entry, BuildContext context) {
    if (entry.setType != AzkarType.afterPrayer) return null;

    if (entry.applicablePrayerIds.isEmpty) {
      final defaultPrayerId = ManagedAzkarEntry.defaultPrayerIdForType(
        entry.setType,
      );
      if (defaultPrayerId == null) return 'كل صلاة';
      return _prayerNameForId(defaultPrayerId).tr();
    }

    final names = entry.applicablePrayerIds
        .map((id) => _prayerTitle(id).tr())
        .toList(growable: false);
    return names.join('\n');
  }

  String _cleanDisplayText(String value) {
    return value
        .replaceAll(
          RegExp('[\u200E\u200F\u202A-\u202E\u2066-\u2069\uFEFF]'),
          '',
        )
        .trim();
  }

  String _prayerNameForId(int prayerId) => _prayerTitle(prayerId);
}

class _ManagedStatusButton extends StatelessWidget {
  const _ManagedStatusButton({required this.active, required this.onTap});

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppTheme.accentColor : AppTheme.secondaryTextColor;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(color: color.withValues(alpha: 0.38), width: 1.w),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              active ? Icons.visibility_rounded : Icons.visibility_off_rounded,
              color: color,
              size: 15.r,
            ),
            SizedBox(height: 2.h),
            Text(
              active ? 'ظاهر' : 'مخفي',
              maxLines: 1,
              style: TextStyle(
                color: color,
                fontSize: 9.5.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManagedTileActionButton extends StatelessWidget {
  const _ManagedTileActionButton({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.color,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32.r,
      height: 32.r,
      child: IconButton(
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        constraints: BoxConstraints.tight(Size(32.r, 32.r)),
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 21.r,
          color: onPressed == null
              ? AppTheme.secondaryTextColor.withValues(alpha: 0.45)
              : color ?? AppTheme.accentColor,
        ),
      ),
    );
  }
}

class _ManagedDragHandle extends StatelessWidget {
  const _ManagedDragHandle();

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'اسحب لتغيير الترتيب',
      child: SizedBox(
        width: 32.r,
        height: 32.r,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppTheme.accentColor.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: AppTheme.accentColor.withValues(alpha: 0.38),
              width: 1.w,
            ),
          ),
          child: Icon(
            Icons.drag_indicator_rounded,
            color: AppTheme.accentColor,
            size: 22.r,
          ),
        ),
      ),
    );
  }
}

class _ManagedOrderBadge extends StatelessWidget {
  const _ManagedOrderBadge({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30.r,
      height: 30.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active
            ? _ManagedAzkarDialogColors.badgeBackground
            : _ManagedAzkarDialogColors.badgeBackground.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(
          color: active
              ? _ManagedAzkarDialogColors.accent.withValues(alpha: 0.70)
              : _ManagedAzkarDialogColors.cardBorder,
          width: 1.w,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active
              ? _ManagedAzkarDialogColors.primaryText
              : _ManagedAzkarDialogColors.listItemMutedText,
          fontSize: 12.sp,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
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
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.18),
          width: 1.w,
        ),
      ),
      child: child,
    );
  }
}

class _ManagedAzkarDialogColors {
  const _ManagedAzkarDialogColors._();

  static const Color primaryText = Color(0xFFFFE8AD);
  static const Color secondaryText = Color(0xFFE6EEF6);
  static const Color mutedText = Color(0xFFB8C5D1);
  static const Color accent = Color(0xFFF4C66A);
  static const Color cardBackground = Color(0xFF132232);
  static const Color cardBorder = Color(0xFF32465A);
  static const Color selectedSurface = Color(0xFF26301F);
  static const Color listHeaderBackground = Color(0xD9132232);
  static const Color listItemBackground = Color(0xF0132232);
  static const Color listItemInactiveBackground = Color(0xD9122232);
  static const Color listItemBorder = Color(0x803B5369);
  static const Color listItemText = Color(0xFFFFF4D6);
  static const Color listItemMutedText = Color(0xFFBFD0DF);
  static const Color badgeBackground = Color(0xFF203448);
}

Future<void> showManagedAzkarEditorDialog(
  BuildContext context, {
  required AzkarType type,
  ManagedAzkarEntry? initialEntry,
  Future<String?> Function()? onImportFile,
  Future<String?> Function()? onPasteBulk,
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
                  onImportFile: onImportFile,
                  onPasteBulk: onPasteBulk,
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
    required this.onImportFile,
    required this.onPasteBulk,
    required this.onSubmit,
  });

  final AzkarType type;
  final ManagedAzkarEntry? initialEntry;
  final Future<String?> Function()? onImportFile;
  final Future<String?> Function()? onPasteBulk;
  final Future<void> Function(String text, List<int> applicablePrayerIds)
  onSubmit;

  @override
  State<_ManagedAzkarEditorForm> createState() =>
      _ManagedAzkarEditorFormState();
}

class _EditorImportPanel extends StatelessWidget {
  const _EditorImportPanel({
    required this.onImportFile,
    required this.onPasteBulk,
  });

  final Future<void> Function() onImportFile;
  final Future<void> Function() onPasteBulk;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: _ManagedAzkarDialogColors.cardBackground.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _ManagedAzkarDialogColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            textDirection: ui.TextDirection.rtl,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
                decoration: BoxDecoration(
                  color: _ManagedAzkarDialogColors.selectedSurface,
                  borderRadius: BorderRadius.circular(999.r),
                  border: Border.all(
                    color: _ManagedAzkarDialogColors.accent,
                    width: 1.2.w,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.edit_document,
                      color: _ManagedAzkarDialogColors.accent,
                      size: 16.r,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'كتابة يدوية',
                      style: TextStyle(
                        color: _ManagedAzkarDialogColors.primaryText,
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'أدخل النص مباشرة، أو استخدم طريقة أسرع للاستيراد.',
                  textAlign: TextAlign.right,
                  textDirection: ui.TextDirection.rtl,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _ManagedAzkarDialogColors.secondaryText,
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          _ContentImportGrid(
            onImportFile: () => unawaited(onImportFile()),
            onPasteBulk: () => unawaited(onPasteBulk()),
          ),
        ],
      ),
    );
  }
}

class _ImportStatusMessage extends StatelessWidget {
  const _ImportStatusMessage({required this.isLoading, required this.message});

  final bool isLoading;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: isLoading
            ? _ManagedAzkarDialogColors.accent.withValues(alpha: 0.12)
            : _ManagedAzkarDialogColors.cardBackground.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isLoading
              ? _ManagedAzkarDialogColors.accent.withValues(alpha: 0.45)
              : _ManagedAzkarDialogColors.cardBorder,
        ),
      ),
      child: Row(
        textDirection: ui.TextDirection.rtl,
        children: [
          if (isLoading)
            SizedBox(
              width: 18.r,
              height: 18.r,
              child: CircularProgressIndicator(
                strokeWidth: 2.2.r,
                color: _ManagedAzkarDialogColors.accent,
              ),
            )
          else
            Icon(
              Icons.info_outline_rounded,
              color: _ManagedAzkarDialogColors.accent,
              size: 18.r,
            ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              isLoading ? 'جاري تجهيز المحتوى...' : (message ?? ''),
              textAlign: TextAlign.right,
              textDirection: ui.TextDirection.rtl,
              style: TextStyle(
                color: _ManagedAzkarDialogColors.secondaryText,
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ManagedAzkarEditorFormState extends State<_ManagedAzkarEditorForm> {
  late final TextEditingController _textController;
  late final Set<int> _selectedPrayerIds;
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  bool _isImporting = false;
  String? _importMessage;

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
      AzkarPrayerScopeHelper.normalizePrayerIds(_selectedPrayerIds),
    );

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _runImportAction(Future<String?> Function()? action) async {
    if (action == null) return;

    setState(() {
      _isImporting = true;
      _importMessage = null;
    });

    String? message;
    try {
      message = await action();
    } catch (_) {
      message = 'حدث خطأ أثناء الاستيراد. جرّب اللصق الجماعي أو ملفًا أبسط.';
    }

    if (!mounted) return;
    setState(() {
      _isImporting = false;
      _importMessage = message ?? 'لم يتم اختيار محتوى للاستيراد.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final sizing = DialogConfig.getSizing(context);
    final canImport =
        widget.initialEntry == null &&
        widget.onImportFile != null &&
        widget.onPasteBulk != null;
    final prayerHelpText = widget.type == AzkarType.afterPrayer
        ? 'اترك الاختيارات فارغة إذا أردت إظهار الذكر بعد كل الصلوات.'
        : 'اترك الاختيارات فارغة للحفاظ على الموعد الافتراضي لهذا القسم، أو اختر صلاة محددة ليظهر الذكر بعدها.';

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (canImport) ...[
            _EditorImportPanel(
              onImportFile: () => _runImportAction(widget.onImportFile),
              onPasteBulk: () => _runImportAction(widget.onPasteBulk),
            ),
            if (_isImporting || _importMessage != null) ...[
              SizedBox(height: sizing.verticalGap * 0.35),
              _ImportStatusMessage(
                isLoading: _isImporting,
                message: _importMessage,
              ),
            ],
            SizedBox(height: sizing.verticalGap * 0.75),
          ],
          VirtualTextField(
            controller: _textController,
            maxLines: 8,
            enablePasteAction: true,
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
          SizedBox(height: sizing.verticalGap * 0.3),
          Text(
            'يمكنك النسخ من مصدر خارجي ثم استخدام زر اللصق. سيتم تنظيف الرموز غير المرئية وتنسيق الأسطر قبل الحفظ.',
            style: TextStyle(
              color: _ManagedAzkarDialogColors.mutedText,
              fontSize: sizing.bodyFontSize * 0.84,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: sizing.verticalGap * 0.7),
          Text(
            'الصلوات المعنية',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _ManagedAzkarDialogColors.primaryText,
              fontSize: sizing.bodyFontSize,
            ),
          ),
          SizedBox(height: sizing.verticalGap * 0.25),
          Text(
            prayerHelpText,
            style: TextStyle(
              color: _ManagedAzkarDialogColors.secondaryText,
              fontSize: sizing.bodyFontSize * 0.9,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: sizing.verticalGap * 0.35),
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: AzkarPrayerScopeHelper.editablePrayerIds
                .map((prayerId) {
                  final selected = _selectedPrayerIds.contains(prayerId);
                  const unselectedChipBackground = Color(0xFFE8E1D7);
                  const unselectedChipText = Color(0xFF243243);
                  const selectedChipText = Color(0xFF102027);
                  return FilterChip(
                    key: ValueKey('managed-azkar-prayer-$prayerId'),
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
                    selectedColor: AppTheme.accentColor,
                    checkmarkColor: selectedChipText,
                    backgroundColor: unselectedChipBackground,
                    surfaceTintColor: Colors.transparent,
                    shadowColor: Colors.black.withValues(alpha: 0.18),
                    elevation: selected ? 1.5 : 0,
                    pressElevation: 2,
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 8.h,
                    ),
                    side: BorderSide(
                      color: selected
                          ? Colors.white.withValues(alpha: 0.70)
                          : const Color(0xFFC9BFB1),
                      width: selected ? 1.4 : 1.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    labelStyle: TextStyle(
                      color: selected ? selectedChipText : unselectedChipText,
                      fontWeight: FontWeight.w900,
                      shadows: selected
                          ? null
                          : const [
                              Shadow(
                                color: Color(0x33FFFFFF),
                                offset: Offset(0, 1),
                                blurRadius: 1,
                              ),
                            ],
                    ),
                  );
                })
                .toList(growable: false),
          ),
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
