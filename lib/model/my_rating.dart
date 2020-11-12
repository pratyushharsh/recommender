class MyRating {
  String userId;
  String movieId;
  String posterurl;
  double rating;
  String releaseDate;
  String year;
  String imdbRating;
  String duration;
  String title;

  MyRating(
      {this.userId,
        this.movieId,
        this.posterurl,
        this.rating,
        this.releaseDate,
        this.year,
        this.imdbRating,
        this.duration,
        this.title});

  MyRating.fromJson(Map<String, dynamic> json) {
    userId = json['UserId'];
    movieId = json['MovieId'];
    posterurl = json['posterurl'];
    rating = json['rating'];
    releaseDate = json['releaseDate'];
    year = json['year'];
    imdbRating = json['imdbRating'];
    duration = json['duration'];
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['UserId'] = this.userId;
    data['MovieId'] = this.movieId;
    data['posterurl'] = this.posterurl;
    data['rating'] = this.rating;
    data['releaseDate'] = this.releaseDate;
    data['year'] = this.year;
    data['imdbRating'] = this.imdbRating;
    data['duration'] = this.duration;
    data['title'] = this.title;
    return data;
  }
}
