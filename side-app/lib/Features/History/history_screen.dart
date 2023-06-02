import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../Data/JSON/post_json.dart';
import 'history_screen_bloc.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HistoryScreenBloc>(
      create: (context) => HistoryScreenBloc()..add(FetchPostsEvent()),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF004643),
          centerTitle: true,
          elevation: 4,
          title: const Text(
            'History',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: BlocBuilder<HistoryScreenBloc, HistoryScreenState>(
          builder: (context, state) {
            if (state is HistoryScreenLoadingState) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is HistoryScreenLoadedState) {
              return ListView.builder(
                itemCount: state.posts.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            side: const BorderSide(
                              color: Color(0xFF004643),
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 10,
                          shadowColor: const Color(0xFF004643),
                          child: ListTile(
                            title: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    state.posts[index].name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF004643),
                                      fontSize: 20.0,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    state.posts[index].title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF004643),
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Text(
                                    state.posts[index].quantity,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF004643),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                              child: Text(
                                state.posts[index].description,
                                style: const TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: Color(0xFF5A7A79),
                                ),
                              ),
                            ),
                            trailing: Wrap(
                              spacing: 12, // space between two icons
                              children: <Widget>[
                                if (state.posts[index].riderRating == null)
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      _showRatingDialog(
                                          context, state.posts[index]);
                                    },
                                    icon: const Icon(Icons.star),
                                    label: const Text('Rate Rider'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF004803),
                                      padding: const EdgeInsets.all(8),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      )
                    ],
                  );
                },
              );
            } else {
              return const Center(
                child: Text('Failed to load posts.'),
              );
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            BlocProvider.of<HistoryScreenBloc>(context)
                .add(RefreshPostsEvent());
          },
          backgroundColor: const Color(0xFFF9BC60),
          child: const Icon(Icons.refresh),
        ),
      ),
    );
  }
}

void _showRatingDialog(BuildContext context, PostJson post) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      double rating = 0.0; // Initial rating value

      return AlertDialog(
        title: const Text('Rate Rider'),
        content: RatingBar.builder(
          minRating: 1,
          itemSize: 46,
          itemBuilder: (context, _) =>
              const Icon(Icons.star, color: Colors.amber),
          updateOnDrag: true,
          onRatingUpdate: (newRating) {
            rating = newRating;
          },
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Rate'),
            onPressed: () {
              BlocProvider.of<HistoryScreenBloc>(context)
                  .add(RateRiderEvent(post, rating));
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
