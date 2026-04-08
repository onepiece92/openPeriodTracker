import '../../../core/theme/app_theme.dart';

class VideoData {
  final String title;
  final String channel;
  final String url;
  final String duration;
  final String thumbnail;

  const VideoData({
    required this.title,
    required this.channel,
    required this.url,
    required this.duration,
    required this.thumbnail,
  });
}

class PoseData {
  final String name;
  final String english;
  final String duration;
  final String icon;
  final String benefit;

  const PoseData({
    required this.name,
    required this.english,
    required this.duration,
    required this.icon,
    required this.benefit,
  });
}

class BreathworkData {
  final String name;
  final String description;

  const BreathworkData({required this.name, required this.description});
}

class YogaPhaseData {
  final CyclePhase phase;
  final String name;
  final String days;
  final String emoji;
  final String tagline;
  final String hormone;
  final String energy;
  final String description;
  final List<PoseData> poses;
  final BreathworkData breathwork;
  final List<String> avoid;
  final String nutrition;
  final List<VideoData> videos;

  const YogaPhaseData({
    required this.phase,
    required this.name,
    required this.days,
    required this.emoji,
    required this.tagline,
    required this.hormone,
    required this.energy,
    required this.description,
    required this.poses,
    required this.breathwork,
    required this.avoid,
    required this.nutrition,
    required this.videos,
  });
}

const List<YogaPhaseData> yogaPhasesData = [
  YogaPhaseData(
    phase: CyclePhase.menstrual,
    name: 'Menstrual Phase',
    days: 'Days 1–5',
    emoji: '🌙',
    tagline: 'Rest & Release',
    description:
        'Theme: Inner winter. Lowest hormones. Prioritize rest, gentle movement, and introspection.',
    hormone: 'Estrogen & progesterone at their lowest. Uterine lining sheds.',
    energy: 'Low — body is working hard internally.',
    poses: [
      PoseData(
        name: 'Supta Baddha Konasana',
        english: 'Reclining Bound Angle Pose',
        duration: '5–10 min',
        icon: '🦋',
        benefit: 'Opens hips/groin, relieves cramps, calms mind',
      ),
      PoseData(
        name: 'Balasana',
        english: 'Supported Child\'s Pose',
        duration: '3–5 min',
        icon: '👶',
        benefit: 'Compresses abdomen to relieve cramps, calms nervous system',
      ),
      PoseData(
        name: 'Supta Matsyendrasana',
        english: 'Supine Spinal Twist',
        duration: '2–3 min/side',
        icon: '🌀',
        benefit: 'Relieves lower back tension, massages organs',
      ),
      PoseData(
        name: 'Viparita Karani',
        english: 'Supported Legs Up the Wall',
        duration: '5–15 min',
        icon: '🦵',
        benefit: 'Reduces swelling, deeply calming, improves circulation',
      ),
      PoseData(
        name: 'Savasana',
        english: 'Corpse Pose with Props',
        duration: '10–15 min',
        icon: '🧘',
        benefit: 'Total nervous system reset',
      ),
    ],
    breathwork: BreathworkData(
      name: 'Chandra Bhedana (Moon Breath)',
      description:
          'Inhale left nostril, exhale right. 5–10 minutes. Cooling and calming.',
    ),
    avoid: [
      'Intense core work',
      'Deep closed twists',
      'Prolonged inversions',
      'Hot yoga',
      'Power poses',
    ],
    nutrition:
        'Warming iron-rich foods (soups, stews, dark leafy greens, beets, dark chocolate). Herbal teas (ginger, chamomile).',
    videos: [
      VideoData(
        title: 'Yoga for Cramps & PMS — Restorative',
        channel: 'Yoga With Adriene',
        url:
            'https://www.youtube.com/results?search_query=Yoga+With+Adriene+Cramps+PMS+Restorative',
        duration: '20 min',
        thumbnail: '🌙',
      ),
      VideoData(
        title: 'Gentle Yoga for Your Period',
        channel: 'Sarah Beth Yoga',
        url:
            'https://www.youtube.com/results?search_query=Sarah+Beth+Yoga+Gentle+Yoga+for+Your+Period',
        duration: '15 min',
        thumbnail: '🌸',
      ),
      VideoData(
        title: 'Restorative Yoga for Menstruation',
        channel: 'Yoga With Bird',
        url:
            'https://www.youtube.com/results?search_query=Yoga+With+Bird+Restorative+Yoga+for+Menstruation',
        duration: '25 min',
        thumbnail: '🕊️',
      ),
      VideoData(
        title: 'Legs Up the Wall — Guided Relaxation',
        channel: 'Yoga With Kassandra',
        url:
            'https://www.youtube.com/results?search_query=Yoga+With+Kassandra+Legs+Up+the+Wall',
        duration: '10 min',
        thumbnail: '🧱',
      ),
    ],
  ),
  YogaPhaseData(
    phase: CyclePhase.follicular,
    name: 'Follicular Phase',
    days: 'Days 6–13',
    emoji: '🌱',
    tagline: 'Build & Bloom',
    description:
        'Theme: Inner spring. Rising estrogen. Time to challenge yourself, try new poses, build strength.',
    hormone: 'Estrogen rises steadily. FSH stimulates follicle growth.',
    energy: 'Rising — creative, social, physically capable.',
    poses: [
      PoseData(
        name: 'Surya Namaskar',
        english: 'Sun Salutations (A & B)',
        duration: '5–10 rounds',
        icon: '☀️',
        benefit: 'Full-body warm-up, builds heat and cardio endurance',
      ),
      PoseData(
        name: 'Virabhadrasana III',
        english: 'Warrior III',
        duration: '30–60 sec/side',
        icon: '⚔️',
        benefit: 'Balance, core strength, focus',
      ),
      PoseData(
        name: 'Bakasana',
        english: 'Crow Pose',
        duration: '15–30 sec',
        icon: '🦅',
        benefit: 'Arm/core strength, builds confidence',
      ),
      PoseData(
        name: 'Natarajasana',
        english: 'Dancer\'s Pose',
        duration: '30 sec/side',
        icon: '💃',
        benefit: 'Deep backbend, balance, opens chest/shoulders',
      ),
      PoseData(
        name: 'Ustrasana',
        english: 'Camel Pose',
        duration: '30–60 sec',
        icon: '🐪',
        benefit: 'Opens entire front body, energizing heart opener',
      ),
    ],
    breathwork: BreathworkData(
      name: 'Kapalabhati (Skull-Shining Breath)',
      description:
          'Short powerful exhales, passive inhales. 30 pumps × 3 rounds. Energizing.',
    ),
    avoid: ['Being overly cautious', 'Skipping warm-ups', 'Ignoring alignment'],
    nutrition:
        'Light fresh foods (salads, fermented foods, lean proteins, sprouted grains, fresh fruits, cruciferous vegetables).',
    videos: [
      VideoData(
        title: 'Sun Salutation A & B — Full Tutorial',
        channel: 'Yoga With Adriene',
        url:
            'https://www.youtube.com/results?search_query=Yoga+With+Adriene+Sun+Salutation+Tutorial',
        duration: '15 min',
        thumbnail: '☀️',
      ),
      VideoData(
        title: 'Power Vinyasa Flow — Build Strength',
        channel: 'Boho Beautiful',
        url:
            'https://www.youtube.com/results?search_query=Boho+Beautiful+Power+Vinyasa+Flow',
        duration: '30 min',
        thumbnail: '💪',
      ),
      VideoData(
        title: 'Crow Pose Tutorial for Beginners',
        channel: 'Yoga With Kassandra',
        url:
            'https://www.youtube.com/results?search_query=Yoga+With+Kassandra+Crow+Pose',
        duration: '12 min',
        thumbnail: '🦅',
      ),
      VideoData(
        title: 'Energizing Morning Yoga Flow',
        channel: 'Breathe and Flow',
        url:
            'https://www.youtube.com/results?search_query=Breathe+and+Flow+Energizing+Morning+Yoga',
        duration: '25 min',
        thumbnail: '🌅',
      ),
    ],
  ),
  YogaPhaseData(
    phase: CyclePhase.ovulation,
    name: 'Ovulatory Phase',
    days: 'Days 14–16',
    emoji: '🔥',
    tagline: 'Peak & Power',
    description:
        'Theme: Inner summer. Peak estrogen + testosterone spike. Maximum strength, confidence, social energy. Go all out.',
    hormone: 'Estrogen peaks. LH surge triggers ovulation.',
    energy: 'Highest — magnetic, strong, communicative, confident.',
    poses: [
      PoseData(
        name: 'Utkata Konasana',
        english: 'Goddess Pose',
        duration: '1–2 min',
        icon: '👑',
        benefit: 'Empowering, builds lower body strength, activates pelvic floor',
      ),
      PoseData(
        name: 'Adho Mukha Vrksasana',
        english: 'Handstand',
        duration: 'Practice attempts',
        icon: '🤸',
        benefit: 'Ultimate upper body/core strength, fearlessness',
      ),
      PoseData(
        name: 'Eka Pada Koundinyasana II',
        english: 'Flying Splits',
        duration: '15–30 sec/side',
        icon: '✈️',
        benefit: 'Arm balance combining strength, flexibility, courage',
      ),
      PoseData(
        name: 'Urdhva Dhanurasana',
        english: 'Full Wheel Pose',
        duration: '30 sec × 3',
        icon: '🎡',
        benefit: 'Deep backbend, opens entire front body',
      ),
      PoseData(
        name: 'Hanumanasana',
        english: 'Full Splits',
        duration: '1–2 min/side',
        icon: '🐒',
        benefit: 'Deep hip flexor/hamstring opening',
      ),
    ],
    breathwork: BreathworkData(
      name: 'Bhastrika (Bellows Breath)',
      description:
          'Rapid forceful inhales AND exhales. 20 breaths × 3 rounds. Extremely energizing.',
    ),
    avoid: [
      'Holding back',
      'Practicing in isolation',
      'Ignoring overexertion signs',
    ],
    nutrition:
        'Lighter meals (raw vegetables, fruits, whole grains, anti-inflammatory foods, fiber-rich foods). Stay hydrated.',
    videos: [
      VideoData(
        title: 'Advanced Power Vinyasa Flow',
        channel: 'Travis Eliot',
        url:
            'https://www.youtube.com/results?search_query=Travis+Eliot+Advanced+Power+Vinyasa',
        duration: '45 min',
        thumbnail: '🔥',
      ),
      VideoData(
        title: 'Handstand Tutorial',
        channel: 'Dylan Werner Yoga',
        url:
            'https://www.youtube.com/results?search_query=Dylan+Werner+Yoga+Handstand+Tutorial',
        duration: '20 min',
        thumbnail: '🤸',
      ),
      VideoData(
        title: 'Full Wheel Pose — Step by Step',
        channel: 'Yoga With Adriene',
        url:
            'https://www.youtube.com/results?search_query=Yoga+With+Adriene+Full+Wheel+Pose',
        duration: '15 min',
        thumbnail: '🎡',
      ),
      VideoData(
        title: 'Ashtanga Primary Series',
        channel: 'Kino Yoga',
        url:
            'https://www.youtube.com/results?search_query=Kino+Yoga+Ashtanga+Primary+Series',
        duration: '75 min',
        thumbnail: '⚡',
      ),
    ],
  ),
  YogaPhaseData(
    phase: CyclePhase.luteal,
    name: 'Luteal Phase',
    days: 'Days 17–28',
    emoji: '🍂',
    tagline: 'Slow & Soften',
    description:
        'Theme: Inner autumn. Progesterone dominates. Energy declines. PMS symptoms emerge. Slow down progressively.',
    hormone:
        'Progesterone rises. If no implantation, both hormones drop sharply before menstruation.',
    energy:
        'Declining — early luteal still moderate, late luteal significantly lower. PMS symptoms appear.',
    poses: [
      PoseData(
        name: 'Eka Pada Rajakapotasana',
        english: 'Pigeon Pose',
        duration: '3–5 min/side',
        icon: '🐦',
        benefit: 'Deep hip opener, releases emotional tension',
      ),
      PoseData(
        name: 'Paschimottanasana',
        english: 'Seated Forward Fold',
        duration: '3–5 min',
        icon: '🥨',
        benefit: 'Calms nervous system, massages organs, reduces anxiety',
      ),
      PoseData(
        name: 'Baddha Konasana',
        english: 'Bound Angle / Butterfly',
        duration: '3–5 min',
        icon: '🦋',
        benefit: 'Opens inner thighs/groin, eases bloating',
      ),
      PoseData(
        name: 'Utthan Pristhasana',
        english: 'Lizard Pose',
        duration: '2–3 min/side',
        icon: '🦎',
        benefit: 'Deep hip flexor stretch, releases lower body tension',
      ),
      PoseData(
        name: 'Setu Bandhasana',
        english: 'Supported Bridge',
        duration: '5 min',
        icon: '🌉',
        benefit: 'Gentle backbend, opens chest, calms brain, reduces fatigue',
      ),
    ],
    breathwork: BreathworkData(
      name: 'Nadi Shodhana (Alternate Nostril Breathing)',
      description:
          'Inhale left, exhale right, inhale right, exhale left = 1 round. 10–15 rounds. Balances nervous system.',
    ),
    avoid: [
      'Pushing for personal bests',
      'Hot yoga (body temp already elevated)',
      'Ignoring cravings',
      'Comparing energy to other phases',
      'Intense core work if bloated',
    ],
    nutrition:
        'Complex carbs (sweet potatoes, brown rice, oats). Magnesium-rich foods (dark chocolate, nuts, bananas). Calcium and B6. Reduce salt.',
    videos: [
      VideoData(
        title: 'Yin Yoga for PMS & Luteal Phase',
        channel: 'Yoga With Kassandra',
        url:
            'https://www.youtube.com/results?search_query=Yoga+With+Kassandra+Yin+Yoga+PMS',
        duration: '30 min',
        thumbnail: '🍂',
      ),
      VideoData(
        title: 'Deep Hip Opener — Pigeon Pose Flow',
        channel: 'Yoga With Adriene',
        url:
            'https://www.youtube.com/results?search_query=Yoga+With+Adriene+Pigeon+Pose',
        duration: '20 min',
        thumbnail: '🐦',
      ),
      VideoData(
        title: 'Yoga for Anxiety & Stress Relief',
        channel: 'Boho Beautiful',
        url:
            'https://www.youtube.com/results?search_query=Boho+Beautiful+Yoga+Anxiety',
        duration: '20 min',
        thumbnail: '☁️',
      ),
      VideoData(
        title: 'Alternate Nostril Breathing — Guided',
        channel: 'Yoga With Adriene',
        url:
            'https://www.youtube.com/results?search_query=Yoga+With+Adriene+Alternate+Nostril+Breathing',
        duration: '8 min',
        thumbnail: '🌬️',
      ),
    ],
  ),
];
