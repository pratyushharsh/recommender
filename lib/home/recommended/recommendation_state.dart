part of 'recommendation_bloc.dart';

@immutable
abstract class RecommendationState {}

class RecommendationInitial extends RecommendationState {}

class LoadingRecommendationState extends RecommendationState {}

class FailureRecommendationState extends RecommendationState {}

class SuccessRecommendationState extends RecommendationState {
  final List<Movie> movies;

  SuccessRecommendationState(this.movies);
}
