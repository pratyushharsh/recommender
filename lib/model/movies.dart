class Movie {
  String movieId;
  String posterurl;
  int averageRating;
  String releaseDate;
  String year;
  String imdbRating;
  String duration;
  String title;

  Movie(
      {this.movieId,
        this.posterurl,
        this.averageRating,
        this.releaseDate,
        this.year,
        this.imdbRating,
        this.duration,
        this.title});

  Movie.fromJson(Map<String, dynamic> json) {
    movieId = json['MovieId'];
    posterurl = json['posterurl'];
    averageRating = json['averageRating'];
    releaseDate = json['releaseDate'];
    year = json['year'];
    imdbRating = json['imdbRating'];
    duration = json['duration'];
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['MovieId'] = this.movieId;
    data['posterurl'] = this.posterurl;
    data['averageRating'] = this.averageRating;
    data['releaseDate'] = this.releaseDate;
    data['year'] = this.year;
    data['imdbRating'] = this.imdbRating;
    data['duration'] = this.duration;
    data['title'] = this.title;
    return data;
  }
}
