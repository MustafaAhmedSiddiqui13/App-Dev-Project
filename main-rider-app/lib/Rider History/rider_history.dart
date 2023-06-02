import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../Schema/post_json.dart';
import '../bloc/rider_history_bloc.dart';
import 'finished_post_details.dart';

class RiderHistory extends StatelessWidget {
  const RiderHistory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RiderHistoryBloc(),
      child: const RiderHistoryScreen(),
    );
  }
}

class RiderHistoryScreen extends StatefulWidget {
  const RiderHistoryScreen({super.key});

  @override
  RiderHistoryScreenState createState() => RiderHistoryScreenState();
}

class RiderHistoryScreenState extends State<RiderHistoryScreen> {
  late RiderHistoryBloc _riderHistoryBloc;

  @override
  void initState() {
    super.initState();
    _riderHistoryBloc = BlocProvider.of<RiderHistoryBloc>(context);
    _riderHistoryBloc.fetchAcceptedPosts();
  }

  @override
  void dispose() {
    _riderHistoryBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rider History'),
        backgroundColor: Colors.teal,
      ),
      body: BlocBuilder<RiderHistoryBloc, List<PostJson>>(
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FinishedPost(
                                  post: post,
                                ),
                              ),
                            );
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.teal),
                          ),
                          child: const Text('View Details'),
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
