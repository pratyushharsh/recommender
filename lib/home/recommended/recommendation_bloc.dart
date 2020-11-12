import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:recommender/model/model.dart';
import 'package:recommender/service/Api.dart';

part 'recommendation_event.dart';
part 'recommendation_state.dart';

class RecommendationBloc extends Bloc<RecommendationEvent, RecommendationState> {
  RecommendationBloc({ @required Api api}) :
        assert(api != null),
        _api = api,
        super(RecommendationInitial());

  final Api _api;

  @override
  Stream<RecommendationState> mapEventToState(
    RecommendationEvent event,
  ) async* {
    // TODO: implement mapEventToState
    if (event is GetRecommendation) {
      yield* _mapRecommendation();
    }
  }

  Stream<RecommendationState> _mapRecommendation() async* {
    try {
      yield LoadingRecommendationState();
      List<Movie> movie = await _api.getAllMovies() as List;
      yield SuccessRecommendationState(movie);
    } catch (e) {
      yield FailureRecommendationState();
    }
  }
}
