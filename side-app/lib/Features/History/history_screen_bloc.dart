import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../Data/JSON/post_json.dart';
import 'history_screen_provider.dart';

// Events
abstract class HistoryScreenEvent {}

class FetchPostsEvent extends HistoryScreenEvent {}

class RateRiderEvent extends HistoryScreenEvent {
  final PostJson post;
  double rating;

  RateRiderEvent(this.post, this.rating);
}

class RefreshPostsEvent extends HistoryScreenEvent {}

// States
abstract class HistoryScreenState {}

class HistoryScreenLoadingState extends HistoryScreenState {}

class HistoryScreenLoadedState extends HistoryScreenState {
  final List<PostJson> posts;

  HistoryScreenLoadedState(this.posts);
}

class HistoryScreenErrorState extends HistoryScreenState {
  final String error;

  HistoryScreenErrorState(this.error);
}

// BLoC
class HistoryScreenBloc extends Bloc<HistoryScreenEvent, HistoryScreenState> {
  final user = FirebaseAuth.instance.currentUser!;
  final provider = HistoryScreenProvider();

  HistoryScreenBloc() : super(HistoryScreenLoadingState()) {
    on<FetchPostsEvent>(_mapFetchPostsEventToState);
    on<RateRiderEvent>(_mapRateRiderEventToState);
    on<RefreshPostsEvent>(_mapRefreshPostsEventToState);
  }

  void _mapFetchPostsEventToState(
      FetchPostsEvent event, Emitter<HistoryScreenState> emit) async {
    try {
      final fetchedPosts = await provider.fetchPosts(user.uid.toString());
      emit(HistoryScreenLoadedState(fetchedPosts));
    } catch (error) {
      emit(HistoryScreenErrorState('Failed to fetch posts: $error'));
    }
  }

  void _mapRateRiderEventToState(
      RateRiderEvent event, Emitter<HistoryScreenState> emit) async {
    try {
      final post = event.post;
      final rating = event.rating;
      final riderUid = post.riderUid;
      if (riderUid != null) {
        final riderDoc =
            FirebaseFirestore.instance.collection('riders').doc(riderUid);
        final riderSnapshot = await riderDoc.get();
        if (riderSnapshot.exists) {
          final currentRating = riderSnapshot.data()?['rating'] ?? 0.0;

          await FirebaseFirestore.instance
              .collection('posts')
              .doc(post.pid)
              .update({'riderRating': rating});

          if (currentRating != 0.0) {
            final totalRating = currentRating + rating;

            await riderDoc.update({'rating': totalRating / 2});
          } else {
            await riderDoc.update({'rating': rating});
          }
        }
      }
    } catch (error) {
      // Handle rate rider error
      print('Failed to rate rider: $error');
    }
  }

  void _mapRefreshPostsEventToState(
      RefreshPostsEvent event, Emitter<HistoryScreenState> emit) async {
    add(FetchPostsEvent());
  }
}
