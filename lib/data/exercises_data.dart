import '../models/exercise.dart';

class ExercisesData {
  static final List<ExerciseData> exercises = [
  // ============ BARBELL EXERCISES ============

  // 1. Barbell Bench Press
  ExerciseData(
  name: 'Barbell Bench Press',
  nameRu: 'Жим штанги лежа',
  primaryMuscle: DetailedMuscle.middleChest,
  secondaryMuscles: [
  DetailedMuscle.frontDelts,
  DetailedMuscle.medialHeadTriceps,
  DetailedMuscle.lateralHeadTriceps,
  ],
  equipment: Equipment.barbell,
  difficulty: Difficulty.intermediate,
  exerciseType: ExerciseType.compound,
  description: 'The king of all chest exercises. Fundamental compound movement for building chest mass and strength.',
  descriptionRu: 'Король всех упражнений на грудь. Фундаментальное базовое движение для развития массы и силы груди.',
  instructions: [
  'Lie flat on bench with feet planted firmly on floor',
  'Grip barbell slightly wider than shoulder-width with overhand grip',
  'Unrack bar and position over mid-chest with arms extended',
  'Lower bar slowly to chest, maintaining control',
  'Press bar back up to starting position, fully extending arms',
  ],
  instructionsRu: [
  'Лягте на скамью, плотно поставив ноги на пол',
  'Возьмите штангу хватом чуть шире плеч',
  'Снимите штангу со стоек и расположите над серединой груди',
  'Медленно опустите штангу к груди под контролем',
  'Выжмите штангу вверх, полностью выпрямляя руки',
  ],
  tips: [
  'Always use a spotter for heavy weights',
  'Keep shoulder blades retracted',
  'Maintain neutral spine',
  'Don\'t bounce bar off chest',
  ],
  tipsRu: [
  'Всегда используйте страховщика при работе с большими весами',
  'Держите лопатки сведенными',
  'Сохраняйте нейтральное положение позвоночника',
  'Не отбивайте штангу от груди',
  ],
  ),

  // 2. Barbell Back Squat
  ExerciseData(
  name: 'Barbell Back Squat',
  nameRu: 'Приседания со штангой на спине',
  primaryMuscle: DetailedMuscle.quadriceps,
  secondaryMuscles: [
  DetailedMuscle.glutes,
  DetailedMuscle.hamstrings,
  DetailedMuscle.erectorSpinae,
  DetailedMuscle.abs,
  ],
  equipment: Equipment.barbell,
  difficulty: Difficulty.intermediate,
  exerciseType: ExerciseType.compound,
  description: 'The king of all leg exercises. Builds overall lower body mass and strength.',
  descriptionRu: 'Король всех упражнений для ног. Развивает общую массу и силу нижней части тела.',
  instructions: [
  'Position barbell on upper traps/rear delts in squat rack',
  'Step back with feet shoulder-width apart, toes slightly outward',
  'Initiate movement by pushing hips back and bending knees',
  'Descend until thighs are parallel to floor',
  'Drive through heels to return to starting position',
  ],
  instructionsRu: [
  'Расположите штангу на верхних трапециях в силовой раме',
  'Отойдите назад, поставив ноги на ширине плеч',
  'Начните движение, отводя таз назад и сгибая колени',
  'Опуститесь до параллели бедер с полом',
  'Поднимитесь, отталкиваясь пятками',
  ],
  tips: [
  'Maintain chest up and knees tracking over toes',
  'Don\'t let knees cave inward',
  'Use safety bars',
  ],
  tipsRu: [
  'Держите грудь высоко, колени следуют за носками',
  'Не позволяйте коленям заваливаться внутрь',
  'Используйте страховочные упоры',
  ],
  ),

  // 3. Conventional Deadlift
  ExerciseData(
  name: 'Conventional Deadlift',
  nameRu: 'Классическая становая тяга',
  primaryMuscle: DetailedMuscle.erectorSpinae,
  secondaryMuscles: [
  DetailedMuscle.glutes,
  DetailedMuscle.hamstrings,
  DetailedMuscle.quadriceps,
  DetailedMuscle.lats,
  DetailedMuscle.upperTraps,
  DetailedMuscle.forearms,
  ],
  equipment: Equipment.barbell,
  difficulty: Difficulty.advanced,
  exerciseType: ExerciseType.compound,
  description: 'The ultimate full-body exercise. Works more muscles than any other single movement.',
  descriptionRu: 'Лучшее упражнение для всего тела. Задействует больше мышц, чем любое другое движение.',
  instructions: [
  'Stand with feet hip-width apart, bar over midfoot',
  'Grip bar with hands just outside legs',
  'Keep chest up, shoulders over bar, neutral spine',
  'Drive through heels and hips to lift bar',
  'Stand tall with shoulders back, then reverse movement',
  ],
  instructionsRu: [
  'Встаньте, ноги на ширине бедер, гриф над серединой стопы',
  'Возьмите гриф хватом чуть шире ног',
  'Держите грудь высоко, плечи над грифом, спина прямая',
  'Поднимайте штангу, отталкиваясь пятками',
  'Выпрямитесь полностью, затем опустите штангу',
  ],
  tips: [
  'Keep bar close to body throughout movement',
  'Engage core',
  'Don\'t round lower back',
  ],
  tipsRu: [
  'Держите штангу близко к телу на протяжении всего движения',
  'Напрягайте кор',
  'Не округляйте поясницу',
  ],
  ),

  // 4. Barbell Bent-Over Row
  ExerciseData(
  name: 'Barbell Bent-Over Row',
  nameRu: 'Тяга штанги в наклоне',
  primaryMuscle: DetailedMuscle.lats,
  secondaryMuscles: [
  DetailedMuscle.rhomboids,
  DetailedMuscle.middleTraps,
  DetailedMuscle.rearDelts,
  DetailedMuscle.biceps,
  ],
  equipment: Equipment.barbell,
  difficulty: Difficulty.intermediate,
  exerciseType: ExerciseType.compound,
  description: 'Fundamental rowing movement for back thickness. Engages entire posterior chain.',
  descriptionRu: 'Фундаментальное тяговое движение для толщины спины. Задействует всю заднюю цепь.',
  instructions: [
  'Stand with feet hip-width apart, knees slightly bent',
  'Hinge at hips to 45-degree angle, grip bar overhand',
  'Pull bar to lower chest/upper abdomen',
  'Squeeze shoulder blades together at top',
  'Lower bar with control to starting position',
  ],
  instructionsRu: [
  'Встаньте, ноги на ширине бедер, колени слегка согнуты',
  'Наклонитесь вперед под углом 45 градусов',
  'Тяните штангу к нижней части груди/верху живота',
  'Сведите лопатки в верхней точке',
  'Опустите штангу под контролем',
  ],
  ),

  // 5. Overhead Press
  ExerciseData(
  name: 'Overhead Press',
  nameRu: 'Жим штанги стоя',
  primaryMuscle: DetailedMuscle.frontDelts,
  secondaryMuscles: [
  DetailedMuscle.sideDelts,
  DetailedMuscle.medialHeadTriceps,
  DetailedMuscle.lateralHeadTriceps,
  DetailedMuscle.abs,
  ],
  equipment: Equipment.barbell,
  difficulty: Difficulty.intermediate,
  exerciseType: ExerciseType.compound,
  description: 'Fundamental shoulder exercise for building mass and strength. Full body stabilization required.',
  descriptionRu: 'Фундаментальное упражнение для плеч. Требует стабилизации всего тела.',
  instructions: [
  'Stand with feet shoulder-width apart, bar at shoulder level',
  'Grip bar slightly wider than shoulders',
  'Press bar straight up overhead',
  'Lock out arms fully at top',
  'Lower bar back to shoulders with control',
  ],
  instructionsRu: [
  'Встаньте, ноги на ширине плеч, штанга на уровне плеч',
  'Возьмите штангу хватом чуть шире плеч',
  'Выжмите штангу вверх над головой',
  'Полностью выпрямите руки в верхней точке',
  'Опустите штангу к плечам под контролем',
  ],
  ),

  // 6. Barbell Bicep Curl
  ExerciseData(
  name: 'Barbell Bicep Curl',
  nameRu: 'Подъем штанги на бицепс',
  primaryMuscle: DetailedMuscle.biceps,
  secondaryMuscles: [
  DetailedMuscle.forearms,
  ],
  equipment: Equipment.barbell,
  difficulty: Difficulty.beginner,
  exerciseType: ExerciseType.isolation,
  description: 'Classic bicep builder. Allows for progressive overload with heavy weight.',
  descriptionRu: 'Классическое упражнение для бицепса. Позволяет прогрессивную перегрузку.',
  instructions: [
  'Stand with feet hip-width apart, arms extended',
  'Grip bar with underhand grip, shoulder-width apart',
  'Keep elbows at sides, curl bar toward chest',
  'Squeeze biceps at top of movement',
  'Lower bar slowly to starting position',
  ],
  instructionsRu: [
  'Встаньте, ноги на ширине бедер, руки выпрямлены',
  'Возьмите штангу обратным хватом на ширине плеч',
  'Держа локти у корпуса, поднимите штангу к груди',
  'Напрягите бицепсы в верхней точке',
  'Медленно опустите штангу в исходное положение',
  ],
  ),

  // 7. Barbell Hip Thrust
  ExerciseData(
  name: 'Barbell Hip Thrust',
  nameRu: 'Ягодичный мост со штангой',
  primaryMuscle: DetailedMuscle.glutes,
  secondaryMuscles: [
  DetailedMuscle.hamstrings,
  DetailedMuscle.quadriceps,
  DetailedMuscle.abs,
  ],
  equipment: Equipment.barbell,
  difficulty: Difficulty.intermediate,
  exerciseType: ExerciseType.compound,
  description: 'Superior glute-building exercise. Allows heavy loading for maximum development.',
  descriptionRu: 'Превосходное упражнение для ягодиц. Позволяет работать с большими весами.',
  instructions: [
  'Sit with back against bench, barbell over hips',
  'Plant feet firmly on floor, hip-width apart',
  'Drive through heels to lift hips up',
  'Squeeze glutes at top, creating straight line from knees to shoulders',
  'Lower hips with control',
  ],
  instructionsRu: [
  'Сядьте спиной к скамье, штанга на бедрах',
  'Поставьте ноги на пол на ширине бедер',
  'Поднимите таз вверх, отталкиваясь пятками',
  'Напрягите ягодицы в верхней точке',
  'Опустите таз под контролем',
  ],
  ),

  // 8. Barbell Shrugs
  ExerciseData(
  name: 'Barbell Shrugs',
  nameRu: 'Шраги со штангой',
  primaryMuscle: DetailedMuscle.upperTraps,
  secondaryMuscles: [
  DetailedMuscle.rhomboids,
  ],
  equipment: Equipment.barbell,
  difficulty: Difficulty.beginner,
  exerciseType: ExerciseType.isolation,
  description: 'Direct trap isolation exercise. Builds impressive upper back development.',
  descriptionRu: 'Изолирующее упражнение для трапеций. Развивает впечатляющий верх спины.',
  instructions: [
  'Stand with barbell in hands, arms extended',
  'Shrug shoulders straight up toward ears',
  'Hold briefly at top',
  'Lower shoulders back down',
  'Don\'t roll shoulders forward or backward',
  ],
  instructionsRu: [
  'Встаньте со штангой в руках, руки выпрямлены',
  'Поднимите плечи вверх к ушам',
  'Задержитесь в верхней точке',
  'Опустите плечи вниз',
  'Не вращайте плечами',
  ],
  ),

  // 9. Good Mornings
  ExerciseData(
  name: 'Good Mornings',
  nameRu: 'Наклоны со штангой (гуд морнинг)',
  primaryMuscle: DetailedMuscle.lowerBack,
  secondaryMuscles: [
  DetailedMuscle.hamstrings,
  DetailedMuscle.glutes,
  DetailedMuscle.erectorSpinae,
  ],
  equipment: Equipment.barbell,
  difficulty: Difficulty.intermediate,
  exerciseType: ExerciseType.compound,
  description: 'Excellent posterior chain exercise. Builds strong lower back and hamstrings.',
  descriptionRu: 'Отличное упражнение для задней цепи. Укрепляет поясницу и бицепс бедра.',
  instructions: [
  'Place barbell on upper back (like squat position)',
  'Hinge at hips, pushing hips back',
  'Lower torso until parallel to floor',
  'Return to upright position',
  'Keep slight bend in knees',
  ],
  instructionsRu: [
  'Расположите штангу на верхней части спины',
  'Наклонитесь вперед, отводя таз назад',
  'Опустите корпус до параллели с полом',
  'Вернитесь в вертикальное положение',
  'Держите колени слегка согнутыми',
  ],
  ),

  // 10. Close-Grip Bench Press
  ExerciseData(
  name: 'Close-Grip Bench Press',
  nameRu: 'Жим узким хватом',
  primaryMuscle: DetailedMuscle.medialHeadTriceps,
  secondaryMuscles: [
  DetailedMuscle.lateralHeadTriceps,
  DetailedMuscle.longHeadTriceps,
  DetailedMuscle.innerChest,
  ],
  equipment: Equipment.barbell,
  difficulty: Difficulty.intermediate,
  exerciseType: ExerciseType.compound,
  description: 'Compound tricep exercise. Allows for heavy loading and progressive overload.',
  descriptionRu: 'Базовое упражнение для трицепса. Позволяет работать с большими весами.',
  instructions: [
  'Lie on bench with hands closer than shoulder-width',
  'Keep elbows closer to body than regular bench press',
  'Lower bar to lower chest/upper abdomen',
  'Press back up focusing on tricep engagement',
  'Maintain control throughout movement',
  ],
  instructionsRu: [
  'Лягте на скамью, руки уже ширины плеч',
  'Держите локти ближе к корпусу, чем при обычном жиме',
  'Опустите штангу к нижней части груди',
  'Выжмите штангу, фокусируясь на работе трицепсов',
  'Контролируйте движение на всей амплитуде',
  ],
  ),

  // 11. Incline Barbell Press
  ExerciseData(
  name: 'Incline Barbell Press',
  nameRu: 'Жим штанги на наклонной скамье',
  primaryMuscle: DetailedMuscle.upperChest,
  secondaryMuscles: [
  DetailedMuscle.frontDelts,
  DetailedMuscle.medialHeadTriceps,
  DetailedMuscle.lateralHeadTriceps,
  ],
  equipment: Equipment.barbell,
  difficulty: Difficulty.intermediate,
  exerciseType: ExerciseType.compound,
  description: 'Targets upper chest development. Essential for complete chest development.',
  descriptionRu: 'Нацелено на развитие верхней части груди. Необходимо для полного развития грудных мышц.',
  instructions: [
  'Set bench to 30-45 degree incline',
  'Grip barbell slightly wider than shoulders',
  'Lower bar to upper chest with control',
  'Press bar back up to starting position',
  'Focus on upper chest engagement',
  ],
  instructionsRu: [
  'Установите скамью под углом 30-45 градусов',
  'Возьмите штангу хватом чуть шире плеч',
  'Опустите штангу к верхней части груди',
  'Выжмите штангу в исходное положение',
  'Фокусируйтесь на работе верха груди',
  ],
  ),

  // 12. Decline Barbell Press
  ExerciseData(
  name: 'Decline Barbell Press',
  nameRu: 'Жим штанги на скамье с отрицательным наклоном',
  primaryMuscle: DetailedMuscle.lowerChest,
  secondaryMuscles: [
  DetailedMuscle.medialHeadTriceps,
  DetailedMuscle.lateralHeadTriceps,
  ],
  equipment: Equipment.barbell,
  difficulty: Difficulty.intermediate,
  exerciseType: ExerciseType.compound,
  description: 'Emphasizes lower chest. Often allows for heavier loads than flat bench.',
  descriptionRu: 'Акцент на нижнюю часть груди. Часто позволяет работать с большими весами.',
  instructions: [
  'Lie on decline bench with feet secured',
  'Grip barbell with standard bench press grip',
  'Lower bar to lower chest area',
  'Press bar back up, focusing on lower chest',
  'Maintain control throughout movement',
  ],
  instructionsRu: [
  'Лягте на скамью с отрицательным наклоном',
  'Возьмите штангу стандартным хватом для жима',
  'Опустите штангу к нижней части груди',
  'Выжмите штангу, фокусируясь на низе груди',
  'Контролируйте движение',
  ],
  ),

  // 13. T-Bar Row
  ExerciseData(
  name: 'T-Bar Row',
  nameRu: 'Т-образная тяга',
  primaryMuscle: DetailedMuscle.lats,
  secondaryMuscles: [
  DetailedMuscle.rhomboids,
  DetailedMuscle.middleTraps,
  DetailedMuscle.biceps,
  ],
  equipment: Equipment.barbell,
  difficulty: Difficulty.intermediate,
  exerciseType: ExerciseType.compound,
  description: 'Excellent back thickness builder. Allows for heavy loading with stable position.',
  descriptionRu: 'Отличное упражнение для толщины спины. Позволяет работать с большими весами.',
  instructions: [
  'Straddle T-bar with bent knees',
  'Grip handles with neutral or overhand grip',
  'Pull weight to chest, keeping back straight',
  'Squeeze shoulder blades at top',
  'Lower weight with control',
  ],
  instructionsRu: [
  'Встаньте над Т-грифом, согнув колени',
  'Возьмитесь за рукоятки нейтральным хватом',
  'Тяните вес к груди, держа спину прямой',
  'Сведите лопатки в верхней точке',
  'Опустите вес под контролем',
  ],
  ),

  // 14. Rack Pulls
  ExerciseData(
  name: 'Rack Pulls',
  nameRu: 'Тяга с плинтов',
  primaryMuscle: DetailedMuscle.erectorSpinae,
  secondaryMuscles: [
  DetailedMuscle.upperTraps,
  DetailedMuscle.lats,
  DetailedMuscle.glutes,
  DetailedMuscle.hamstrings,
  ],
  equipment: Equipment.barbell,
  difficulty: Difficulty.intermediate,
  exerciseType: ExerciseType.compound,
  description: 'Partial deadlift variation. Allows for heavier loads to build back strength.',
  descriptionRu: 'Частичная становая тяга. Позволяет работать с большими весами для развития силы спины.',
  instructions: [
  'Set barbell in rack at knee height',
  'Grip bar with conventional deadlift grip',
  'Pull bar up by extending hips and knees',
  'Lock out at top with shoulders back',
  'Lower bar back to rack with control',
  ],
  instructionsRu: [
  'Установите штангу в раме на уровне колен',
  'Возьмите штангу хватом для становой тяги',
  'Поднимите штангу, разгибая бедра и колени',
  'Зафиксируйтесь в верхней точке',
  'Опустите штангу обратно под контролем',
  ],
  ),

  // 15. Front Squats
  ExerciseData(
  name: 'Front Squats',
  nameRu: 'Фронтальные приседания',
  primaryMuscle: DetailedMuscle.quadriceps,
  secondaryMuscles: [
  DetailedMuscle.glutes,
  DetailedMuscle.abs,
  DetailedMuscle.upperChest,
  ],
  equipment: Equipment.barbell,
  difficulty: Difficulty.advanced,
  exerciseType: ExerciseType.compound,
  description: 'Quad-dominant squat variation. Requires excellent mobility and core strength.',
  descriptionRu: 'Вариант приседаний с акцентом на квадрицепс. Требует хорошей мобильности.',
  instructions: [
  'Hold barbell in front rack position',
  'Keep elbows high and chest up',
  'Squat down maintaining upright torso',
  'Drive through heels to stand up',
  'Maintain front rack position throughout',
  ],
  instructionsRu: [
  'Держите штангу в передней позиции',
  'Держите локти высоко, грудь вперед',
  'Приседайте, сохраняя вертикальное положение корпуса',
  'Встаньте, отталкиваясь пятками',
  'Сохраняйте положение штанги',
  ],
  ),

  // 16. Sumo Deadlifts
  ExerciseData(
  name: 'Sumo Deadlifts',
  nameRu: 'Становая тяга сумо',
  primaryMuscle: DetailedMuscle.glutes,
  secondaryMuscles: [
  DetailedMuscle.quadriceps,
  DetailedMuscle.hamstrings,
  DetailedMuscle.adductors,
  DetailedMuscle.erectorSpinae,
  ],
  equipment: Equipment.barbell,
  difficulty: Difficulty.intermediate,
  exerciseType: ExerciseType.compound,
  description: 'Wide-stance deadlift variation. More quad and glute dominant than conventional.',
  descriptionRu: 'Вариант становой тяги с широкой постановкой ног. Больше нагружает квадрицепсы и ягодицы.',
  instructions: [
  'Stand with wide stance, toes pointed out',
  'Grip bar with hands inside legs',
  'Keep chest up and hips low',
  'Drive through heels and hips to lift',
  'Lock out with shoulders back',
  ],
  instructionsRu: [
  'Встаньте с широкой постановкой ног, носки наружу',
  'Возьмите штангу хватом внутри ног',
  'Держите грудь высоко, таз низко',
  'Поднимайте штангу, отталкиваясь пятками',
  'Зафиксируйтесь с отведенными плечами',
  ],
  ),

  // 17. Preacher Curls
  ExerciseData(
  name: 'Preacher Curls',
  nameRu: 'Сгибания на скамье Скотта',
  primaryMuscle: DetailedMuscle.biceps,
  secondaryMuscles: [
  DetailedMuscle.forearms,
  ],
  equipment: Equipment.barbell,
  difficulty: Difficulty.beginner,
  exerciseType: ExerciseType.isolation,
  description: 'Isolates biceps by eliminating momentum. Great for peak development.',
  descriptionRu: 'Изолирует бицепс, исключая читинг. Отлично для развития пика бицепса.',
  instructions: [
  'Position arms on preacher bench pad',
  'Grip barbell or EZ-bar with underhand grip',
  'Lower weight until arms nearly straight',
  'Curl weight up, focusing on bicep contraction',
  'Control the eccentric portion',
  ],
  instructionsRu: [
  'Расположите руки на подушке скамьи Скотта',
  'Возьмите штангу или EZ-гриф обратным хватом',
  'Опустите вес до почти полного выпрямления рук',
  'Поднимите вес, фокусируясь на сокращении бицепса',
  'Контролируйте негативную фазу',
  ],
  ),

  // 18. Pendlay Rows
  ExerciseData(
  name: 'Pendlay Rows',
  nameRu: 'Тяга Пендли',
  primaryMuscle: DetailedMuscle.lats,
  secondaryMuscles: [
  DetailedMuscle.rhomboids,
  DetailedMuscle.middleTraps,
  DetailedMuscle.erectorSpinae,
  ],
  equipment: Equipment.barbell,
  difficulty: Difficulty.intermediate,
  exerciseType: ExerciseType.compound,
  description: 'Explosive rowing variation. Each rep starts from the floor for maximum power.',
  descriptionRu: 'Взрывной вариант тяги. Каждое повторение начинается с пола для максимальной мощности.',
  instructions: [
  'Start with barbell on floor',
  'Bend over with flat back parallel to floor',
  'Row bar explosively to lower chest',
  'Lower bar back to floor',
  'Reset position for each rep',
  ],
  instructionsRu: [
  'Начните со штангой на полу',
  'Наклонитесь с прямой спиной параллельно полу',
  'Взрывным движением тяните штангу к нижней части груди',
  'Опустите штангу на пол',
  'Перезагрузите позицию для каждого повторения',
  ],
  ),

  // 19. Zercher Squats
  ExerciseData(
  name: 'Zercher Squats',
  nameRu: 'Приседания Зерхера',
  primaryMuscle: DetailedMuscle.quadriceps,
  secondaryMuscles: [
  DetailedMuscle.abs,
  DetailedMuscle.upperChest,
  DetailedMuscle.glutes,
  ],
  equipment: Equipment.barbell,
  difficulty: Difficulty.advanced,
  exerciseType: ExerciseType.compound,
  description: 'Unique squat variation holding bar in elbow crease. Builds tremendous core strength.',
  descriptionRu: 'Уникальный вариант приседаний со штангой в локтевых сгибах. Развивает мощный кор.',
  instructions: [
  'Hold barbell in crook of elbows',
  'Keep elbows high and core tight',
  'Squat down maintaining upright torso',
  'Drive through heels to stand',
  'Keep bar secure in arm position',
  ],
  instructionsRu: [
  'Держите штангу в локтевых сгибах',
  'Держите локти высоко, кор напряжен',
  'Приседайте, сохраняя вертикальное положение корпуса',
  'Встаньте, отталкиваясь пятками',
  'Надежно удерживайте штангу',
  ],
  ),

  // 20. Reverse Grip Bench Press
  ExerciseData(
  name: 'Reverse Grip Bench Press',
  nameRu: 'Жим обратным хватом',
  primaryMuscle: DetailedMuscle.upperChest,
  secondaryMuscles: [
  DetailedMuscle.biceps,
  DetailedMuscle.frontDelts,
  ],
  equipment: Equipment.barbell,
  difficulty: Difficulty.advanced,
  exerciseType: ExerciseType.compound,
  description: 'Unique bench press variation targeting upper chest. Requires careful technique.',
  descriptionRu: 'Уникальный вариант жима с акцентом на верх груди. Требует аккуратной техники.',
  instructions: [
  'Grip barbell with underhand grip',
  'Lower bar to lower chest area',
  'Press bar up focusing on upper chest',
  'Keep elbows tucked',
  'Maintain control throughout',
  ],
  instructionsRu: [
  'Возьмите штангу обратным хватом',
  'Опустите штангу к нижней части груди',
  'Выжмите штангу, фокусируясь на верхе груди',
  'Держите локти прижатыми',
  'Контролируйте движение',
  ],
  ),

  // ============ DUMBBELL EXERCISES ============

  // 21. Dumbbell Chest Press
  ExerciseData(
  name: 'Dumbbell Chest Press',
  nameRu: 'Жим гантелей лежа',
  primaryMuscle: DetailedMuscle.middleChest,
  secondaryMuscles: [
  DetailedMuscle.frontDelts,
  DetailedMuscle.medialHeadTriceps,
  DetailedMuscle.lateralHeadTriceps,
  ],
  equipment: Equipment.dumbbell,
  difficulty: Difficulty.beginner,
  exerciseType: ExerciseType.compound,
  description: 'Allows greater range of motion than barbell. Excellent for muscle development and stabilization.',
  descriptionRu: 'Позволяет большую амплитуду движения, чем штанга. Отлично для развития мышц и стабилизации.',
  instructions: [
  'Lie on bench with dumbbells at chest level',
  'Press dumbbells up and slightly inward',
  'Fully extend arms at top',
  'Lower dumbbells to chest level with control',
  'Maintain constant tension throughout movement',
  ],
  instructionsRu: [
  'Лягте на скамью с гантелями на уровне груди',
  'Выжмите гантели вверх, слегка сводя их',
  'Полностью выпрямите руки в верхней точке',
  'Опустите гантели к груди под контролем',
  'Сохраняйте постоянное напряжение',
  ],
  ),

  // 22. Dumbbell Flyes
  ExerciseData(
  name: 'Dumbbell Flyes',
  nameRu: 'Разведение гантелей лежа',
  primaryMuscle: DetailedMuscle.outerChest,
  secondaryMuscles: [
  DetailedMuscle.frontDelts,
  ],
  equipment: Equipment.dumbbell,
  difficulty: Difficulty.beginner,
  exerciseType: ExerciseType.isolation,
  description: 'Isolation exercise for chest. Provides excellent stretch and chest activation.',
  descriptionRu: 'Изолирующее упражнение для груди. Обеспечивает отличное растяжение.',
  instructions: [
  'Lie on bench with dumbbells extended above chest',
  'Slightly bend elbows and maintain throughout movement',
  'Lower dumbbells in wide arc until stretch is felt in chest',
  'Bring dumbbells back together above chest',
  'Focus on squeezing chest muscles',
  ],
  instructionsRu: [
  'Лягте на скамью с гантелями над грудью',
  'Слегка согните локти и сохраняйте этот угол',
  'Опустите гантели по широкой дуге до ощущения растяжения',
  'Сведите гантели над грудью',
  'Фокусируйтесь на сжатии грудных мышц',
  ],
  ),

  // 23. Dumbbell Shoulder Press
  ExerciseData(
  name: 'Dumbbell Shoulder Press',
  nameRu: 'Жим гантелей сидя/стоя',
  primaryMuscle: DetailedMuscle.frontDelts,
  secondaryMuscles: [
  DetailedMuscle.sideDelts,
  DetailedMuscle.medialHeadTriceps,
  DetailedMuscle.lateralHeadTriceps,
  ],
  equipment: Equipment.dumbbell,
  difficulty: Difficulty.beginner,
  exerciseType: ExerciseType.compound,
  description: 'Fundamental shoulder exercise. Allows natural movement path and unilateral training.',
  descriptionRu: 'Фундаментальное упражнение для плеч. Позволяет естественную траекторию движения.',
  instructions: [
  'Sit or stand with dumbbells at shoulder height',
  'Press dumbbells overhead in straight line',
  'Bring dumbbells together at top',
  'Lower dumbbells to shoulder level',
  'Maintain core engagement throughout',
  ],
  instructionsRu: [
  'Сядьте или встаньте с гантелями на уровне плеч',
  'Выжмите гантели вверх по прямой линии',
  'Сведите гантели в верхней точке',
  'Опустите гантели к плечам',
  'Держите кор напряженным',
  ],
  ),

  // 24. Dumbbell Lateral Raises
  ExerciseData(
  name: 'Dumbbell Lateral Raises',
  nameRu: 'Махи гантелями в стороны',
  primaryMuscle: DetailedMuscle.sideDelts,
  secondaryMuscles: [
  DetailedMuscle.frontDelts,
  DetailedMuscle.upperTraps,
  ],
  equipment: Equipment.dumbbell,
  difficulty: Difficulty.beginner,
  exerciseType: ExerciseType.isolation,
  description: 'Isolation exercise for shoulder width. Focus on controlled movement, not heavy weight.',
  descriptionRu: 'Изолирующее упражнение для ширины плеч. Фокус на контроле, а не на весе.',
  instructions: [
  'Stand with dumbbells at sides, slight bend in elbows',
  'Raise dumbbells out to sides until arms parallel to floor',
  'Lead with pinkies, keep slight forward lean',
  'Lower dumbbells slowly to starting position',
  'Focus on feeling tension in side delts',
  ],
  instructionsRu: [
  'Встаньте с гантелями по бокам, локти слегка согнуты',
  'Поднимите гантели в стороны до параллели с полом',
  'Ведите движение мизинцами вверх',
  'Медленно опустите гантели',
  'Фокусируйтесь на напряжении в средних дельтах',
  ],
  ),

  // 25. Dumbbell Bent-Over Reverse Flyes
  ExerciseData(
  name: 'Dumbbell Bent-Over Reverse Flyes',
  nameRu: 'Махи гантелями в наклоне',
  primaryMuscle: DetailedMuscle.rearDelts,
  secondaryMuscles: [
  DetailedMuscle.rhomboids,
  DetailedMuscle.middleTraps,
  ],
  equipment: Equipment.dumbbell,
  difficulty: Difficulty.beginner,
  exerciseType: ExerciseType.isolation,
  description: 'Targets rear deltoids for balanced shoulder development. Essential for posture.',
  descriptionRu: 'Нацелено на задние дельты для сбалансированного развития плеч. Важно для осанки.',
  instructions: [
  'Bend over at hips with dumbbells hanging down',
  'Keep slight bend in elbows',
  'Raise dumbbells out to sides in reverse fly motion',
  'Squeeze shoulder blades together',
  'Lower dumbbells with control',
  ],
  instructionsRu: [
  'Наклонитесь вперед с гантелями внизу',
  'Держите локти слегка согнутыми',
  'Разведите гантели в стороны',
  'Сведите лопатки в верхней точке',
  'Опустите гантели под контролем',
  ],
  ),

  // 26. Dumbbell Lunges
  ExerciseData(
  name: 'Dumbbell Lunges',
  nameRu: 'Выпады с гантелями',
  primaryMuscle: DetailedMuscle.quadriceps,
  secondaryMuscles: [
  DetailedMuscle.glutes,
  DetailedMuscle.hamstrings,
  DetailedMuscle.calves,
  ],
  equipment: Equipment.dumbbell,
  difficulty: Difficulty.beginner,
  exerciseType: ExerciseType.compound,
  description: 'Unilateral leg exercise. Builds strength, balance, and coordination.',
  descriptionRu: 'Одностороннее упражнение для ног. Развивает силу, баланс и координацию.',
  instructions: [
  'Stand with dumbbells at sides',
  'Step forward into lunge position',
  'Lower back knee toward ground',
  'Push off front foot to return to starting position',
  'Alternate legs or complete all reps on one side',
  ],
  instructionsRu: [
  'Встаньте с гантелями по бокам',
  'Сделайте шаг вперед в позицию выпада',
  'Опустите заднее колено к полу',
  'Оттолкнитесь передней ногой для возврата',
  'Чередуйте ноги или выполните все повторения на одну',
  ],
  ),

  // 27. Dumbbell Romanian Deadlift
  ExerciseData(
  name: 'Dumbbell Romanian Deadlift',
  nameRu: 'Румынская тяга с гантелями',
  primaryMuscle: DetailedMuscle.hamstrings,
  secondaryMuscles: [
  DetailedMuscle.glutes,
  DetailedMuscle.erectorSpinae,
  ],
  equipment: Equipment.dumbbell,
  difficulty: Difficulty.beginner,
  exerciseType: ExerciseType.compound,
  description: 'Hip hinge movement pattern. Excellent for hamstring and glute development.',
  descriptionRu: 'Движение тазобедренного шарнира. Отлично для развития бицепса бедра и ягодиц.',
  instructions: [
  'Stand with dumbbells in front of thighs',
  'Hinge at hips, pushing hips back',
  'Lower dumbbells along legs, feeling hamstring stretch',
  'Drive hips forward to return to standing',
  'Keep dumbbells close to body throughout',
  ],
  instructionsRu: [
  'Встаньте с гантелями перед бедрами',
  'Отведите таз назад, наклоняясь вперед',
  'Опустите гантели вдоль ног до растяжения бицепса бедра',
  'Вернитесь в исходное положение движением таза вперед',
  'Держите гантели близко к телу',
  ],
  ),

  // 28. Dumbbell Hammer Curls
  ExerciseData(
  name: 'Dumbbell Hammer Curls',
  nameRu: 'Молотковые сгибания',
  primaryMuscle: DetailedMuscle.biceps,
  secondaryMuscles: [
  DetailedMuscle.forearms,
  ],
  equipment: Equipment.dumbbell,
  difficulty: Difficulty.beginner,
  exerciseType: ExerciseType.isolation,
  description: 'Targets brachialis and brachioradialis. Builds arm thickness and grip strength.',
  descriptionRu: 'Нацелено на брахиалис и брахиорадиалис. Развивает толщину рук и силу хвата.',
  instructions: [
  'Stand with dumbbells at sides, palms facing each other',
  'Curl dumbbells up toward shoulders',
  'Keep elbows at sides throughout movement',
  'Squeeze biceps at top',
  'Lower dumbbells slowly',
  ],
  instructionsRu: [
  'Встаньте с гантелями по бокам, ладони друг к другу',
  'Поднимите гантели к плечам',
  'Держите локти у корпуса',
  'Напрягите бицепсы в верхней точке',
  'Медленно опустите гантели',
  ],
  ),

  // 29. Incline Dumbbell Press
  ExerciseData(
  name: 'Incline Dumbbell Press',
  nameRu: 'Жим гантелей на наклонной скамье',
  primaryMuscle: DetailedMuscle.upperChest,
  secondaryMuscles: [
  DetailedMuscle.frontDelts,
  DetailedMuscle.medialHeadTriceps,
  ],
  equipment: Equipment.dumbbell,
  difficulty: Difficulty.beginner,
  exerciseType: ExerciseType.compound,
  description: 'Upper chest focused pressing movement. Allows for deeper stretch than barbell.',
  descriptionRu: 'Жимовое движение с фокусом на верх груди. Позволяет более глубокое растяжение.',
  instructions: [
  'Set bench to 30-45 degree incline',
  'Press dumbbells up and slightly inward',
  'Follow same pattern as flat dumbbell press',
  'Focus on upper chest engagement',
  'Lower with control to upper chest',
  ],
  instructionsRu: [
  'Установите скамью под углом 30-45 градусов',
  'Выжмите гантели вверх, слегка сводя их',
  'Следуйте той же технике, что и в горизонтальном жиме',
  'Фокусируйтесь на работе верха груди',
  'Опускайте под контролем',
  ],
  ),

  // 30. Overhead Tricep Extension
  ExerciseData(
  name: 'Overhead Tricep Extension',
  nameRu: 'Французский жим с гантелью',
  primaryMuscle: DetailedMuscle.longHeadTriceps,
  secondaryMuscles: [
  DetailedMuscle.medialHeadTriceps,
  DetailedMuscle.lateralHeadTriceps,
  ],
  equipment: Equipment.dumbbell,
  difficulty: Difficulty.beginner,
  exerciseType: ExerciseType.isolation,
  description: 'Excellent for targeting the long head of the triceps. Provides great stretch.',
  descriptionRu: 'Отлично для проработки длинной головки трицепса. Обеспечивает отличное растяжение.',
  instructions: [
  'Hold dumbbell overhead with both hands',
  'Lower weight behind head by bending elbows',
  'Keep elbows pointing forward',
  'Extend arms back to starting position',
  'Focus on tricep stretch and contraction',
  ],
  instructionsRu: [
  'Держите гантель над головой обеими руками',
  'Опустите вес за голову, сгибая локти',
  'Держите локти направленными вперед',
  'Выпрямите руки в исходное положение',
  'Фокусируйтесь на растяжении и сокращении трицепса',
  ],
  ),

  // 31. Single-Arm Dumbbell Row
  ExerciseData(
  name: 'Single-Arm Dumbbell Row',
  nameRu: 'Тяга гантели в наклоне одной рукой',
  primaryMuscle: DetailedMuscle.lats,
  secondaryMuscles: [
  DetailedMuscle.rhomboids,
  DetailedMuscle.biceps,
  DetailedMuscle.rearDelts,
  ],
  equipment: Equipment.dumbbell,
  difficulty: Difficulty.beginner,
  exerciseType: ExerciseType.compound,
  description: 'Unilateral back exercise. Allows for focused lat development and core stability.',
  descriptionRu: 'Одностороннее упражнение для спины. Позволяет сфокусированное развитие широчайших.',
  instructions: [
  'Place one knee and hand on bench for support',
  'Hold dumbbell in opposite hand',
  'Pull dumbbell to hip/lower ribcage',
  'Squeeze shoulder blade at top',
  'Lower with control',
  ],
  instructionsRu: [
  'Поставьте одно колено и руку на скамью для опоры',
  'Держите гантель в противоположной руке',
  'Тяните гантель к бедру/нижним ребрам',
  'Сведите лопатку в верхней точке',
  'Опустите под контролем',
  ],
  ),

  // 32. Bulgarian Split Squats
  ExerciseData(
  name: 'Bulgarian Split Squats',
  nameRu: 'Болгарские приседания',
  primaryMuscle: DetailedMuscle.quadriceps,
  secondaryMuscles: [
  DetailedMuscle.glutes,
  DetailedMuscle.hamstrings,
  ],
  equipment: Equipment.dumbbell,
  difficulty: Difficulty.intermediate,
  exerciseType: ExerciseType.compound,
  description: 'Advanced single-leg exercise. Builds strength, balance, and muscle mass.',
  descriptionRu: 'Продвинутое упражнение на одну ногу. Развивает силу, баланс и мышечную массу.',
  instructions: [
  'Place rear foot on bench behind you',
  'Lower front leg into lunge position',
  'Keep most weight on front leg',
  'Push through front heel to return up',
  'Complete all reps before switching legs',
  ],
  instructionsRu: [
  'Поставьте заднюю ногу на скамью позади',
  'Опустите переднюю ногу в позицию выпада',
  'Держите большую часть веса на передней ноге',
  'Оттолкнитесь передней пяткой для подъема',
  'Выполните все повторения перед сменой ног',
  ],
  ),

  // 33. Dumbbell Pullovers
  ExerciseData(
  name: 'Dumbbell Pullovers',
  nameRu: 'Пуловер с гантелью',
  primaryMuscle: DetailedMuscle.lats,
  secondaryMuscles: [
  DetailedMuscle.upperChest,
  DetailedMuscle.longHeadTriceps,
  ],
  equipment: Equipment.dumbbell,
  difficulty: Difficulty.intermediate,
  exerciseType: ExerciseType.isolation,
  description: 'Unique exercise targeting lats and chest. Excellent for ribcage expansion.',
  descriptionRu: 'Уникальное упражнение для широчайших и груди. Отлично для расширения грудной клетки.',
  instructions: [
  'Lie perpendicular on bench with shoulders supported',
  'Hold dumbbell above chest with both hands',
  'Lower weight in arc behind head',
  'Feel stretch in lats and chest',
  'Pull weight back over chest',
  ],
  instructionsRu: [
  'Лягте поперек скамьи, опираясь плечами',
  'Держите гантель над грудью обеими руками',
  'Опустите вес по дуге за голову',
  'Почувствуйте растяжение в широчайших и груди',
  'Верните вес над грудью',
  ],
  ),

  // 34. Arnold Press
  ExerciseData(
  name: 'Arnold Press',
  nameRu: 'Жим Арнольда',
  primaryMuscle: DetailedMuscle.frontDelts,
  secondaryMuscles: [
  DetailedMuscle.sideDelts,
  DetailedMuscle.medialHeadTriceps,
  ],
  equipment: Equipment.dumbbell,
  difficulty: Difficulty.intermediate,
  exerciseType: ExerciseType.compound,
  description: 'Shoulder press with rotation. Hits all deltoid heads through full range of motion.',
  descriptionRu: 'Жим с вращением. Прорабатывает все головки дельт через полную амплитуду.',
  instructions: [
  'Start with dumbbells at shoulder level, palms facing you',
  'Press up while rotating palms forward',
  'End with arms extended, palms facing away',
  'Reverse motion to return to start',
  'Maintain smooth rotation throughout',
  ],
  instructionsRu: [
  'Начните с гантелями на уровне плеч, ладони к себе',
  'Выжимайте вверх, вращая ладони вперед',
  'Закончите с выпрямленными руками, ладони от себя',
  'Выполните обратное движение',
  'Сохраняйте плавное вращение',
  ],
  ),

  // 35. Concentration Curls
  ExerciseData(
  name: 'Concentration Curls',
  nameRu: 'Концентрированные сгибания',
  primaryMuscle: DetailedMuscle.biceps,
  secondaryMuscles: [
  DetailedMuscle.forearms,
  ],
  equipment: Equipment.dumbbell,
  difficulty: Difficulty.beginner,
  exerciseType: ExerciseType.isolation,
  description: 'Ultimate bicep isolation exercise. Perfect for developing bicep peak.',
  descriptionRu: 'Лучшее изолирующее упражнение для бицепса. Идеально для развития пика бицепса.',
  instructions: [
  'Sit on bench with legs spread',
  'Rest elbow on inner thigh',
  'Curl dumbbell toward shoulder',
  'Focus on bicep peak contraction',
  'Lower slowly to full extension',
  ],
  instructionsRu: [
  'Сядьте на скамью, расставив ноги',
  'Уприте локоть во внутреннюю часть бедра',
  'Поднимите гантель к плечу',
  'Фокусируйтесь на пиковом сокращении бицепса',
  'Медленно опустите до полного выпрямления',
  ],
  ),

  // ============ CABLE/MACHINE EXERCISES ============

  // 36. Lat Pulldown
  ExerciseData(
  name: 'Lat Pulldown',
  nameRu: 'Тяга верхнего блока',
  primaryMuscle: DetailedMuscle.lats,
  secondaryMuscles: [
  DetailedMuscle.rhomboids,
  DetailedMuscle.middleTraps,
  DetailedMuscle.biceps,
  ],
  equipment: Equipment.cable,
  difficulty: Difficulty.beginner,
  exerciseType: ExerciseType.compound,
  description: 'Great alternative to pull-ups. Allows for progressive overload with adjustable weight.',
  descriptionRu: 'Отличная альтернатива подтягиваниям. Позволяет прогрессивную перегрузку.',
  instructions: [
  'Sit at lat pulldown machine with thighs secured',
  'Grip bar wider than shoulders with overhand grip',
  'Pull bar down to upper chest',
  'Squeeze shoulder blades together',
  'Slowly return bar to starting position',
  ],
  instructionsRu: [
  'Сядьте за тренажер, зафиксировав бедра',
  'Возьмите рукоять шире плеч прямым хватом',
  'Тяните рукоять к верхней части груди',
  'Сведите лопатки в нижней точке',
  'Медленно верните рукоять в исходное положение',
  ],
  ),

  // 37. Cable Rows
  ExerciseData(
  name: 'Cable Rows',
  nameRu: 'Тяга горизонтального блока',
  primaryMuscle: DetailedMuscle.rhomboids,
  secondaryMuscles: [
  DetailedMuscle.lats,
  DetailedMuscle.middleTraps,
  DetailedMuscle.rearDelts,
  DetailedMuscle.biceps,
  ],
  equipment: Equipment.cable,
  difficulty: Difficulty.beginner,
  exerciseType: ExerciseType.compound,
  description: 'Excellent for back thickness. Constant tension throughout the movement.',
  descriptionRu: 'Отлично для толщины спины. Постоянное напряжение на всей амплитуде.',
  instructions: [
  'Sit at cable row machine with feet on platform',
  'Grip handle with neutral grip',
  'Pull handle to abdomen, squeezing shoulder blades',
  'Keep chest up and shoulders back',
  'Slowly extend arms to starting position',
  ],
  instructionsRu: [
  'Сядьте за тренажер, поставив ноги на платформу',
  'Возьмите рукоять нейтральным хватом',
  'Тяните рукоять к животу, сводя лопатки',
  'Держите грудь высоко, плечи назад',
  'Медленно выпрямите руки',
  ],
  ),

  // 38. Cable Tricep Pushdowns
  ExerciseData(
  name: 'Cable Tricep Pushdowns',
  nameRu: 'Разгибания на блоке',
  primaryMuscle: DetailedMuscle.lateralHeadTriceps,
  secondaryMuscles: [
  DetailedMuscle.medialHeadTriceps,
  DetailedMuscle.longHeadTriceps,
  ],
  equipment: Equipment.cable,
  difficulty: Difficulty.beginner,
  exerciseType: ExerciseType.isolation,
  description: 'Isolation exercise with constant tension. Great for tricep definition.',
  descriptionRu: 'Изолирующее упражнение с постоянным напряжением. Отлично для рельефа трицепса.',
  instructions: [
  'Stand at cable machine with rope or bar attachment',
  'Keep elbows at sides, grip handle',
  'Push weight down by extending forearms',
  'Fully extend arms at bottom',
  'Slowly return to starting position',
  ],
  instructionsRu: [
  'Встаньте у блока с канатной или прямой рукоятью',
  'Держите локти у корпуса',
  'Разгибайте предплечья, опуская вес вниз',
  'Полностью выпрямите руки внизу',
  'Медленно вернитесь в исходное положение',
  ],
  ),

  // 39. Cable Chest Flyes
  ExerciseData(
  name: 'Cable Chest Flyes',
  nameRu: 'Сведение рук в кроссовере',
  primaryMuscle: DetailedMuscle.innerChest,
  secondaryMuscles: [
  DetailedMuscle.frontDelts,
  ],
  equipment: Equipment.cable,
  difficulty: Difficulty.beginner,
  exerciseType: ExerciseType.isolation,
  description: 'Provides constant tension throughout range of motion. Excellent for chest isolation.',
  descriptionRu: 'Обеспечивает постоянное напряжение. Отлично для изоляции грудных мышц.',
  instructions: [
  'Stand between cable towers with handles at chest height',
  'Step forward with slight forward lean',
  'Bring handles together in front of chest',
  'Squeeze chest muscles at end position',
  'Slowly return to starting position',
  ],
  instructionsRu: [
  'Встаньте между блоками с рукоятями на уровне груди',
  'Сделайте шаг вперед, слегка наклонившись',
  'Сведите рукояти перед грудью',
  'Напрягите грудные мышцы в конечной точке',
  'Медленно вернитесь в исходное положение',
  ],
  ),

  // 40. Cable Lateral Raises
  ExerciseData(
  name: 'Cable Lateral Raises',
  nameRu: 'Махи в стороны на блоке',
  primaryMuscle: DetailedMuscle.sideDelts,
  secondaryMuscles: [
  DetailedMuscle.frontDelts,
  ],
  equipment: Equipment.cable,
  difficulty: Difficulty.beginner,
  exerciseType: ExerciseType.isolation,
  description: 'Constant tension variation of lateral raises. Excellent for shoulder development.',
  descriptionRu: 'Вариант махов с постоянным напряжением. Отлично для развития плеч.',
  instructions: [
  'Stand sideways to cable machine with handle in outside hand',
  'Raise arm out to side until parallel to floor',
  'Lead with pinky finger',
  'Lower arm slowly to starting position',
  'Complete all reps before switching sides',
  ],
  instructionsRu: [
  'Встаньте боком к блоку, рукоять в дальней руке',
  'Поднимите руку в сторону до параллели с полом',
  'Ведите движение мизинцем вверх',
  'Медленно опустите руку',
  'Выполните все повторения перед сменой стороны',
  ],
  ),

  // 41. Cable Bicep Curls
  ExerciseData(
    name: 'Cable Bicep Curls',
    nameRu: 'Сгибания рук на блоке',
    primaryMuscle: DetailedMuscle.biceps,
    secondaryMuscles: [
      DetailedMuscle.forearms,
    ],
    equipment: Equipment.cable,
    difficulty: Difficulty.beginner,
    exerciseType: ExerciseType.isolation,
    description: 'Constant tension bicep exercise. Excellent for muscle development and pump.',
    descriptionRu: 'Упражнение для бицепса с постоянным напряжением. Отлично для развития и пампинга.',
    instructions: [
      'Stand facing cable machine with bar attachment',
      'Grip bar with underhand grip',
      'Curl bar toward chest, keeping elbows at sides',
      'Squeeze biceps at top',
      'Lower bar slowly with control',
    ],
    instructionsRu: [
      'Встаньте лицом к блоку с прямой рукоятью',
      'Возьмите рукоять обратным хватом',
      'Поднимите рукоять к груди, держа локти у корпуса',
      'Напрягите бицепсы в верхней точке',
      'Медленно опустите рукоять',
    ],
  ),

  // 42. Cable Face Pulls
  ExerciseData(
    name: 'Cable Face Pulls',
    nameRu: 'Тяга к лицу',
    primaryMuscle: DetailedMuscle.rearDelts,
    secondaryMuscles: [
      DetailedMuscle.rhomboids,
      DetailedMuscle.middleTraps,
    ],
    equipment: Equipment.cable,
    difficulty: Difficulty.beginner,
    exerciseType: ExerciseType.isolation,
    description: 'Excellent for rear delt development and shoulder health. Helps improve posture.',
    descriptionRu: 'Отлично для задних дельт и здоровья плеч. Помогает улучшить осанку.',
    instructions: [
      'Set cable at face height with rope attachment',
      'Pull rope toward face, separating ends',
      'Focus on pulling elbows back',
      'Squeeze shoulder blades together',
      'Slowly return to starting position',
    ],
    instructionsRu: [
      'Установите блок на уровне лица с канатной рукоятью',
      'Тяните канат к лицу, разводя концы',
      'Фокусируйтесь на отведении локтей назад',
      'Сведите лопатки',
      'Медленно вернитесь в исходное положение',
    ],
  ),

  // 43. Cable External Rotations
  ExerciseData(
    name: 'Cable External Rotations',
    nameRu: 'Внешняя ротация на блоке',
    primaryMuscle: DetailedMuscle.infraspinatus,
    secondaryMuscles: [
      DetailedMuscle.teresMinor,
    ],
    equipment: Equipment.cable,
    difficulty: Difficulty.beginner,
    exerciseType: ExerciseType.isolation,
    description: 'Rotator cuff strengthening exercise. Essential for shoulder health and injury prevention.',
    descriptionRu: 'Упражнение для ротаторной манжеты. Важно для здоровья плеч и профилактики травм.',
    instructions: [
      'Stand sideways to cable with elbow at 90 degrees',
      'Keep elbow at side, rotate arm outward',
      'Return to starting position with control',
      'Focus on external rotation movement',
      'Complete all reps before switching sides',
    ],
    instructionsRu: [
      'Встаньте боком к блоку, локоть согнут под 90 градусов',
      'Держа локоть у корпуса, вращайте руку наружу',
      'Вернитесь в исходное положение под контролем',
      'Фокусируйтесь на внешнем вращении',
      'Выполните все повторения перед сменой стороны',
    ],
  ),

  // 44. Cable Internal Rotations
  ExerciseData(
    name: 'Cable Internal Rotations',
    nameRu: 'Внутренняя ротация на блоке',
    primaryMuscle: DetailedMuscle.teresMajor,
    secondaryMuscles: [
      DetailedMuscle.lats,
    ],
    equipment: Equipment.cable,
    difficulty: Difficulty.beginner,
    exerciseType: ExerciseType.isolation,
    description: 'Complements external rotation for complete rotator cuff training.',
    descriptionRu: 'Дополняет внешнюю ротацию для полной тренировки ротаторной манжеты.',
    instructions: [
      'Stand sideways to cable with elbow at 90 degrees',
      'Rotate arm inward across body',
      'Keep elbow at side throughout',
      'Return to starting position',
      'Focus on internal rotation',
    ],
    instructionsRu: [
      'Встаньте боком к блоку, локоть согнут под 90 градусов',
      'Вращайте руку внутрь через корпус',
      'Держите локоть у корпуса',
      'Вернитесь в исходное положение',
      'Фокусируйтесь на внутреннем вращении',
    ],
  ),

  // 45. Wrist Curls
  ExerciseData(
    name: 'Wrist Curls',
    nameRu: 'Сгибания запястий',
    primaryMuscle: DetailedMuscle.forearms,
    secondaryMuscles: [],
    equipment: Equipment.barbell,
    difficulty: Difficulty.beginner,
    exerciseType: ExerciseType.isolation,
    description: 'Direct forearm exercise. Builds grip strength and forearm mass.',
    descriptionRu: 'Прямое упражнение для предплечий. Развивает силу хвата и массу предплечий.',
    instructions: [
      'Sit with forearms on bench, wrists hanging over edge',
      'Hold barbell or dumbbells with underhand grip',
      'Curl wrists up by flexing forearms',
      'Lower wrists below starting position',
      'Focus on forearm muscle contraction',
    ],
    instructionsRu: [
      'Сядьте, положив предплечья на скамью',
      'Держите штангу или гантели обратным хватом',
      'Поднимите запястья вверх, сгибая предплечья',
      'Опустите запястья ниже исходного положения',
      'Фокусируйтесь на сокращении мышц предплечий',
    ],
  ),

  // 46. Standing Calf Raises
  ExerciseData(
    name: 'Standing Calf Raises',
    nameRu: 'Подъемы на носки стоя',
    primaryMuscle: DetailedMuscle.calves,
    secondaryMuscles: [],
    equipment: Equipment.machine,
    difficulty: Difficulty.beginner,
    exerciseType: ExerciseType.isolation,
    description: 'Primary calf exercise. Builds lower leg strength and definition.',
    descriptionRu: 'Основное упражнение для икр. Развивает силу и рельеф голеней.',
    instructions: [
      'Stand on balls of feet on elevated surface',
      'Hold weights or use calf raise machine',
      'Rise up onto toes as high as possible',
      'Hold briefly at top',
      'Lower heels below starting position for stretch',
    ],
    instructionsRu: [
      'Встаньте на носки на возвышении',
      'Держите вес или используйте тренажер',
      'Поднимитесь на носки как можно выше',
      'Задержитесь в верхней точке',
      'Опустите пятки ниже исходного положения',
    ],
  ),

  // 47. Lateral Lunges
  ExerciseData(
    name: 'Lateral Lunges',
    nameRu: 'Боковые выпады',
    primaryMuscle: DetailedMuscle.adductors,
    secondaryMuscles: [
      DetailedMuscle.quadriceps,
      DetailedMuscle.glutes,
    ],
    equipment: Equipment.dumbbell,
    difficulty: Difficulty.intermediate,
    exerciseType: ExerciseType.compound,
    description: 'Frontal plane movement. Targets inner thighs and improves hip mobility.',
    descriptionRu: 'Движение во фронтальной плоскости. Нацелено на внутреннюю поверхность бедра.',
    instructions: [
      'Stand with feet hip-width apart',
      'Step wide to one side, lowering into side lunge',
      'Keep stepping leg bent, other leg straight',
      'Push off to return to center',
      'Alternate sides or complete all reps on one side',
    ],
    instructionsRu: [
      'Встаньте, ноги на ширине бедер',
      'Сделайте широкий шаг в сторону в боковой выпад',
      'Держите рабочую ногу согнутой, другую прямой',
      'Оттолкнитесь для возврата в центр',
      'Чередуйте стороны или выполните все повторения на одну',
    ],
  ),

  // 48. Cable Kickbacks
  ExerciseData(
    name: 'Cable Kickbacks',
    nameRu: 'Отведение ноги назад на блоке',
    primaryMuscle: DetailedMuscle.glutes,
    secondaryMuscles: [
      DetailedMuscle.hamstrings,
    ],
    equipment: Equipment.cable,
    difficulty: Difficulty.beginner,
    exerciseType: ExerciseType.isolation,
    description: 'Glute isolation exercise. Excellent for targeting and shaping glutes.',
    descriptionRu: 'Изолирующее упражнение для ягодиц. Отлично для целевой проработки.',
    instructions: [
      'Attach ankle strap to cable machine',
      'Face machine, holding onto support',
      'Kick leg back and up',
      'Squeeze glute at top',
      'Return to start with control',
    ],
    instructionsRu: [
      'Прикрепите манжету к блоку',
      'Встаньте лицом к тренажеру, держась за опору',
      'Отведите ногу назад и вверх',
      'Напрягите ягодицу в верхней точке',
      'Вернитесь в исходное положение под контролем',
    ],
  ),

  // 49. Cable Crossovers
  ExerciseData(
    name: 'Cable Crossovers',
    nameRu: 'Кроссовер',
    primaryMuscle: DetailedMuscle.middleChest,
    secondaryMuscles: [
      DetailedMuscle.innerChest,
      DetailedMuscle.frontDelts,
    ],
    equipment: Equipment.cable,
    difficulty: Difficulty.beginner,
    exerciseType: ExerciseType.isolation,
    description: 'Classic chest isolation exercise. Provides peak contraction and constant tension.',
    descriptionRu: 'Классическое изолирующее упражнение для груди. Обеспечивает пиковое сокращение.',
    instructions: [
      'Stand between cable towers',
      'Hold handles with arms extended to sides',
      'Bring hands together in front of body',
      'Squeeze chest at end position',
      'Return to start with control',
    ],
    instructionsRu: [
      'Встаньте между блоками кроссовера',
      'Держите рукояти с разведенными руками',
      'Сведите руки перед собой',
      'Напрягите грудь в конечной точке',
      'Вернитесь в исходное положение под контролем',
    ],
  ),

  // 50. Skull Crushers
  ExerciseData(
    name: 'Skull Crushers',
    nameRu: 'Французский жим лежа',
    primaryMuscle: DetailedMuscle.longHeadTriceps,
    secondaryMuscles: [
      DetailedMuscle.medialHeadTriceps,
      DetailedMuscle.lateralHeadTriceps,
    ],
    equipment: Equipment.barbell,
    difficulty: Difficulty.intermediate,
    exerciseType: ExerciseType.isolation,
    description: 'Excellent tricep isolation exercise. Targets all three heads of the triceps.',
    descriptionRu: 'Отличное изолирующее упражнение для трицепса. Нацелено на все три головки.',
    instructions: [
      'Lie on bench with barbell or dumbbells',
      'Extend arms straight up over chest',
      'Lower weight by bending elbows toward forehead',
      'Extend elbows to return to start',
      'Keep upper arms stationary',
    ],
    instructionsRu: [
      'Лягте на скамью со штангой или гантелями',
      'Выпрямите руки над грудью',
      'Опустите вес, сгибая локти к голове',
      'Разогните локти для возврата',
      'Держите плечи неподвижными',
    ],
  ),

  // 51. Reverse Lunges
  ExerciseData(
    name: 'Reverse Lunges',
    nameRu: 'Обратные выпады',
    primaryMuscle: DetailedMuscle.quadriceps,
    secondaryMuscles: [
      DetailedMuscle.glutes,
      DetailedMuscle.hamstrings,
    ],
    equipment: Equipment.dumbbell,
    difficulty: Difficulty.beginner,
    exerciseType: ExerciseType.compound,
    description: 'Knee-friendly lunge variation. Excellent for leg development and balance.',
    descriptionRu: 'Вариант выпадов, щадящий колени. Отлично для развития ног и баланса.',
    instructions: [
      'Stand with feet hip-width apart',
      'Step backwards into lunge position',
      'Lower back knee toward ground',
      'Push through front heel to return to standing',
      'Alternate legs or complete all reps on one side',
    ],
    instructionsRu: [
      'Встаньте, ноги на ширине бедер',
      'Сделайте шаг назад в позицию выпада',
      'Опустите заднее колено к полу',
      'Оттолкнитесь передней пяткой для возврата',
      'Чередуйте ноги или выполните все повторения на одну',
    ],
  ),

  // 52. Step-ups
  ExerciseData(
    name: 'Step-ups',
    nameRu: 'Зашагивания на платформу',
    primaryMuscle: DetailedMuscle.quadriceps,
    secondaryMuscles: [
      DetailedMuscle.glutes,
      DetailedMuscle.calves,
    ],
    equipment: Equipment.dumbbell,
    difficulty: Difficulty.beginner,
    exerciseType: ExerciseType.compound,
    description: 'Functional unilateral exercise. Builds leg strength and improves balance.',
    descriptionRu: 'Функциональное одностороннее упражнение. Развивает силу ног и баланс.',
    instructions: [
      'Stand in front of sturdy box or bench',
      'Step up with one foot, driving through heel',
      'Bring other foot up to standing position',
      'Step down with control',
      'Complete all reps on one leg before switching',
    ],
    instructionsRu: [
      'Встаньте перед устойчивой платформой или скамьей',
      'Зашагните одной ногой, отталкиваясь пяткой',
      'Подставьте вторую ногу',
      'Сойдите вниз под контролем',
      'Выполните все повторения на одну ногу',
    ],
  ),

  // 53. Leg Press
  ExerciseData(
    name: 'Leg Press',
    nameRu: 'Жим ногами',
    primaryMuscle: DetailedMuscle.quadriceps,
    secondaryMuscles: [
      DetailedMuscle.glutes,
      DetailedMuscle.hamstrings,
      DetailedMuscle.calves,
    ],
    equipment: Equipment.machine,
    difficulty: Difficulty.beginner,
    exerciseType: ExerciseType.compound,
    description: 'Safe alternative to squats. Allows for heavy loading with reduced spinal stress.',
    descriptionRu: 'Безопасная альтернатива приседаниям. Позволяет работать с большими весами.',
    instructions: [
      'Sit in leg press machine with back against pad',
      'Place feet shoulder-width apart on platform',
      'Lower weight by bending knees to 90 degrees',
      'Press weight back up without locking knees',
      'Maintain control throughout movement',
    ],
    instructionsRu: [
      'Сядьте в тренажер, прижав спину к спинке',
      'Поставьте ноги на платформу на ширине плеч',
      'Опустите вес, согнув колени до 90 градусов',
      'Выжмите вес, не выпрямляя колени полностью',
      'Контролируйте движение',
    ],
  ),

  // 54. Hack Squats
  ExerciseData(
    name: 'Hack Squats',
    nameRu: 'Гакк-приседания',
    primaryMuscle: DetailedMuscle.quadriceps,
    secondaryMuscles: [
      DetailedMuscle.glutes,
      DetailedMuscle.hamstrings,
    ],
    equipment: Equipment.machine,
    difficulty: Difficulty.intermediate,
    exerciseType: ExerciseType.compound,
    description: 'Machine squat variation. Excellent for quad development with back support.',
    descriptionRu: 'Вариант приседаний в тренажере. Отлично для развития квадрицепсов.',
    instructions: [
      'Position back against hack squat machine pad',
      'Place feet shoulder-width apart on platform',
      'Lower body by bending knees',
      'Drive through heels to return to start',
      'Keep core engaged throughout',
    ],
    instructionsRu: [
      'Прижмите спину к спинке тренажера',
      'Поставьте ноги на платформу на ширине плеч',
      'Опуститесь, сгибая колени',
      'Поднимитесь, отталкиваясь пятками',
      'Держите кор напряженным',
    ],
  ),

  // 55. Seated Calf Raises
  ExerciseData(
    name: 'Seated Calf Raises',
    nameRu: 'Подъемы на носки сидя',
    primaryMuscle: DetailedMuscle.calves,
    secondaryMuscles: [],
    equipment: Equipment.machine,
    difficulty: Difficulty.beginner,
    exerciseType: ExerciseType.isolation,
    description: 'Targets soleus muscle of the calf. Complements standing calf raises.',
    descriptionRu: 'Нацелено на камбаловидную мышцу. Дополняет подъемы на носки стоя.',
    instructions: [
      'Sit on calf raise machine with knees under pads',
      'Place balls of feet on platform',
      'Raise heels as high as possible',
      'Hold briefly at top',
      'Lower heels below platform level',
    ],
    instructionsRu: [
      'Сядьте в тренажер, колени под валиками',
      'Поставьте носки на платформу',
      'Поднимите пятки как можно выше',
      'Задержитесь в верхней точке',
      'Опустите пятки ниже уровня платформы',
    ],
  ),

  // 56. Leg Curls
  ExerciseData(
    name: 'Leg Curls',
    nameRu: 'Сгибание ног лежа',
    primaryMuscle: DetailedMuscle.hamstrings,
    secondaryMuscles: [
      DetailedMuscle.calves,
    ],
    equipment: Equipment.machine,
    difficulty: Difficulty.beginner,
    exerciseType: ExerciseType.isolation,
    description: 'Primary hamstring isolation exercise. Essential for balanced leg development.',
    descriptionRu: 'Основное изолирующее упражнение для бицепса бедра. Важно для баланса развития ног.',
    instructions: [
      'Lie face down on leg curl machine',
      'Position ankles under pads',
      'Curl heels toward glutes',
      'Squeeze hamstrings at top',
      'Lower weight with control',
    ],
    instructionsRu: [
      'Лягте лицом вниз на тренажер',
      'Расположите лодыжки под валиками',
      'Согните ноги, подтягивая пятки к ягодицам',
      'Напрягите бицепс бедра в верхней точке',
      'Опустите вес под контролем',
    ],
  ),

  // 57. Leg Extensions
  ExerciseData(
    name: 'Leg Extensions',
    nameRu: 'Разгибание ног сидя',
    primaryMuscle: DetailedMuscle.quadriceps,
    secondaryMuscles: [],
    equipment: Equipment.machine,
    difficulty: Difficulty.beginner,
    exerciseType: ExerciseType.isolation,
    description: 'Quadriceps isolation exercise. Great for pre-exhaust or finishing movement.',
    descriptionRu: 'Изолирующее упражнение для квадрицепса. Отлично для предварительного утомления.',
    instructions: [
      'Sit on leg extension machine',
      'Position ankles behind lower pads',
      'Extend legs until nearly straight',
      'Hold briefly at top',
      'Lower weight with control',
    ],
    instructionsRu: [
      'Сядьте в тренажер',
      'Расположите лодыжки за нижними валиками',
      'Выпрямите ноги почти полностью',
      'Задержитесь в верхней точке',
      'Опустите вес под контролем',
    ],
  ),

  // 58. Glute Ham Raises
  ExerciseData(
    name: 'Glute Ham Raises',
    nameRu: 'Гиперэкстензия для бицепса бедра',
    primaryMuscle: DetailedMuscle.hamstrings,
    secondaryMuscles: [
      DetailedMuscle.glutes,
      DetailedMuscle.erectorSpinae,
    ],
    equipment: Equipment.machine,
    difficulty: Difficulty.advanced,
    exerciseType: ExerciseType.compound,
    description: 'Advanced posterior chain exercise. Builds incredible hamstring strength.',
    descriptionRu: 'Продвинутое упражнение для задней цепи. Развивает невероятную силу бицепса бедра.',
    instructions: [
      'Position body on GHR machine',
      'Start with torso perpendicular to floor',
      'Lower torso using hamstring control',
      'Pull body back up using hamstrings and glutes',
      'Maintain neutral spine throughout',
    ],
    instructionsRu: [
      'Расположитесь на тренажере GHR',
      'Начните с корпусом перпендикулярно полу',
      'Опустите корпус, контролируя бицепсом бедра',
      'Поднимите корпус, используя бицепс бедра и ягодицы',
      'Сохраняйте нейтральное положение позвоночника',
    ],
  ),

  // 59. Upright Rows
  ExerciseData(
    name: 'Upright Rows',
    nameRu: 'Тяга к подбородку',
    primaryMuscle: DetailedMuscle.sideDelts,
    secondaryMuscles: [
      DetailedMuscle.upperTraps,
      DetailedMuscle.frontDelts,
    ],
    equipment: Equipment.barbell,
    difficulty: Difficulty.intermediate,
    exerciseType: ExerciseType.compound,
    description: 'Compound shoulder exercise. Builds deltoids and traps simultaneously.',
    descriptionRu: 'Базовое упражнение для плеч. Развивает дельты и трапеции одновременно.',
    instructions: [
      'Hold barbell with overhand grip, hands close',
      'Pull bar up along body to chin level',
      'Lead with elbows, keeping them high',
      'Lower bar with control',
      'Keep bar close to body',
    ],
    instructionsRu: [
      'Держите штангу прямым хватом, руки близко',
      'Тяните штангу вверх вдоль тела к подбородку',
      'Ведите движение локтями, держа их высоко',
      'Опустите штангу под контролем',
      'Держите штангу близко к телу',
    ],
  ),

  // 60. Landmine Press
  ExerciseData(
    name: 'Landmine Press',
    nameRu: 'Жим штанги одним концом',
    primaryMuscle: DetailedMuscle.frontDelts,
    secondaryMuscles: [
      DetailedMuscle.upperChest,
      DetailedMuscle.medialHeadTriceps,
    ],
    equipment: Equipment.barbell,
    difficulty: Difficulty.intermediate,
    exerciseType: ExerciseType.compound,
    description: 'Unique pressing angle. Shoulder-friendly alternative to overhead press.',
    descriptionRu: 'Уникальный угол жима. Безопасная для плеч альтернатива жиму над головой.',
    instructions: [
      'Hold end of barbell at shoulder',
      'Press bar up and slightly forward',
      'Extend arm fully at top',
      'Lower bar back to shoulder',
      'Maintain stable stance',
    ],
    instructionsRu: [
      'Держите конец штанги у плеча',
      'Выжмите штангу вверх и слегка вперед',
      'Полностью выпрямите руку в верхней точке',
      'Опустите штангу к плечу',
      'Сохраняйте устойчивую стойку',
    ],
  ),

  // 61. Jefferson Squats
  ExerciseData(
    name: 'Jefferson Squats',
    nameRu: 'Приседания Джефферсона',
    primaryMuscle: DetailedMuscle.quadriceps,
    secondaryMuscles: [
      DetailedMuscle.glutes,
      DetailedMuscle.adductors,
      DetailedMuscle.hamstrings,
    ],
    equipment: Equipment.barbell,
    difficulty: Difficulty.advanced,
    exerciseType: ExerciseType.compound,
    description: 'Unique squat variation. Challenges stability and hits legs from different angle.',
    descriptionRu: 'Уникальный вариант приседаний. Развивает стабильность и прорабатывает ноги под другим углом.',
    instructions: [
      'Straddle barbell with one foot forward',
      'Grip bar with mixed grip',
      'Squat down keeping torso upright',
      'Stand up by driving through both legs',
      'Maintain balanced position',
    ],
    instructionsRu: [
      'Встаньте над штангой, одна нога впереди',
      'Возьмите штангу разнохватом',
      'Приседайте, держа корпус вертикально',
      'Встаньте, отталкиваясь обеими ногами',
      'Сохраняйте баланс',
    ],
  ),

  // 62. Meadows Rows
  ExerciseData(
    name: 'Meadows Rows',
    nameRu: 'Тяга Медоуза',
    primaryMuscle: DetailedMuscle.lats,
    secondaryMuscles: [
      DetailedMuscle.rhomboids,
      DetailedMuscle.rearDelts,
      DetailedMuscle.biceps,
    ],
    equipment: Equipment.barbell,
    difficulty: Difficulty.intermediate,
    exerciseType: ExerciseType.compound,
    description: 'Landmine row variation. Provides unique angle for lat development.',
    descriptionRu: 'Вариант тяги с одним концом штанги. Обеспечивает уникальный угол для развития широчайших.',
    instructions: [
      'Set up perpendicular to landmine barbell',
      'Grip bar with one hand near end',
      'Row bar to hip in arcing motion',
      'Squeeze lat at top',
      'Lower with control',
    ],
    instructionsRu: [
      'Встаньте перпендикулярно к штанге',
      'Возьмите штангу одной рукой у конца',
      'Тяните штангу к бедру по дуге',
      'Напрягите широчайшую в верхней точке',
      'Опустите под контролем',
    ],
  ),

  // 63. Belt Squats
  ExerciseData(
    name: 'Belt Squats',
    nameRu: 'Приседания с поясом',
    primaryMuscle: DetailedMuscle.quadriceps,
    secondaryMuscles: [
      DetailedMuscle.glutes,
      DetailedMuscle.hamstrings,
    ],
    equipment: Equipment.machine,
    difficulty: Difficulty.intermediate,
    exerciseType: ExerciseType.compound,
    description: 'Spine-friendly squat variation. Allows heavy loading without spinal compression.',
    descriptionRu: 'Вариант приседаний без нагрузки на позвоночник. Позволяет работать с большими весами.',
    instructions: [
      'Attach weight to belt around hips',
      'Stand on platforms with weight hanging',
      'Squat down allowing weight to lower',
      'Drive through heels to stand',
      'Maintain upright posture',
    ],
    instructionsRu: [
      'Прикрепите вес к поясу на бедрах',
      'Встаньте на платформы с висящим весом',
      'Приседайте, позволяя весу опускаться',
      'Встаньте, отталкиваясь пятками',
      'Сохраняйте вертикальное положение',
    ],
  ),

  // 64. Cable Pull-throughs
  ExerciseData(
    name: 'Cable Pull-throughs',
    nameRu: 'Протяжка через ноги на блоке',
    primaryMuscle: DetailedMuscle.glutes,
    secondaryMuscles: [
      DetailedMuscle.hamstrings,
      DetailedMuscle.erectorSpinae,
    ],
    equipment: Equipment.cable,
    difficulty: Difficulty.beginner,
    exerciseType: ExerciseType.compound,
    description: 'Hip hinge movement with constant tension. Excellent glute builder.',
    descriptionRu: 'Движение тазобедренного шарнира с постоянным напряжением. Отлично для ягодиц.',
    instructions: [
      'Face away from cable machine',
      'Hold rope between legs',
      'Hinge at hips pushing hips back',
      'Drive hips forward to return',
      'Squeeze glutes at top',
    ],
    instructionsRu: [
      'Встаньте спиной к блоку',
      'Держите канат между ног',
      'Отведите таз назад, наклоняясь вперед',
      'Верните таз вперед',
      'Напрягите ягодицы в верхней точке',
    ],
  ),

  // 65. Pallof Press
  ExerciseData(
    name: 'Pallof Press',
    nameRu: 'Жим Паллофа',
    primaryMuscle: DetailedMuscle.abs,
    secondaryMuscles: [
      DetailedMuscle.obliques,
    ],
    equipment: Equipment.cable,
    difficulty: Difficulty.beginner,
    exerciseType: ExerciseType.isometric,
    description: 'Anti-rotation core exercise. Builds incredible core stability.',
    descriptionRu: 'Упражнение против вращения для кора. Развивает невероятную стабильность.',
    instructions: [
      'Stand perpendicular to cable machine',
      'Hold handle at chest with both hands',
      'Press handle straight out from chest',
      'Resist rotation forces',
      'Return handle to chest',
    ],
    instructionsRu: [
      'Встаньте перпендикулярно к блоку',
      'Держите рукоять у груди обеими руками',
      'Выжмите рукоять прямо от груди',
      'Сопротивляйтесь вращающей силе',
      'Верните рукоять к груди',
    ],
  ),

  // 66. Cable Crunches
  ExerciseData(
    name: 'Cable Crunches',
    nameRu: 'Скручивания на блоке',
    primaryMuscle: DetailedMuscle.abs,
    secondaryMuscles: [
      DetailedMuscle.obliques,
    ],
    equipment: Equipment.cable,
    difficulty: Difficulty.beginner,
    exerciseType: ExerciseType.isolation,
    description: 'Weighted ab exercise. Allows progressive overload for ab development.',
    descriptionRu: 'Упражнение для пресса с отягощением. Позволяет прогрессивную перегрузку.',
    instructions: [
      'Kneel facing cable machine',
      'Hold rope behind head',
      'Crunch forward flexing spine',
      'Focus on ab contraction',
      'Return to start position',
    ],
    instructionsRu: [
      'Встаньте на колени лицом к блоку',
      'Держите канат за головой',
      'Скручивайтесь вперед, сгибая позвоночник',
      'Фокусируйтесь на сокращении пресса',
      'Вернитесь в исходное положение',
    ],
  ),

  // 67. Seated Row Machine
  ExerciseData(
    name: 'Seated Row Machine',
    nameRu: 'Тяга в тренажере сидя',
    primaryMuscle: DetailedMuscle.rhomboids,
    secondaryMuscles: [
      DetailedMuscle.lats,
      DetailedMuscle.middleTraps,
      DetailedMuscle.biceps,
    ],
    equipment: Equipment.machine,
    difficulty: Difficulty.beginner,
    exerciseType: ExerciseType.compound,
    description: 'Machine row variation. Provides stability for maximum back engagement.',
    descriptionRu: 'Вариант тяги в тренажере. Обеспечивает стабильность для максимальной работы спины.',
    instructions: [
      'Sit at machine with chest against pad',
      'Grip handles with neutral or overhand grip',
      'Pull handles back squeezing shoulder blades',
      'Focus on back muscles',
      'Return to start with control',
    ],
    instructionsRu: [
      'Сядьте в тренажер, прижав грудь к подушке',
      'Возьмите рукояти нейтральным хватом',
      'Тяните рукояти назад, сводя лопатки',
      'Фокусируйтесь на мышцах спины',
      'Вернитесь в исходное положение под контролем',
    ],
  ),

  // 68. Pec Deck Machine
  ExerciseData(
    name: 'Pec Deck Machine',
    nameRu: 'Бабочка',
    primaryMuscle: DetailedMuscle.innerChest,
    secondaryMuscles: [
      DetailedMuscle.middleChest,
      DetailedMuscle.frontDelts,
    ],
    equipment: Equipment.machine,
    difficulty: Difficulty.beginner,
    exerciseType: ExerciseType.isolation,
    description: 'Machine chest fly. Safe isolation exercise for chest development.',
    descriptionRu: 'Сведение рук в тренажере. Безопасное изолирующее упражнение для груди.',
    instructions: [
      'Sit with back against pad',
      'Place forearms on pads or grip handles',
      'Bring arms together in front',
      'Squeeze chest at end position',
      'Return to start with control',
    ],
    instructionsRu: [
      'Сядьте, прижав спину к спинке',
      'Расположите предплечья на подушках',
      'Сведите руки перед собой',
      'Напрягите грудь в конечной точке',
      'Вернитесь в исходное положение под контролем',
    ],
  ),

  // 69. Smith Machine Squats
  ExerciseData(
    name: 'Smith Machine Squats',
    nameRu: 'Приседания в Смите',
    primaryMuscle: DetailedMuscle.quadriceps,
    secondaryMuscles: [
      DetailedMuscle.glutes,
      DetailedMuscle.hamstrings,
    ],
    equipment: Equipment.machine,
    difficulty: Difficulty.beginner,
    exerciseType: ExerciseType.compound,
    description: 'Guided bar path squat. Good for beginners or targeting specific muscles.',
    descriptionRu: 'Приседания с фиксированной траекторией. Хорошо для начинающих.',
    instructions: [
      'Position bar on upper traps',
      'Stand with feet slightly forward',
      'Squat down along fixed path',
      'Drive through heels to stand',
      'Use safety stops',
    ],
    instructionsRu: [
      'Расположите гриф на верхних трапециях',
      'Встаньте, ноги слегка впереди',
      'Приседайте по фиксированной траектории',
      'Встаньте, отталкиваясь пятками',
      'Используйте страховочные упоры',
    ],
  ),

  // 70. Trap Bar Deadlifts
  ExerciseData(
    name: 'Trap Bar Deadlifts',
    nameRu: 'Становая тяга с трэп-грифом',
    primaryMuscle: DetailedMuscle.quadriceps,
    secondaryMuscles: [
      DetailedMuscle.glutes,
      DetailedMuscle.hamstrings,
      DetailedMuscle.erectorSpinae,
      DetailedMuscle.upperTraps,
    ],
    equipment: Equipment.barbell,
    difficulty: Difficulty.beginner,
    exerciseType: ExerciseType.compound,
    description: 'Beginner-friendly deadlift variation. More quad-dominant than conventional.',
    descriptionRu: 'Вариант становой тяги для начинающих. Больше нагружает квадрицепсы.',
    instructions: [
      'Stand inside trap bar',
      'Grip handles at sides',
      'Lift by extending hips and knees',
      'Stand tall at top',
      'Lower bar with control',
    ],
    instructionsRu: [
      'Встаньте внутри трэп-грифа',
      'Возьмитесь за ручки по бокам',
      'Поднимите гриф, разгибая бедра и колени',
      'Выпрямитесь в верхней точке',
      'Опустите гриф под контролем',
    ],
  ),

  // 71. Cable Hammer Curls
  ExerciseData(
    name: 'Cable Hammer Curls',
    nameRu: 'Молотковые сгибания на блоке',
    primaryMuscle: DetailedMuscle.biceps,
    secondaryMuscles: [
      DetailedMuscle.forearms,
    ],
    equipment: Equipment.cable,
    difficulty: Difficulty.beginner,
    exerciseType: ExerciseType.isolation,
    description: 'Cable version of hammer curls. Constant tension throughout movement.',
    descriptionRu: 'Версия молотковых сгибаний на блоке. Постоянное напряжение.',
    instructions: [
      'Attach rope to low cable',
      'Hold ends with neutral grip',
      'Curl rope toward shoulders',
      'Keep elbows at sides',
      'Lower with control',
    ],
    instructionsRu: [
      'Прикрепите канат к нижнему блоку',
      'Держите концы нейтральным хватом',
      'Поднимите канат к плечам',
      'Держите локти у корпуса',
      'Опустите под контролем',
    ],
  ),

  // 72. Reverse Hyperextensions
  ExerciseData(
    name: 'Reverse Hyperextensions',
    nameRu: 'Обратная гиперэкстензия',
    primaryMuscle: DetailedMuscle.glutes,
    secondaryMuscles: [
      DetailedMuscle.hamstrings,
      DetailedMuscle.erectorSpinae,
    ],
    equipment: Equipment.machine,
    difficulty: Difficulty.intermediate,
    exerciseType: ExerciseType.compound,
    description: 'Posterior chain exercise. Builds glutes and hamstrings without spinal loading.',
    descriptionRu: 'Упражнение для задней цепи. Развивает ягодицы и бицепс бедра без нагрузки на позвоночник.',
    instructions: [
      'Lie face down on bench with hips at edge',
      'Hold bench for support',
      'Raise legs behind you',
      'Squeeze glutes at top',
      'Lower legs with control',
    ],
    instructionsRu: [
      'Лягте лицом вниз, бедра на краю скамьи',
      'Держитесь за скамью для опоры',
      'Поднимите ноги за собой',
      'Напрягите ягодицы в верхней точке',
      'Опустите ноги под контролем',
    ],
  ),
  ];
}

// Вспомогательные классы для структурирования данных
class ExerciseData {
  final String name;
  final String nameRu;
  final DetailedMuscle primaryMuscle;
  final List<DetailedMuscle> secondaryMuscles;
  final Equipment equipment;
  final Difficulty difficulty;
  final ExerciseType exerciseType;
  final String description;
  final String descriptionRu;
  final List<String> instructions;
  final List<String> instructionsRu;
  final List<String> tips;
  final List<String> tipsRu;

  const ExerciseData({
    required this.name,
    required this.nameRu,
    required this.primaryMuscle,
    required this.secondaryMuscles,
    required this.equipment,
    required this.difficulty,
    required this.exerciseType,
    required this.description,
    required this.descriptionRu,
    this.instructions = const [],
    this.instructionsRu = const [],
    this.tips = const [],
    this.tipsRu = const [],
  });
}

// Enums для дополнительных полей
enum Equipment {
  barbell,
  dumbbell,
  cable,
  machine,
  bodyweight,
  kettlebell,
  bands,
  other
}

enum Difficulty {
  beginner,
  intermediate,
  advanced
}

enum ExerciseType {
  compound,
  isolation,
  isometric
}