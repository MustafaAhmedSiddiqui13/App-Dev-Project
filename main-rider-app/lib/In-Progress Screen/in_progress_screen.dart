import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../Schema/post_json.dart';
import '../Startup Screens/timer.dart';
import '../Tracking Screens/ngo_track_food.dart';
import '../Tracking Screens/track_food.dart';
import '../bloc/in_progress_bloc.dart';

class InProgress extends StatelessWidget {
  const InProgress({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InProgressBloc(),
      child: const InProgressScreen(),
    );
  }
}

class InProgressScreen extends StatefulWidget {
  const InProgressScreen({super.key});

  @override
  InProgressScreenState createState() => InProgressScreenState();
}

class InProgressScreenState extends State<InProgressScreen> {
  late InProgressBloc _inProgressBloc;
  late final TimerClass _timer = TimerClass();

  @override
  void initState() {
    super.initState();
    _inProgressBloc = BlocProvider.of<InProgressBloc>(context);
    _inProgressBloc.fetchAcceptedPosts();
  }

  @override
  void dispose() {
    _inProgressBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('In Progress Orders'),
        backgroundColor: Colors.teal,
      ),
      body: BlocBuilder<InProgressBloc, List<PostJson>>(
        builder: (context, posts) {
          if (posts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('${post.description}\nQuantity: ${post.quantity}'),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () async {
                            final status =
                                await _inProgressBloc.fetchRiderStatus();
                            _timer.startLocationUpdates();
                            if (status == 'accepted') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TrackFood(
                                    post: post,
                                  ),
                                ),
                              );
                            } else if (status == 'pickedup') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NgoTrackFood(
                                    post: post,
                                  ),
                                ),
                              );
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.teal),
                          ),
                          child: const Text('Continue Delivery'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
