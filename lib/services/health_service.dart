import '../models/health_data.dart';
import '../data/mock_data.dart';

class HealthService {
  static final HealthService _instance = HealthService._internal();

  factory HealthService() {
    return _instance;
  }

  HealthService._internal();

  List<HealthData> _healthDataList = [];

  Future<void> initHealthData() async {
    _healthDataList = MockData.getMockHealthData();
  }

  List<HealthData> getHealthData() => _healthDataList;

  HealthData? getTodayHealthData() {
    final today = DateTime.now();
    try {
      return _healthDataList.firstWhere((h) =>
          h.date.day == today.day &&
          h.date.month == today.month &&
          h.date.year == today.year);
    } catch (e) {
      return null;
    }
  }

  Future<void> addHealthData(HealthData data) async {
    _healthDataList.add(data);
  }

  int getAverageSteps(int days) {
    final recent = _healthDataList.take(days).toList();
    final sum = recent.fold<int>(0, (sum, h) => sum + h.steps);
    return (sum / recent.length).round();
  }

  double getAverageHeartRate(int days) {
    final recent = _healthDataList.take(days).toList();
    final sum = recent.fold<double>(0, (sum, h) => sum + h.heartRate);
    return sum / recent.length;
  }

  String getHealthStatus() {
    final today = getTodayHealthData();
    if (today == null) return 'Нет данных';

    if (today.sleepHours >= 7 && today.waterGlassesConsumed >= 7) {
      return 'Отличное состояние! Продолжай так!';
    } else if (today.sleepHours < 6 || today.waterGlassesConsumed < 5) {
      return 'Нужно больше отдыхать и пить воду';
    }
    return 'Хорошее состояние';
  }
}
