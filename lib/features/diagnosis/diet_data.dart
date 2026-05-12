import '../../core/theme/app_theme.dart';

/// Maps a free-text food/dish name to a set of dietary tags it contains.
/// Used to filter recommendations by the user's diet type and allergies.
///
/// Heuristic substring match — case-insensitive. Order matters only for
/// readability; each rule sets an independent tag.
Set<String> classifyFood(String name) {
  final n = name.toLowerCase();
  final tags = <String>{};

  // Meat (any land animal flesh).
  const meatKeywords = [
    'beef', 'lamb', 'pork', 'ham', 'bacon', 'chicken', 'turkey', 'kofta',
    'meat', 'mutton', 'sausage', 'bhurji', 'venison', 'duck',
  ];
  for (final k in meatKeywords) {
    if (n.contains(k)) {
      tags.add('meat');
      break;
    }
  }
  if (n.contains('pork') || n.contains('ham') || n.contains('bacon')) {
    tags.add('pork');
  }

  // Fish / seafood.
  const fishKeywords = ['fish', 'salmon', 'tilapia', 'sardine', 'tuna',
    'mackerel', 'cod', 'anchovy', 'ceviche', 'pho'];
  for (final k in fishKeywords) {
    if (n.contains(k)) {
      tags.add('fish');
      break;
    }
  }
  const shellfishKeywords = ['shrimp', 'prawn', 'crab', 'lobster', 'oyster',
    'clam', 'mussel', 'scallop'];
  for (final k in shellfishKeywords) {
    if (n.contains(k)) {
      tags.add('shellfish');
      tags.add('fish'); // user avoiding fish likely avoids shellfish too
      break;
    }
  }

  // Dairy.
  const dairyKeywords = ['milk', 'yogurt', 'yoghurt', 'cheese', 'paneer',
    'butter', 'lassi', 'raita', 'doodh', 'cream', 'whey', 'kefir'];
  for (final k in dairyKeywords) {
    if (n.contains(k)) {
      tags.add('dairy');
      break;
    }
  }

  // Eggs.
  if (n.contains('egg') || n.contains('shakshuka') || n.contains('bhurji')) {
    tags.add('eggs');
  }

  // Gluten (wheat / barley / rye / common gluten-containing dishes).
  const glutenKeywords = ['bread', 'pasta', 'wheat', 'rye', 'barley', 'oat',
    'granola', 'tabbouleh', 'falafel', 'shakshuka', 'shorba', 'bourguignon',
    'wrap', 'toast', 'chapati', 'roti', 'naan'];
  for (final k in glutenKeywords) {
    if (n.contains(k)) {
      tags.add('gluten');
      break;
    }
  }

  // Nuts (excluding peanut which is technically a legume but commonly grouped).
  const nutKeywords = ['almond', 'walnut', 'cashew', 'pistachio', 'pecan',
    'hazelnut', 'macadamia', 'peanut', 'groundnut', 'pine nut', 'trail mix',
    'nut butter', 'halva'];
  for (final k in nutKeywords) {
    if (n.contains(k)) {
      tags.add('nuts');
      break;
    }
  }
  if (n.contains('seed') && (n.contains('sesame') || n.contains('til'))) {
    // sesame is a top allergen — group with nuts for the avoid filter
    tags.add('nuts');
  }

  // Soy.
  const soyKeywords = ['soy', 'tofu', 'tempeh', 'natto', 'edamame', 'miso'];
  for (final k in soyKeywords) {
    if (n.contains(k)) {
      tags.add('soy');
      break;
    }
  }

  // Alcohol.
  if (n.contains('wine') || n.contains('beer') || n.contains('alcohol')) {
    tags.add('alcohol');
  }

  return tags;
}

/// Resolves the set of food tags the user wants to avoid, based on their
/// diet type and explicit allergies.
Set<String> exclusionsFor(String? dietType, List<String> allergies) {
  final excl = <String>{};
  switch (dietType) {
    case 'vegan':
      excl.addAll({'meat', 'pork', 'fish', 'shellfish', 'dairy', 'eggs'});
      break;
    case 'vegetarian':
      excl.addAll({'meat', 'pork', 'fish', 'shellfish'});
      break;
    case 'pescatarian':
      excl.addAll({'meat', 'pork'});
      break;
    case 'halal':
      excl.addAll({'pork', 'alcohol'});
      break;
    case 'kosher':
      excl.addAll({'pork', 'shellfish'});
      break;
    case 'omnivore':
    case null:
      break;
  }
  excl.addAll(allergies);
  return excl;
}

/// Returns true if [name] should be filtered out given [exclusions].
bool foodIsExcluded(String name, Set<String> exclusions) {
  if (exclusions.isEmpty) return false;
  return classifyFood(name).intersection(exclusions).isNotEmpty;
}


const Map<CyclePhase, Map<String, int>> macrosByPhase = {
    CyclePhase.menstrual: {'carb': 45, 'protein': 30, 'fat': 25},
    CyclePhase.follicular: {'carb': 40, 'protein': 30, 'fat': 30},
    CyclePhase.ovulation: {'carb': 35, 'protein': 35, 'fat': 30},
    CyclePhase.luteal: {'carb': 50, 'protein': 25, 'fat': 25},
  };

const Map<CyclePhase, Map<String, String>> hydrationByPhase = {
    CyclePhase.menstrual: {
      'amount': '2.5–3L / day',
      'tip':
          'You lose extra fluids during your period. Add electrolytes or coconut water. Warm herbal teas count too.',
    },
    CyclePhase.follicular: {
      'amount': '2–2.5L / day',
      'tip':
          'Standard hydration. Add lemon or cucumber for flavor. Green tea is a great mid-morning boost.',
    },
    CyclePhase.ovulation: {
      'amount': '2.5L / day',
      'tip':
          'Estrogen peaks — your body runs warmer. Stay ahead of thirst. Watermelon and cucumber are hydrating snacks.',
    },
    CyclePhase.luteal: {
      'amount': '2.5–3L / day',
      'tip':
          'Progesterone causes water retention. Counterintuitively, drinking more water helps reduce bloating.',
    },
  };

const Map<CyclePhase, List<Map<String, String>>> supplementsByPhase =
      {
        CyclePhase.menstrual: [
          {
            'emoji': '🔴',
            'name': 'Iron (ferrous bisglycinate)',
            'dose': '18–25mg',
          },
          {'emoji': '🟤', 'name': 'Magnesium glycinate', 'dose': '200–400mg'},
          {'emoji': '🟡', 'name': 'Vitamin C', 'dose': '500mg'},
          {'emoji': '🟠', 'name': 'Omega-3 fish oil', 'dose': '1000mg'},
        ],
        CyclePhase.follicular: [
          {'emoji': '🟢', 'name': 'B-Complex', 'dose': '1 tablet'},
          {'emoji': '🟡', 'name': 'Vitamin E', 'dose': '200IU'},
          {'emoji': '🔵', 'name': 'Probiotic', 'dose': '10B CFU'},
          {'emoji': '🟠', 'name': 'Vitamin D3', 'dose': '2000IU'},
        ],
        CyclePhase.ovulation: [
          {'emoji': '🟢', 'name': 'Folate / Folic acid', 'dose': '400mcg'},
          {'emoji': '🔴', 'name': 'NAC (N-Acetyl Cysteine)', 'dose': '600mg'},
          {'emoji': '🟡', 'name': 'Vitamin C', 'dose': '500mg'},
          {'emoji': '🔵', 'name': 'CoQ10', 'dose': '100mg'},
        ],
        CyclePhase.luteal: [
          {'emoji': '🟤', 'name': 'Magnesium glycinate', 'dose': '300–400mg'},
          {'emoji': '🟡', 'name': 'Vitamin B6', 'dose': '50mg'},
          {'emoji': '🟠', 'name': 'Calcium', 'dose': '500mg'},
          {'emoji': '🔵', 'name': 'L-Theanine', 'dose': '200mg'},
        ],
      };
final Map<CyclePhase, Map<String, dynamic>> phaseNutrition = {
    CyclePhase.menstrual: {
      'summary':
          'Focus on replenishing iron and reducing inflammation. Warm, nourishing foods support recovery.',
      'vitamins': [
        {
          'emoji': '🔴',
          'name': 'Iron',
          'benefit': 'Replaces blood loss, prevents fatigue',
          'sources': 'Red meat, lentils, spinach, tofu',
        },
        {
          'emoji': '🟡',
          'name': 'Vitamin C',
          'benefit': 'Boosts iron absorption',
          'sources': 'Citrus fruits, bell peppers, broccoli',
        },
        {
          'emoji': '🟤',
          'name': 'Magnesium',
          'benefit': 'Reduces cramps and muscle tension',
          'sources': 'Dark chocolate, almonds, bananas',
        },
        {
          'emoji': '🟠',
          'name': 'Omega-3',
          'benefit': 'Anti-inflammatory, eases pain',
          'sources': 'Salmon, walnuts, flaxseeds',
        },
        {
          'emoji': '🔵',
          'name': 'Zinc',
          'benefit': 'Supports immune function',
          'sources': 'Pumpkin seeds, chickpeas, cashews',
        },
      ],
      'foods': [
        {'emoji': '🥩', 'name': 'Lean red meat'},
        {'emoji': '🥬', 'name': 'Spinach'},
        {'emoji': '🍫', 'name': 'Dark chocolate'},
        {'emoji': '🍲', 'name': 'Warm soups'},
        {'emoji': '🫘', 'name': 'Lentils'},
        {'emoji': '🍵', 'name': 'Ginger tea'},
        {'emoji': '🐟', 'name': 'Salmon'},
        {'emoji': '🥜', 'name': 'Walnuts'},
        {'emoji': '🍌', 'name': 'Bananas'},
      ],
      'avoid': [
        {
          'emoji': '☕',
          'name': 'Excess caffeine',
          'reason': 'worsens cramps and bloating',
        },
        {
          'emoji': '🧂',
          'name': 'High-sodium foods',
          'reason': 'increases water retention',
        },
        {
          'emoji': '🍷',
          'name': 'Alcohol',
          'reason': 'dehydrates and increases inflammation',
        },
        {
          'emoji': '🍬',
          'name': 'Refined sugar',
          'reason': 'spikes blood sugar, worsens mood swings',
        },
      ],
    },
    CyclePhase.follicular: {
      'summary':
          'Energy is rising. Fuel with lean proteins and fermented foods to support estrogen metabolism.',
      'vitamins': [
        {
          'emoji': '🟢',
          'name': 'B Vitamins',
          'benefit': 'Energy production and hormone balance',
          'sources': 'Eggs, leafy greens, whole grains',
        },
        {
          'emoji': '🟡',
          'name': 'Vitamin E',
          'benefit': 'Supports follicle development',
          'sources': 'Sunflower seeds, avocado, almonds',
        },
        {
          'emoji': '🔵',
          'name': 'Probiotics',
          'benefit': 'Gut health aids estrogen processing',
          'sources': 'Yogurt, kimchi, sauerkraut',
        },
        {
          'emoji': '🟠',
          'name': 'Vitamin D',
          'benefit': 'Hormone regulation and mood',
          'sources': 'Sunlight, fatty fish, fortified foods',
        },
      ],
      'foods': [
        {'emoji': '🥚', 'name': 'Eggs'},
        {'emoji': '🥗', 'name': 'Fresh salads'},
        {'emoji': '🥑', 'name': 'Avocado'},
        {'emoji': '🫚', 'name': 'Fermented foods'},
        {'emoji': '🍗', 'name': 'Lean chicken'},
        {'emoji': '🥦', 'name': 'Broccoli'},
        {'emoji': '🌰', 'name': 'Nuts & seeds'},
        {'emoji': '🫐', 'name': 'Berries'},
      ],
      'avoid': [
        {
          'emoji': '🍔',
          'name': 'Heavy fried foods',
          'reason': 'slows digestion when body wants lightness',
        },
        {
          'emoji': '🥤',
          'name': 'Sugary drinks',
          'reason': 'disrupts blood sugar balance',
        },
      ],
    },
    CyclePhase.ovulation: {
      'summary':
          'Peak energy and fertility. Support with antioxidants and liver-friendly foods for estrogen clearance.',
      'vitamins': [
        {
          'emoji': '🔴',
          'name': 'Antioxidants',
          'benefit': 'Protect egg quality',
          'sources': 'Berries, green tea, dark leafy greens',
        },
        {
          'emoji': '🟢',
          'name': 'Folate',
          'benefit': 'Cell division and fertility support',
          'sources': 'Asparagus, lentils, leafy greens',
        },
        {
          'emoji': '🟡',
          'name': 'Glutathione',
          'benefit': 'Liver detox, estrogen clearance',
          'sources': 'Cruciferous vegetables, garlic',
        },
        {
          'emoji': '🟤',
          'name': 'Fiber',
          'benefit': 'Removes excess estrogen',
          'sources': 'Whole grains, vegetables, fruits',
        },
      ],
      'foods': [
        {'emoji': '🫑', 'name': 'Bell peppers'},
        {'emoji': '🍅', 'name': 'Tomatoes'},
        {'emoji': '🥒', 'name': 'Raw veggies'},
        {'emoji': '🫐', 'name': 'Berries'},
        {'emoji': '🍍', 'name': 'Tropical fruits'},
        {'emoji': '🥕', 'name': 'Carrots'},
        {'emoji': '🧄', 'name': 'Garlic'},
        {'emoji': '🍵', 'name': 'Green tea'},
      ],
      'avoid': [
        {
          'emoji': '🍕',
          'name': 'Processed foods',
          'reason': 'inflammation during peak hormones',
        },
        {
          'emoji': '🥛',
          'name': 'Excess dairy',
          'reason': 'can increase estrogen load',
        },
        {
          'emoji': '☕',
          'name': 'Too much caffeine',
          'reason': 'may affect ovulation',
        },
      ],
    },
    CyclePhase.luteal: {
      'summary':
          'Progesterone rises, cravings hit. Stabilize blood sugar with complex carbs and magnesium.',
      'vitamins': [
        {
          'emoji': '🟤',
          'name': 'Magnesium',
          'benefit': 'Reduces PMS, calms anxiety',
          'sources': 'Pumpkin seeds, dark chocolate, spinach',
        },
        {
          'emoji': '🟡',
          'name': 'Vitamin B6',
          'benefit': 'Supports progesterone, reduces bloating',
          'sources': 'Chickpeas, potatoes, turkey',
        },
        {
          'emoji': '🟠',
          'name': 'Calcium',
          'benefit': 'Reduces mood swings and cramps',
          'sources': 'Yogurt, kale, sesame seeds',
        },
        {
          'emoji': '🔵',
          'name': 'Tryptophan',
          'benefit': 'Serotonin precursor, improves mood',
          'sources': 'Turkey, oats, pumpkin seeds',
        },
        {
          'emoji': '🔴',
          'name': 'Chromium',
          'benefit': 'Stabilizes blood sugar, curbs cravings',
          'sources': 'Broccoli, whole grains, green beans',
        },
      ],
      'foods': [
        {'emoji': '🍠', 'name': 'Sweet potato'},
        {'emoji': '🍚', 'name': 'Brown rice'},
        {'emoji': '🥔', 'name': 'Root vegetables'},
        {'emoji': '🍫', 'name': 'Dark chocolate'},
        {'emoji': '🎃', 'name': 'Pumpkin seeds'},
        {'emoji': '🦃', 'name': 'Turkey'},
        {'emoji': '🥣', 'name': 'Oatmeal'},
        {'emoji': '🥬', 'name': 'Kale'},
      ],
      'avoid': [
        {
          'emoji': '🧂',
          'name': 'Salty snacks',
          'reason': 'worsens bloating and water retention',
        },
        {
          'emoji': '🍬',
          'name': 'Refined sugar',
          'reason': 'blood sugar spikes worsen PMS',
        },
        {
          'emoji': '🍷',
          'name': 'Alcohol',
          'reason': 'disrupts sleep and worsens mood',
        },
        {
          'emoji': '☕',
          'name': 'Caffeine',
          'reason': 'increases anxiety and breast tenderness',
        },
      ],
    },
  };

final Map<String, Map<CyclePhase, List<Map<String, String>>>>
  regionalFoods = {
    'south_asian': {
      CyclePhase.menstrual: [
        {
          'emoji': '🍛',
          'name': 'Dal (lentil soup)',
          'why': 'Iron-rich, warming, easy to digest',
        },
        {
          'emoji': '🫚',
          'name': 'Haldi doodh (turmeric milk)',
          'why': 'Anti-inflammatory, reduces cramps',
        },
        {'emoji': '🥬', 'name': 'Palak paneer', 'why': 'Iron + calcium combo'},
        {
          'emoji': '🍚',
          'name': 'Khichdi',
          'why': 'Gentle on digestion, comforting',
        },
        {
          'emoji': '🌿',
          'name': 'Ajwain water',
          'why': 'Traditional remedy for period pain',
        },
      ],
      CyclePhase.follicular: [
        {
          'emoji': '🥗',
          'name': 'Sprouted moong salad',
          'why': 'Protein + folate for rising energy',
        },
        {
          'emoji': '🍳',
          'name': 'Egg bhurji',
          'why': 'B vitamins and lean protein',
        },
        {
          'emoji': '🫐',
          'name': 'Lassi with fruit',
          'why': 'Probiotics + vitamins',
        },
        {
          'emoji': '🥒',
          'name': 'Raita',
          'why': 'Cooling probiotic, aids digestion',
        },
      ],
      CyclePhase.ovulation: [
        {
          'emoji': '🥭',
          'name': 'Seasonal fruits (mango, papaya)',
          'why': 'Antioxidant-rich, supports fertility',
        },
        {
          'emoji': '🧄',
          'name': 'Garlic chutney',
          'why': 'Natural detox, liver support',
        },
        {
          'emoji': '🥕',
          'name': 'Gajar ka juice',
          'why': 'Beta-carotene for egg quality',
        },
      ],
      CyclePhase.luteal: [
        {
          'emoji': '🍠',
          'name': 'Shakarkandi chaat',
          'why': 'Complex carbs stabilize blood sugar',
        },
        {
          'emoji': '🍫',
          'name': 'Til ladoo (sesame)',
          'why': 'Calcium + magnesium for PMS',
        },
        {
          'emoji': '🍵',
          'name': 'Ashwagandha milk',
          'why': 'Adaptogenic, calms anxiety',
        },
        {
          'emoji': '🎃',
          'name': 'Kaddu sabzi (pumpkin)',
          'why': 'Magnesium-rich, reduces bloating',
        },
      ],
    },
    'east_asian': {
      CyclePhase.menstrual: [
        {
          'emoji': '🍜',
          'name': 'Bone broth / miso soup',
          'why': 'Warming, mineral-rich, restorative',
        },
        {
          'emoji': '🫚',
          'name': 'Ginger & jujube tea',
          'why': 'Traditional blood circulation remedy',
        },
        {
          'emoji': '🐟',
          'name': 'Steamed fish',
          'why': 'Omega-3 for inflammation',
        },
      ],
      CyclePhase.follicular: [
        {
          'emoji': '🥢',
          'name': 'Natto / fermented soy',
          'why': 'Probiotics + plant protein',
        },
        {
          'emoji': '🥬',
          'name': 'Bok choy stir-fry',
          'why': 'Folate and vitamin C',
        },
        {
          'emoji': '🍵',
          'name': 'Green tea',
          'why': 'Antioxidants, gentle energy',
        },
      ],
      CyclePhase.ovulation: [
        {
          'emoji': '🥒',
          'name': 'Seaweed salad',
          'why': 'Iodine + minerals for hormones',
        },
        {'emoji': '🫘', 'name': 'Edamame', 'why': 'Folate and plant protein'},
        {
          'emoji': '🍊',
          'name': 'Citrus fruits',
          'why': 'Vitamin C for estrogen clearance',
        },
      ],
      CyclePhase.luteal: [
        {
          'emoji': '🍚',
          'name': 'Congee / rice porridge',
          'why': 'Comforting, easy to digest',
        },
        {
          'emoji': '🌰',
          'name': 'Black sesame dessert',
          'why': 'Calcium + iron for PMS',
        },
        {
          'emoji': '🍠',
          'name': 'Roasted sweet potato',
          'why': 'Complex carbs curb cravings',
        },
      ],
    },
    'western': {
      CyclePhase.menstrual: [
        {
          'emoji': '🥩',
          'name': 'Grass-fed beef stew',
          'why': 'Iron and zinc replenishment',
        },
        {
          'emoji': '🍫',
          'name': 'Dark chocolate (70%+)',
          'why': 'Magnesium for cramp relief',
        },
        {
          'emoji': '🥣',
          'name': 'Warm oatmeal with berries',
          'why': 'Fiber + antioxidants',
        },
      ],
      CyclePhase.follicular: [
        {
          'emoji': '🥑',
          'name': 'Avocado toast with eggs',
          'why': 'Healthy fats + B vitamins',
        },
        {
          'emoji': '🫐',
          'name': 'Smoothie bowl',
          'why': 'Probiotics + fruit energy',
        },
        {
          'emoji': '🥗',
          'name': 'Quinoa salad',
          'why': 'Complete protein + iron',
        },
      ],
      CyclePhase.ovulation: [
        {'emoji': '🐟', 'name': 'Grilled salmon', 'why': 'Omega-3 + vitamin D'},
        {
          'emoji': '🥦',
          'name': 'Roasted cruciferous veggies',
          'why': 'Liver detox support',
        },
        {
          'emoji': '🫐',
          'name': 'Mixed berry bowl',
          'why': 'Antioxidant powerhouse',
        },
      ],
      CyclePhase.luteal: [
        {
          'emoji': '🍠',
          'name': 'Baked sweet potato',
          'why': 'Complex carb comfort',
        },
        {
          'emoji': '🦃',
          'name': 'Turkey & whole grain wrap',
          'why': 'Tryptophan for serotonin',
        },
        {'emoji': '🥜', 'name': 'Trail mix', 'why': 'Magnesium + healthy fats'},
      ],
    },
    'middle_eastern': {
      CyclePhase.menstrual: [
        {
          'emoji': '🍲',
          'name': 'Lentil shorba',
          'why': 'Iron-rich, warming comfort food',
        },
        {
          'emoji': '🫚',
          'name': 'Ginger & honey tea',
          'why': 'Anti-inflammatory, soothes cramps',
        },
        {
          'emoji': '🥩',
          'name': 'Lamb kofta',
          'why': 'Iron and B12 replenishment',
        },
      ],
      CyclePhase.follicular: [
        {
          'emoji': '🧆',
          'name': 'Falafel with tahini',
          'why': 'Plant protein + calcium',
        },
        {'emoji': '🥗', 'name': 'Tabbouleh', 'why': 'Fresh herbs + folate'},
        {
          'emoji': '🫒',
          'name': 'Olive oil & zaatar',
          'why': 'Healthy fats + antioxidants',
        },
      ],
      CyclePhase.ovulation: [
        {
          'emoji': '🐟',
          'name': 'Grilled fish with herbs',
          'why': 'Omega-3 for fertility',
        },
        {
          'emoji': '🥒',
          'name': 'Fattoush salad',
          'why': 'Raw veggies + antioxidants',
        },
        {
          'emoji': '🍋',
          'name': 'Lemon & mint water',
          'why': 'Detox and hydration',
        },
      ],
      CyclePhase.luteal: [
        {
          'emoji': '🍚',
          'name': 'Mujaddara (lentils & rice)',
          'why': 'Complex carbs + iron',
        },
        {
          'emoji': '🌰',
          'name': 'Halva with pistachios',
          'why': 'Sesame calcium + magnesium',
        },
        {
          'emoji': '🍵',
          'name': 'Chamomile tea',
          'why': 'Calming, reduces PMS anxiety',
        },
      ],
    },
    'african': {
      CyclePhase.menstrual: [
        {
          'emoji': '🍲',
          'name': 'Groundnut soup',
          'why': 'Iron + protein, warming',
        },
        {
          'emoji': '🥬',
          'name': 'Jute leaves (ewedu)',
          'why': 'High iron and folate',
        },
        {
          'emoji': '🫚',
          'name': 'Ginger & lemon',
          'why': 'Anti-inflammatory remedy',
        },
      ],
      CyclePhase.follicular: [
        {
          'emoji': '🫘',
          'name': 'Black-eyed peas',
          'why': 'Folate + protein boost',
        },
        {
          'emoji': '🥚',
          'name': 'Eggs & plantain',
          'why': 'B vitamins + potassium',
        },
        {
          'emoji': '🥗',
          'name': 'Fresh fruit salad',
          'why': 'Vitamin C + energy',
        },
      ],
      CyclePhase.ovulation: [
        {
          'emoji': '🐟',
          'name': 'Grilled tilapia',
          'why': 'Lean protein + omega-3',
        },
        {
          'emoji': '🥕',
          'name': 'Carrot & orange juice',
          'why': 'Antioxidants for fertility',
        },
        {
          'emoji': '🧄',
          'name': 'Garlic stew',
          'why': 'Liver support and detox',
        },
      ],
      CyclePhase.luteal: [
        {
          'emoji': '🍠',
          'name': 'Yam pottage',
          'why': 'Complex carbs ease cravings',
        },
        {'emoji': '🌰', 'name': 'Tiger nuts', 'why': 'Magnesium + fiber'},
        {
          'emoji': '🍵',
          'name': 'Hibiscus tea (zobo)',
          'why': 'Rich in vitamin C, calming',
        },
      ],
    },
    'latin_american': {
      CyclePhase.menstrual: [
        {
          'emoji': '🫘',
          'name': 'Frijoles negros (black beans)',
          'why': 'Iron + folate powerhouse',
        },
        {
          'emoji': '🍲',
          'name': 'Caldo de pollo',
          'why': 'Warming, nourishing broth',
        },
        {'emoji': '🍫', 'name': 'Cacao caliente', 'why': 'Magnesium + comfort'},
      ],
      CyclePhase.follicular: [
        {
          'emoji': '🥑',
          'name': 'Guacamole & veggies',
          'why': 'Healthy fats + vitamin E',
        },
        {
          'emoji': '🥭',
          'name': 'Tropical fruit bowl',
          'why': 'Vitamin C + natural energy',
        },
        {'emoji': '🌽', 'name': 'Elote', 'why': 'B vitamins + fiber'},
      ],
      CyclePhase.ovulation: [
        {
          'emoji': '🐟',
          'name': 'Ceviche',
          'why': 'Omega-3 + citrus antioxidants',
        },
        {
          'emoji': '🍅',
          'name': 'Pico de gallo',
          'why': 'Raw veggies + vitamin C',
        },
        {
          'emoji': '🫘',
          'name': 'Quinoa bowl',
          'why': 'Complete protein + minerals',
        },
      ],
      CyclePhase.luteal: [
        {
          'emoji': '🍠',
          'name': 'Camote (sweet potato)',
          'why': 'Complex carbs for cravings',
        },
        {
          'emoji': '🍌',
          'name': 'Plátano maduro',
          'why': 'Potassium + tryptophan',
        },
        {'emoji': '🍵', 'name': 'Manzanilla tea', 'why': 'Chamomile calms PMS'},
      ],
    },
    'southeast_asian': {
      CyclePhase.menstrual: [
        {
          'emoji': '🍜',
          'name': 'Pho / bone broth soup',
          'why': 'Warming, mineral-rich',
        },
        {
          'emoji': '🫚',
          'name': 'Ginger lemongrass tea',
          'why': 'Anti-inflammatory, eases cramps',
        },
        {
          'emoji': '🐟',
          'name': 'Steamed fish with turmeric',
          'why': 'Omega-3 + anti-inflammatory',
        },
      ],
      CyclePhase.follicular: [
        {'emoji': '🥗', 'name': 'Papaya salad', 'why': 'Enzymes + vitamin C'},
        {
          'emoji': '🫘',
          'name': 'Tempeh',
          'why': 'Fermented soy protein + probiotics',
        },
        {
          'emoji': '🥥',
          'name': 'Coconut water',
          'why': 'Hydration + electrolytes',
        },
      ],
      CyclePhase.ovulation: [
        {
          'emoji': '🥒',
          'name': 'Fresh spring rolls',
          'why': 'Light, raw veggies + herbs',
        },
        {
          'emoji': '🍊',
          'name': 'Tropical fruits',
          'why': 'Antioxidants at peak',
        },
        {
          'emoji': '🧄',
          'name': 'Stir-fried morning glory',
          'why': 'Iron + garlic detox',
        },
      ],
      CyclePhase.luteal: [
        {
          'emoji': '🍚',
          'name': 'Sticky rice with taro',
          'why': 'Comforting complex carbs',
        },
        {
          'emoji': '🌰',
          'name': 'Coconut desserts',
          'why': 'Healthy fats + satisfaction',
        },
        {
          'emoji': '🍵',
          'name': 'Pandan tea',
          'why': 'Calming, traditional remedy',
        },
      ],
    },
    'european': {
      CyclePhase.menstrual: [
        {
          'emoji': '🍲',
          'name': 'Beef bourguignon / stew',
          'why': 'Iron-rich comfort food',
        },
        {
          'emoji': '🥬',
          'name': 'Nettle tea',
          'why': 'Traditional iron supplement',
        },
        {
          'emoji': '🍫',
          'name': 'Swiss dark chocolate',
          'why': 'Magnesium for cramps',
        },
      ],
      CyclePhase.follicular: [
        {
          'emoji': '🥚',
          'name': 'Shakshuka / egg dishes',
          'why': 'B vitamins + protein',
        },
        {
          'emoji': '🫒',
          'name': 'Mediterranean salad',
          'why': 'Olive oil + fresh produce',
        },
        {
          'emoji': '🧀',
          'name': 'Yogurt with granola',
          'why': 'Probiotics + fiber',
        },
      ],
      CyclePhase.ovulation: [
        {'emoji': '🐟', 'name': 'Grilled sardines', 'why': 'Omega-3 + calcium'},
        {
          'emoji': '🥦',
          'name': 'Roasted vegetables',
          'why': 'Fiber + cruciferous detox',
        },
        {
          'emoji': '🍇',
          'name': 'Fresh berries & grapes',
          'why': 'Resveratrol + antioxidants',
        },
      ],
      CyclePhase.luteal: [
        {
          'emoji': '🍠',
          'name': 'Root vegetable mash',
          'why': 'Complex carbs + comfort',
        },
        {
          'emoji': '🥜',
          'name': 'Nut butter on rye bread',
          'why': 'Magnesium + slow carbs',
        },
        {
          'emoji': '🍵',
          'name': 'Chamomile or valerian tea',
          'why': 'Sleep + PMS calm',
        },
      ],
    },
    'global': {
      CyclePhase.menstrual: [
        {
          'emoji': '🍲',
          'name': 'Warm soups & stews',
          'why': 'Comforting and nutrient-dense',
        },
        {
          'emoji': '🫚',
          'name': 'Ginger tea',
          'why': 'Natural anti-inflammatory',
        },
        {'emoji': '🍫', 'name': 'Dark chocolate', 'why': 'Magnesium boost'},
      ],
      CyclePhase.follicular: [
        {'emoji': '🥗', 'name': 'Fresh salads', 'why': 'Light + vitamin-rich'},
        {'emoji': '🥚', 'name': 'Eggs', 'why': 'B vitamins + protein'},
        {'emoji': '🫐', 'name': 'Berries', 'why': 'Antioxidant energy'},
      ],
      CyclePhase.ovulation: [
        {'emoji': '🐟', 'name': 'Fatty fish', 'why': 'Omega-3 for fertility'},
        {'emoji': '🥒', 'name': 'Raw vegetables', 'why': 'Fiber + enzymes'},
        {'emoji': '🍵', 'name': 'Green tea', 'why': 'Gentle antioxidant boost'},
      ],
      CyclePhase.luteal: [
        {
          'emoji': '🍠',
          'name': 'Sweet potatoes',
          'why': 'Complex carbs ease cravings',
        },
        {
          'emoji': '🌰',
          'name': 'Seeds & nuts',
          'why': 'Magnesium + healthy fats',
        },
        {'emoji': '🍵', 'name': 'Herbal tea', 'why': 'Calming for PMS'},
      ],
    },
  };
