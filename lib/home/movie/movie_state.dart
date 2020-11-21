part of 'movie_bloc.dart';

@immutable
abstract class MovieState {}

class MovieInitial extends MovieState {}


class LoadingMovieState extends MovieState {}

class FailureMovieState extends MovieState {}

class SuccessMovieState extends MovieState {
  final List<Movie> movies;

  SuccessMovieState(this.movies);
}
