import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recommender/home/rating/rating_bloc.dart';
import 'package:recommender/model/model.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

class MyRatingsCard extends StatefulWidget {

  final MyRating rating;

  const MyRatingsCard({Key key, this.rating}) : super(key: key);

  @override
  _MyRatingsCardState createState() => _MyRatingsCardState();
}

class _MyRatingsCardState extends State<MyRatingsCard> {

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
                  widget.rating.posterurl,
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
                  // onRated: (rating) {
                  //   BlocProvider.of<RatingBloc>(context).add(UpdateRating(rating, widget.movie, BlocProvider.of<AuthenticationBloc>(context).state.user.id));
                  // },
                  color: Colors.white,
                  borderColor: Colors.white,
                  starCount: 5,
                  isReadOnly: true,
                  rating: widget.rating.rating,
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
