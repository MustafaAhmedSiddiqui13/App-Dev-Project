import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rider_app/All%20Orders%20Screens/post_details_screen.dart';
import '../bloc/posts_screen_bloc.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({Key? key}) : super(key: key);

  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  late PostBloc _postBloc;

  @override
  void initState() {
    super.initState();
    _postBloc = PostBloc(FirebaseFirestore.instance);
    _postBloc.add(FetchAcceptedPosts());
  }

  @override
  void dispose() {
    _postBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Orders'),
        backgroundColor: Colors.teal,
      ),
      body: BlocBuilder<PostBloc, PostState>(
        bloc: _postBloc,
        builder: (context, state) {
          if (state is PostLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PostError) {
            return Center(child: Text('Error: ${state.error}'));
          } else if (state is PostLoaded) {
            return ListView.builder(
              itemCount: state.posts.length,
              itemBuilder: (context, index) {
                final post = state.posts[index];
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
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text('${post.description}\nQuantity: ${post.quantity}'),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () async {
                            // ignore: use_build_context_synchronously
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PostDetailsScreen(
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
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }
}
