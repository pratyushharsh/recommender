part of 'recommendation_bloc.dart';

@immutable
abstract class RecommendationEvent {}

class GetRecommendation extends RecommendationEvent {
  final String userId;

  GetRecommendation(this.userId);
}
