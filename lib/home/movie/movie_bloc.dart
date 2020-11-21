import 'dart:async';
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:recommender/model/movies.dart';
import 'package:recommender/service/Api.dart';

part 'movie_event.dart';
part 'movie_state.dart';

class MovieBloc extends Bloc<MovieEvent, MovieState> {

  final Api _api;

  MovieBloc({ @required Api api}) :
        assert(api != null),
        _api = api,
        super(MovieInitial());

  @override
  Stream<MovieState> mapEventToState(
    MovieEvent event,
  ) async* {
    if (event is GetAllMovie) {
      yield* _mapGetAllMovie();
    }
  }

  Stream<MovieState> _mapGetAllMovie() async* {
    try {
      yield LoadingMovieState();
      List<Movie> movies = await _api.getAllMovies();
      yield SuccessMovieState(movies);
    } catch (e) {
      yield FailureMovieState();
    }
  }

}
