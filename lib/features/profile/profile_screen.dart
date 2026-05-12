import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/providers/period_provider.dart';
import '../../core/providers/daily_log_provider.dart';
import '../../core/widgets/mood_selector.dart';
import '../../core/services/demo_data_service.dart';
import '../history/history_view.dart';
import '../../core/services/notification_service.dart';
import 'domain/services/backup_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final periodProvider = context.watch<PeriodProvider>();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text('Profile', style: AppTextStyles.appTitle),
            const SizedBox(height: 4),
            Text(
              'Settings & data',
              style: AppTextStyles.body.copyWith(color: AppColors.textLight),
            ),
            const SizedBox(height: 24),

            // Personal info
            _PersonalInfoSection(),
            const SizedBox(height: 16),

            // Settings section
            Text('CYCLE SETTINGS', style: AppTextStyles.label),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              decoration: AppDecorations.card,
              child: Column(
                children: [
                  _EditableSetting(
                    icon: Icons.loop_rounded,
                    label: 'Cycle Length',
                    value: settingsProvider.cycleLength,
                    unit: 'days',
                    min: 20,
                    max: 45,
                    onChanged: (v) => settingsProvider.updateCycleLength(v),
                  ),
                  const Divider(height: 1, color: AppColors.cardBorder),
                  _EditableSetting(
                    icon: Icons.water_drop_rounded,
                    label: 'Period Length',
                    value: settingsProvider.periodLength,
                    unit: 'days',
                    min: 2,
                    max: 10,
                    onChanged: (v) => settingsProvider.updatePeriodLength(v),
                  ),
                  const Divider(height: 1, color: AppColors.cardBorder),
                  _SettingsTile(
                    icon: Icons.auto_graph_rounded,
                    label: 'Computed Avg Cycle',
                    value: '${periodProvider.averageCycleLength} days',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Cycle Length is a starting estimate. Once you log 2+ periods, predictions switch to your Computed Avg Cycle.',
              style: AppTextStyles.small.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),

            // Defaults section
            Text('DEFAULTS', style: AppTextStyles.label),
            const SizedBox(height: 4),
            Text(
              'Auto-applied when you mark a period day',
              style: AppTextStyles.small.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 8),
            _DefaultsSection(),
            const SizedBox(height: 16),

            // Dietary preferences
            Text('DIETARY PREFERENCES', style: AppTextStyles.label),
            const SizedBox(height: 4),
            Text(
              'Filters Diet tab recommendations',
              style: AppTextStyles.small.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 8),
            _DietPreferencesSection(),
            const SizedBox(height: 16),

            // Data section
            Text('DATA', style: AppTextStyles.label),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              decoration: AppDecorations.card,
              child: Column(
                children: [
                  _ActionTile(
                    icon: Icons.calendar_month_rounded,
                    label: 'Periods Logged (${periodProvider.periods.length})',
                    color: AppColors.follicular,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const _HistoryPage()),
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.cardBorder),
                  _ActionTile(
                    icon: Icons.delete_outline_rounded,
                    label: 'Reset All Data',
                    color: AppColors.menstrual,
                    onTap: () => _showResetDialog(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Notifications
            Text('NOTIFICATIONS', style: AppTextStyles.label),
            const SizedBox(height: 4),
            Text(
              'Daily reminders and cycle predictions',
              style: AppTextStyles.small.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              decoration: AppDecorations.card,
              child: Column(
                children: [
                  _ActionTile(
                    icon: Icons.notifications_active_rounded,
                    label: 'Enable Daily Reminder (8:00 PM)',
                    color: AppColors.textLight,
                    onTap: () async {
                      bool granted = await NotificationService()
                          .requestPermissions();
                      if (granted) {
                        await NotificationService().scheduleDailyReminder(
                          hour: 20,
                          minute: 0,
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Daily reminder scheduled for 8:00 PM',
                              ),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Export & Import
            Text('EXPORT & IMPORT', style: AppTextStyles.label),
            const SizedBox(height: 4),
            Text(
              'Securely backup or restore your cycle data in JSON format',
              style: AppTextStyles.small.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              decoration: AppDecorations.card,
              child: Column(
                children: [
                  _ActionTile(
                    icon: Icons.upload_file_rounded,
                    label: 'Export Backup (JSON)',
                    color: AppColors.follicular,
                    onTap: () async {
                      try {
                        await BackupService().exportDataToJSON();
                      } catch (e) {
                        if (context.mounted)
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(e.toString())));
                      }
                    },
                  ),
                  const Divider(height: 1, color: AppColors.cardBorder),
                  _ActionTile(
                    icon: Icons.download_rounded,
                    label: 'Restore from Backup (JSON)',
                    color: AppColors.luteal,
                    onTap: () => _showImportDialog(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Developer tools
            Text('DEVELOPER TOOLS', style: AppTextStyles.label),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              decoration: AppDecorations.card,
              child: Column(
                children: [
                  _ActionTile(
                    icon: Icons.science_rounded,
                    label: 'Import Demo Data (1 year)',
                    color: AppColors.follicular,
                    onTap: () => _showDemoDataDialog(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // About section
            Text('ABOUT', style: AppTextStyles.label),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              decoration: AppDecorations.card,
              child: const Column(
                children: [
                  _SettingsTile(
                    icon: Icons.info_outline_rounded,
                    label: 'Version',
                    value: '1.0.0',
                  ),
                  Divider(height: 1, color: AppColors.cardBorder),
                  _SettingsTile(
                    icon: Icons.shield_outlined,
                    label: 'Privacy',
                    value: '100% local',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showImportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Import JSON Backup?', style: AppTextStyles.sectionTitle),
        content: Text(
          'This will REPLACE all existing cycle and logging data with the JSON backup file. Your current data will be irrevocably deleted.\n\nOnly import valid Luna backups.',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: AppTextStyles.button.copyWith(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                bool success = await BackupService().importDataFromJSON();
                if (success && context.mounted) {
                  // Refresh UI state
                  await context.read<PeriodProvider>().loadPeriods();
                  if (!context.mounted) return;
                  await context.read<DailyLogProvider>().loadLogs();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Backup restored successfully'),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to restore backup')),
                  );
              }
            },
            child: Text(
              'Choose File',
              style: AppTextStyles.button.copyWith(color: AppColors.luteal),
            ),
          ),
        ],
      ),
    );
  }

  void _showDemoDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Import Demo Data?', style: AppTextStyles.sectionTitle),
        content: Text(
          'This will clear all existing data and generate 1 year of realistic period, flow, mood, and symptom data for testing.\n\nThis cannot be undone.',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: AppTextStyles.button.copyWith(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _generateDemoData(context);
            },
            child: Text(
              'Generate',
              style: AppTextStyles.button.copyWith(color: AppColors.follicular),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generateDemoData(BuildContext context) async {
    await DemoDataService().generate(
      settingsProv: context.read<SettingsProvider>(),
      periodProv: context.read<PeriodProvider>(),
      logProv: context.read<DailyLogProvider>(),
    );
  }



  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Reset Luna?', style: AppTextStyles.sectionTitle),
        content: Text(
          'This will delete all your data and return to the setup screen. This cannot be undone.',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: AppTextStyles.button.copyWith(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<SettingsProvider>().resetApp();
              if (!context.mounted) return;
              await context.read<PeriodProvider>().loadPeriods();
              if (!context.mounted) return;
              await context.read<DailyLogProvider>().loadLogs();
            },
            child: Text(
              'Reset',
              style: AppTextStyles.button.copyWith(color: AppColors.menstrual),
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonalInfoSection extends StatefulWidget {
  @override
  State<_PersonalInfoSection> createState() => _PersonalInfoSectionState();
}

class _PersonalInfoSectionState extends State<_PersonalInfoSection> {
  late TextEditingController _nameCtrl;
  late TextEditingController _nicknameCtrl;
  bool _initialized = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nicknameCtrl.dispose();
    super.dispose();
  }

  void _initControllers(SettingsProvider settings) {
    if (!_initialized) {
      _nameCtrl = TextEditingController(text: settings.userName ?? '');
      _nicknameCtrl = TextEditingController(text: settings.userNickname ?? '');
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    _initControllers(settings);
    final age = settings.userAge;
    final birthday = settings.userBirthday;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + display name
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.lutealBg,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.luteal.withValues(alpha: 0.3),
                  ),
                ),
                child: const Center(
                  child: Text('🌙', style: TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      settings.displayName,
                      style: AppTextStyles.sectionTitle.copyWith(fontSize: 16),
                    ),
                    if (age != null)
                      Text(
                        '$age years old',
                        style: AppTextStyles.small.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    Text(
                      'All data stored locally',
                      style: AppTextStyles.small.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Name
          Text('NAME', style: AppTextStyles.label),
          const SizedBox(height: 6),
          _field(
            controller: _nameCtrl,
            hint: 'Your name',
            onChanged: (v) => settings.updateUserInfo(name: v),
          ),
          const SizedBox(height: 12),

          // Nickname
          Text('NICKNAME', style: AppTextStyles.label),
          const SizedBox(height: 6),
          _field(
            controller: _nicknameCtrl,
            hint: 'What should Luna call you?',
            onChanged: (v) => settings.updateUserInfo(nickname: v),
          ),
          const SizedBox(height: 12),

          // Birthday
          Text('BIRTHDAY', style: AppTextStyles.label),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: birthday != null
                    ? DateTime.parse(birthday)
                    : DateTime(2000, 1, 1),
                firstDate: DateTime(1940),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                final dateStr =
                    '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                settings.updateUserInfo(birthday: dateStr);
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.inputBorder),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      birthday != null
                          ? '${_monthName(DateTime.parse(birthday).month)} ${DateTime.parse(birthday).day}, ${DateTime.parse(birthday).year}'
                          : 'Tap to set birthday',
                      style: AppTextStyles.body.copyWith(
                        color: birthday != null
                            ? AppColors.textPrimary
                            : AppColors.textMuted,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.calendar_month,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                  if (birthday != null && age != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.follicularBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$age y/o',
                        style: AppTextStyles.small.copyWith(
                          color: AppColors.follicular,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required ValueChanged<String> onChanged,
  }) {
    return TextField(
      controller: controller,
      style: AppTextStyles.body,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.textMuted),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.luteal),
        ),
      ),
      onChanged: onChanged,
    );
  }

  String _monthName(int m) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[m - 1];
  }
}

class _DefaultsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final currentFlow = settings.defaultFlow;
    final currentMoods = settings.defaultMoods;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Default flow
          Text('DEFAULT FLOW', style: AppTextStyles.label),
          const SizedBox(height: 8),
          Row(
            children: [
              _FlowOption(
                label: 'Light',
                drops: 1,
                isSelected: currentFlow == 'light',
                onTap: () => settings.updateDefaultFlow(
                  currentFlow == 'light' ? null : 'light',
                ),
              ),
              const SizedBox(width: 8),
              _FlowOption(
                label: 'Medium',
                drops: 2,
                isSelected: currentFlow == 'medium',
                onTap: () => settings.updateDefaultFlow(
                  currentFlow == 'medium' ? null : 'medium',
                ),
              ),
              const SizedBox(width: 8),
              _FlowOption(
                label: 'Heavy',
                drops: 3,
                isSelected: currentFlow == 'heavy',
                onTap: () => settings.updateDefaultFlow(
                  currentFlow == 'heavy' ? null : 'heavy',
                ),
              ),
              const SizedBox(width: 8),
              if (currentFlow != null)
                GestureDetector(
                  onTap: () => settings.updateDefaultFlow(null),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.cardBorder.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 14,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Default moods
          Text('DEFAULT MOODS', style: AppTextStyles.label),
          const SizedBox(height: 8),
          MoodSelector(
            selected: currentMoods,
            onChanged: (moods) => settings.updateDefaultMoods(moods),
          ),
          if (currentMoods.isNotEmpty) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => settings.updateDefaultMoods([]),
              child: Text(
                'Clear all defaults',
                style: AppTextStyles.small.copyWith(
                  color: AppColors.menstrual,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DietPreferencesSection extends StatelessWidget {
  static const List<({String key, String label})> _dietTypes = [
    (key: 'omnivore', label: 'Omnivore'),
    (key: 'vegetarian', label: 'Vegetarian'),
    (key: 'vegan', label: 'Vegan'),
    (key: 'pescatarian', label: 'Pescatarian'),
    (key: 'halal', label: 'Halal'),
    (key: 'kosher', label: 'Kosher'),
  ];

  static const List<({String key, String label})> _allergyTags = [
    (key: 'dairy', label: 'Dairy'),
    (key: 'gluten', label: 'Gluten'),
    (key: 'nuts', label: 'Nuts'),
    (key: 'eggs', label: 'Eggs'),
    (key: 'soy', label: 'Soy'),
    (key: 'shellfish', label: 'Shellfish'),
    (key: 'fish', label: 'Fish'),
  ];

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final dietType = settings.dietType;
    final allergies = settings.allergies;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppDecorations.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DIET TYPE', style: AppTextStyles.label),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _dietTypes.map((d) {
              final selected = dietType == d.key;
              return GestureDetector(
                onTap: () => settings.updateDietType(selected ? null : d.key),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.luteal : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected
                          ? AppColors.luteal
                          : AppColors.inputBorder,
                    ),
                  ),
                  child: Text(
                    d.label,
                    style: AppTextStyles.small.copyWith(
                      color: selected ? Colors.white : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Text('AVOID / ALLERGIES', style: AppTextStyles.label),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _allergyTags.map((t) {
              final selected = allergies.contains(t.key);
              return GestureDetector(
                onTap: () {
                  final next = List<String>.from(allergies);
                  if (selected) {
                    next.remove(t.key);
                  } else {
                    next.add(t.key);
                  }
                  settings.updateAllergies(next);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.menstrual.withValues(alpha: 0.15)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected
                          ? AppColors.menstrual
                          : AppColors.inputBorder,
                    ),
                  ),
                  child: Text(
                    t.label,
                    style: AppTextStyles.small.copyWith(
                      color: selected
                          ? AppColors.menstrual
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _FlowOption extends StatelessWidget {
  final String label;
  final int drops;
  final bool isSelected;
  final VoidCallback onTap;

  const _FlowOption({
    required this.label,
    required this.drops,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.menstrualBg : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.menstrual : AppColors.cardBorder,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  drops,
                  (_) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: Icon(
                      Icons.water_drop,
                      size: 14,
                      color: isSelected
                          ? AppColors.menstrual
                          : AppColors.textMuted,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: AppTextStyles.small.copyWith(
                  color: isSelected ? AppColors.menstrual : AppColors.textMuted,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditableSetting extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final String unit;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _EditableSetting({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textLight),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: AppTextStyles.body)),
          GestureDetector(
            onTap: () {
              final newVal = value - 1;
              if (newVal >= min) onChanged(newVal);
            },
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.cardBorder,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.remove,
                size: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '$value $unit',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              final newVal = value + 1;
              if (newVal <= max) onChanged(newVal);
            },
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.cardBorder,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.add,
                size: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textLight),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: AppTextStyles.body)),
          Text(
            value,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 12),
            Text(label, style: AppTextStyles.body.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}

class _HistoryPage extends StatelessWidget {
  const _HistoryPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text('Period History', style: AppTextStyles.appTitle),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // History content
              const Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: HistoryView(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
