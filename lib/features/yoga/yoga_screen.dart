import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../core/providers/period_provider.dart';
import 'models/yoga_data.dart';

class YogaScreen extends StatefulWidget {
  const YogaScreen({super.key});

  @override
  State<YogaScreen> createState() => _YogaScreenState();
}

class _YogaScreenState extends State<YogaScreen> {
  int _selectedDay = 1;
  bool _isInitialized = false;
  CyclePhase? _expandedPhase; // Tracks which accordion is open
  String? _expandedPoseName; // Tracks which pose is open
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final periodProvider = context.read<PeriodProvider>();
      final day = periodProvider.currentCycleDay;
      _selectedDay = day.clamp(1, 28);
      _expandedPhase = _getPhaseForDay(_selectedDay);
      _isInitialized = true;
    }
  }

  CyclePhase _getPhaseForDay(int day) {
    if (day >= 1 && day <= 5) return CyclePhase.menstrual;
    if (day >= 6 && day <= 13) return CyclePhase.follicular;
    if (day >= 14 && day <= 16) return CyclePhase.ovulation;
    return CyclePhase.luteal;
  }

  @override
  Widget build(BuildContext context) {
    final activePhase = _getPhaseForDay(_selectedDay);
    final activeData = yogaPhasesData.firstWhere((p) => p.phase == activePhase);

    return Scaffold(
      backgroundColor: AppColors.surfaceBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text('Cycle Yoga', style: AppTextStyles.appTitle),
              const SizedBox(height: 4),
              Text(
                'Movement for every phase',
                style: AppTextStyles.body.copyWith(color: AppColors.textLight),
              ),
              const SizedBox(height: 20),
              _buildDaySelector(activeData),
              const SizedBox(height: 24),
              _buildTodayPhaseCard(activeData),
              const SizedBox(height: 24),
              Text('ALL PHASES', style: AppTextStyles.label),
              const SizedBox(height: 12),
              ...yogaPhasesData.map((data) => _buildPhaseAccordion(data)),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDaySelector(YogaPhaseData activeData) {
    return Container(
      decoration: AppDecorations.card,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Day', style: AppTextStyles.body),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.phaseColor(
                    activeData.phase,
                  ).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_selectedDay',
                  style: AppTextStyles.sectionTitle.copyWith(
                    color: AppColors.phaseColor(activeData.phase),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.phaseColor(activeData.phase),
              inactiveTrackColor: AppColors.cardBorder,
              thumbColor: AppColors.phaseColor(activeData.phase),
              trackHeight: 6,
            ),
            child: Slider(
              value: _selectedDay.toDouble(),
              min: 1,
              max: 28,
              divisions: 27,
              onChanged: (val) {
                setState(() {
                  _selectedDay = val.round();
                  _expandedPhase = _getPhaseForDay(_selectedDay);
                });
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('1', style: AppTextStyles.small),
              Text('28', style: AppTextStyles.small),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodayPhaseCard(YogaPhaseData data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.phaseBgColor(data.phase),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.phaseColor(data.phase).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Text(data.emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Phase',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.phaseColor(data.phase),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.name,
                  style: AppTextStyles.sectionTitle.copyWith(
                    color: AppColors.phaseColor(
                      data.phase,
                    ).withOpacity(1), // Ensure high contrast
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.tagline,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseAccordion(YogaPhaseData data) {
    final isExpanded = _expandedPhase == data.phase;
    final color = AppColors.phaseColor(data.phase);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isExpanded
            ? AppColors.cardBackground
            : AppColors.surfaceBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isExpanded
              ? color.withValues(alpha: 0.5)
              : AppColors.cardBorder,
        ),
        boxShadow: isExpanded
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _expandedPhase = isExpanded ? null : data.phase;
                  _expandedPoseName = null;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(data.emoji, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data.name, style: AppTextStyles.sectionTitle),
                          Text(data.days, style: AppTextStyles.small),
                        ],
                      ),
                    ),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: color,
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity),
              secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: _buildAccordionContent(data, color),
              ),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccordionContent(YogaPhaseData data, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Description
        Text(data.description, style: AppTextStyles.body),
        const SizedBox(height: 16),

        // Hormone & Energy Cards
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildInfoCard('HORMONES', data.hormone, color)),
            const SizedBox(width: 8),
            Expanded(child: _buildInfoCard('ENERGY', data.energy, color)),
          ],
        ),
        const SizedBox(height: 24),

        // Poses
        Text(
          'RECOMMENDED POSES',
          style: AppTextStyles.label.copyWith(color: color),
        ),
        const SizedBox(height: 12),
        ...data.poses.map((pose) => _buildPoseCard(pose, color)),
        const SizedBox(height: 24),

        // Videos
        Text(
          'GUIDED PRACTICES',
          style: AppTextStyles.label.copyWith(color: color),
        ),
        const SizedBox(height: 12),
        ...data.videos.map((video) => _buildVideoCard(video, color)),
        const SizedBox(height: 24),

        // Breathwork
        Text('BREATHWORK', style: AppTextStyles.label.copyWith(color: color)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.breathwork.name,
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(data.breathwork.description, style: AppTextStyles.body),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Avoid
        Text(
          'WHAT TO AVOID',
          style: AppTextStyles.label.copyWith(color: Colors.redAccent),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.redAccent.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: data.avoid
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '✕',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(item, style: AppTextStyles.body)),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 24),

        // Nutrition
        Text('NUTRITION', style: AppTextStyles.label.copyWith(color: color)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Text(data.nutrition, style: AppTextStyles.body),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String content, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.label.copyWith(color: color)),
          const SizedBox(height: 4),
          Text(content, style: AppTextStyles.body.copyWith(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildPoseCard(PoseData pose, Color color) {
    final isExpanded = _expandedPoseName == pose.name;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isExpanded ? color.withValues(alpha: 0.05) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              setState(() {
                _expandedPoseName = isExpanded ? null : pose.name;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Row(
                children: [
                  Text(pose.icon, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pose.english,
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          pose.name,
                          style: AppTextStyles.small.copyWith(
                            fontStyle: FontStyle.italic,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 12,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(pose.duration, style: AppTextStyles.small),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Benefit',
                      style: AppTextStyles.label.copyWith(color: color),
                    ),
                    const SizedBox(height: 4),
                    Text(pose.benefit, style: AppTextStyles.body),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: color.withValues(alpha: 0.2),
                          foregroundColor: color,
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.play_circle_outline, size: 20),
                        label: const Text('Learn this pose'),
                        onPressed: () async {
                          final query = Uri.encodeComponent('${pose.english} ${pose.name} yoga tutorial');
                          final uri = Uri.parse('https://www.youtube.com/results?search_query=$query');
                          try {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          } catch (e) {
                            debugPrint('Could not launch $uri: $e');
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCard(VideoData video, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () async {
          final uri = Uri.parse(video.url);
          try {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } catch (e) {
            debugPrint('Could not launch ${video.url}: $e');
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.surfaceBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        video.thumbnail,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const Positioned(
                        bottom: 0,
                        right: 0,
                        child: Icon(
                          Icons.play_circle_fill,
                          color: Colors.red,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.person,
                          size: 12,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            video.channel,
                            style: AppTextStyles.small,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 12,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(video.duration, style: AppTextStyles.small),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.open_in_new_rounded,
                size: 20,
                color: AppColors.textMuted.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
