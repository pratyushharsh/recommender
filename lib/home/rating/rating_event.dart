part of 'rating_bloc.dart';

@immutable
abstract class RatingEvent {}

class UpdateRating extends RatingEvent {
  final double rating;
  final Movie movie;
  final String userId;
  UpdateRating(this.rating, this.movie, this.userId);
}

class GetAllRatedMovie extends RatingEvent {
  final String userId;

  GetAllRatedMovie(this.userId);
}
