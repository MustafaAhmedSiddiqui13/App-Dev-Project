// Define the events
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Schema/post_json.dart';

abstract class PostEvent {}

class FetchAcceptedPosts extends PostEvent {}

// Define the state
abstract class PostState {}

class PostInitial extends PostState {}

class PostLoading extends PostState {}

class PostLoaded extends PostState {
  final List<PostJson> posts;

  PostLoaded(this.posts);
}

class PostError extends PostState {
  final String error;

  PostError(this.error);
}

// Define the BLoC class
class PostBloc extends Bloc<PostEvent, PostState> {
  final FirebaseFirestore firestore;

  PostBloc(this.firestore) : super(PostInitial()) {
    on<FetchAcceptedPosts>(_fetchAcceptedPosts);
  }

  Future<void> _fetchAcceptedPosts(
      FetchAcceptedPosts event, Emitter<PostState> emit) async {
    emit(PostLoading());

    try {
      final QuerySnapshot querySnapshot = await firestore
          .collection('posts')
          .where('accepted', isEqualTo: 1)
          .get();

      final posts = querySnapshot.docs
          .map((doc) =>
              PostJson.fromJson(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      emit(PostLoaded(posts));
    } catch (error) {
      emit(PostError(error.toString()));
    }
  }
}
