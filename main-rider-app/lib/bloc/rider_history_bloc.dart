import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Schema/post_json.dart';

class RiderHistoryBloc extends Cubit<List<PostJson>> {
  final riderId = FirebaseAuth.instance.currentUser?.uid;

  RiderHistoryBloc() : super([]);

  Future<void> fetchAcceptedPosts() async {
    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .where('accepted', isEqualTo: 2)
          .where('riderUid', isEqualTo: riderId)
          .get();

      final posts = querySnapshot.docs
          .map((doc) =>
              PostJson.fromJson(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      emit(posts);
    } catch (error) {
      // Handle the error
      emit([]);
    }
  }
}
