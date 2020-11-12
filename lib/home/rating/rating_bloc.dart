import 'dart:async';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:recommender/model/model.dart';
import 'package:recommender/service/Api.dart';

part 'rating_event.dart';
part 'rating_state.dart';

class RatingBloc extends Bloc<RatingEvent, RatingState> {
  RatingBloc({ @required Api api, @required User user}) :
        assert(api != null),
        _api = api,
        _user = user,
        super(RatingInitial());

  final Api _api;
  final User _user;

  @override
  Stream<RatingState> mapEventToState(
    RatingEvent event,
  ) async* {
    if (event is UpdateRating) {
      yield*_mapUpdateRating(event);
    } else if (event is GetAllRatedMovie) {
      yield* _mapMyRatings(event);
    }
    // TODO: implement mapEventToState
  }

  Stream<RatingState> _mapUpdateRating(UpdateRating event) async* {
    MyRating req = MyRating(
      rating: event.rating,
      movieId: event.movie.movieId,
      duration: event.movie.duration,
      posterurl: event.movie.posterurl,
      releaseDate: event.movie.releaseDate,
      title: event.movie.title,
      year: event.movie.year,
      userId: event.userId
    );
    try {
      await _api.updateRating(req);
      GetAllRatedMovie(_user.id);
    } catch(e) {
    }
  }

  Stream<RatingState> _mapMyRatings(GetAllRatedMovie event) async* {
    yield LoadingMyRatings();
    try {
      List<MyRating> ratings = await _api.getRatedMovies(event.userId);
      yield SuccessMyRatingState(ratings);
    } catch (e) {
     yield FailureMyRatingState();
    }
  }
}
