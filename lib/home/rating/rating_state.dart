part of 'rating_bloc.dart';

@immutable
abstract class RatingState {}

class RatingInitial extends RatingState {}

class SuccessMyRatingState extends RatingState {
  final List<MyRating> ratings;

  SuccessMyRatingState(this.ratings);
}

class LoadingMyRatings extends RatingState {}

class FailureMyRatingState extends RatingState {}
