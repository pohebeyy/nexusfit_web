class Exercise {
  final String name;
  final int sets;
  final int repsPerSet;
  final double recommendedWeight;
  final int restSeconds;
  final bool hasVideo;

  Exercise({
    required this.name,
    required this.sets,
    required this.repsPerSet,
    required this.recommendedWeight,
    required this.restSeconds,
    required this.hasVideo,
  });
}