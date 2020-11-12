import 'dart:convert';

import 'package:recommender/model/model.dart';
import 'package:recommender/service/ApiService.dart';


class Api {

  ApiService _helper = ApiService();

  Future<List<Movie>> getAllMovies() async {
    var movies = List<Movie>();
    var response = await _helper.get("/movie");
    for (var m in response) {
      movies.add(Movie.fromJson(m));
    }
    return movies;
  }

  Future<List<MyRating>> getRatedMovies(String userId) async {
    var movies = List<MyRating>();
    var response = await _helper.get("/$userId") as List<dynamic>;
    for (var m in response) {
      movies.add(MyRating.fromJson(m));
    }
    return movies;
  }

  Future<void> updateRating(MyRating rating) async {
    var request = json.encode(rating.toJson());
    var response = await _helper.post("/review", request);
  }
}