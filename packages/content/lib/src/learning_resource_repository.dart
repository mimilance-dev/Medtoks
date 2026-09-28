import 'learning_resource.dart';

abstract interface class LearningResourceRepository {
  Future<LearningResource?> findById(String id);
}
