import 'package:flutter/foundation.dart';
import 'package:plant_app/api/api_service.dart';
import 'package:plant_app/models/plant.dart';

class PlantProvider extends ChangeNotifier {
  final ApiService apiService = ApiService();
  List<Plant> _plants = [];
  List<String> _images = [];
  bool _isLoading = false;

  List<Plant> get plants => _plants;
  List<String> get images => _images;
  bool get isLoading => _isLoading;

  Future<void> fetchPlants() async {
    _isLoading = true;
    notifyListeners();
    try {
      _plants = await apiService.fetchPlants();
      _images = await apiService.fetchImages();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deletePlant(int id) async {
    try {
      await apiService.deletePlant(id);
      _plants.removeWhere((plant) => plant.plantId == id);
      notifyListeners();
      await apiService.fetchPlants();
    } catch (e) {
      throw Exception('Error deleting plant: $e');
    }
  }
}
