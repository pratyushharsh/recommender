import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recommender/authentication/authentication.dart';
import 'package:recommender/home/movie/movie_bloc.dart';
import 'package:recommender/home/rating/rating_bloc.dart';
import 'package:recommender/home/recommended/recommendation_bloc.dart';
import 'package:recommender/home/widgets/my_ratings_card.dart';
import 'package:recommender/model/model.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class HomePage extends StatelessWidget {

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => HomePage());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RecommendationBloc>(
            create: (context) => RecommendationBloc(api: RepositoryProvider.of(context))
              ..add(GetRecommendation(BlocProvider.of<AuthenticationBloc>(context).state.user.id))
        ),
        BlocProvider<RatingBloc>(
            create: (context) => RatingBloc(api: RepositoryProvider.of(context), user: BlocProvider.of<AuthenticationBloc>(context).state.user)
                ..add(GetAllRatedMovie(BlocProvider.of<AuthenticationBloc>(context).state.user.id))
        ),
        BlocProvider<MovieBloc>(
            create: (context) => MovieBloc(api: RepositoryProvider.of(context))
                ..add(GetAllMovie())
        )
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text("Movie Recommendation System"),
          actions: [
            // CircleAvatar(
            //   child: Text("H"),
            // ),
            IconButton(
              padding: EdgeInsets.only(right: 50, top: 20, bottom: 20),
              onPressed: () {
                BlocProvider.of<AuthenticationBloc>(context).add(AuthenticationLogoutRequested());
              },
              icon: Icon(Icons.logout),
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10,),
                Text("Recommended Movie", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),),
                SizedBox(height: 3,),
                RecommendedMovie(),
                SizedBox(height: 20,),
                Text("Rated Movie", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),),
                SizedBox(height: 3,),
                MyRatedMovie(),
                SizedBox(height: 20,),
                Text("All Movies", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),),
                SizedBox(height: 3,),
                AllMovie(),
                SizedBox(height: 20,),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AllMovie extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MovieBloc, MovieState>(
        builder: (context, state) {
          if (state is SuccessMovieState) {
            return Container(
              height: 350,
              child: ListView.builder(
                itemCount: state.movies.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (ctx, idx) {
                  return MovieCard(movie: state.movies[idx],);
                },
              ),
            );
          } else if (state is LoadingMovieState) {
            return CircularProgressIndicator();
          } else {
            return Container(
              child: Text("Failed"),
            );
          }
        }
    );
  }
}


class RecommendedMovie extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecommendationBloc, RecommendationState>(
      builder: (context, state) {
        if (state is SuccessRecommendationState) {
          return Container(
            height: 350,
            child: ListView.builder(
              itemCount: state.movies.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (ctx, idx) {
                return MovieCard(movie: state.movies[idx],);
              },
            ),
          );
        } else if (state is LoadingRecommendationState) {
          return CircularProgressIndicator();
        } else {
          return Container(
            child: Text("Failed"),
          );
        }
      }
    );
  }
}

class MyRatedMovie extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RatingBloc, RatingState>(
        builder: (context, state) {
          if (state is SuccessMyRatingState) {
            return Container(
              height: 350,
              child: ListView.builder(
                itemCount: state.ratings.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (ctx, idx) {
                  return MyRatingsCard(rating: state.ratings[idx],);
                },
              ),
            );
          } else if (state is LoadingMyRatings) {
            return CircularProgressIndicator();
          } else {
            return Container(
              child: Text("Failed"),
            );
          }
        }
    );
  }
}

class MovieCard extends StatefulWidget {

  final Movie movie;

  const MovieCard({Key key, this.movie}) : super(key: key);

  @override
  _MovieCardState createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> {

  double _elevation = 3;
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) {
        setState(() {
          _elevation = 10;
          _scale = 1.25;
        });
      },
      onExit: (event) {
        setState(() {
          _elevation = 3;
          _scale = 1;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: 200 * _scale,
        child: Card(
          margin: EdgeInsets.all(8),
          elevation: _elevation,
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                child: Image.network(
                  widget.movie.posterurl,
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Colors.black,
                    Colors.black12
                  ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.center),
                ),
              ),
              Positioned(
                bottom: 5,
                left: 10,
                child: SmoothStarRating(
                  onRated: (rating) {
                    BlocProvider.of<RatingBloc>(context).add(UpdateRating(rating, widget.movie, BlocProvider.of<AuthenticationBloc>(context).state.user.id));
                  },
                  color: Colors.white,
                  borderColor: Colors.white,
                  starCount: 5,
                  spacing: 2,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
