class OnboardingData {
  bool hasPhoto;
  String? gender; 
  String? goal; 
  List<String>? targetZones; 
  double? height;
  double? weight; 
  String? trainingLocation; 
  List<String>? equipment; 
  String? experience; 
  List<String>? healthIssues; 

  OnboardingData({
    this.hasPhoto = false,
    this.gender,
    this.goal,
    this.targetZones,
    this.height,
    this.weight,
    this.trainingLocation,
    this.equipment,
    this.experience,
    this.healthIssues,
  });
}
